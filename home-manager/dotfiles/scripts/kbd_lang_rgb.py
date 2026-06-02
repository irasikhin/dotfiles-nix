#!/usr/bin/env python3
"""Drive the BCORNE split's RGB to indicate the active xkb layout.

The keyboard runs VialRGB. The host cannot read the keyboard's QMK *layer*, but
it does know the xkb *language* (sway/xkb), so we use RGB purely as a language
indicator: Russian -> red, English -> blue.

We set the VialRGB "solid color" effect (mode 2) and only change its hue. Unlike
VialRGB direct mode, a normal effect is computed by the firmware on BOTH split
halves, so the colour shows up on the slave half too (direct mode leaves the
slave half dark on this board).

No firmware changes: everything is host -> keyboard over the Vial rawhid HID
interface (usage page 0xFF60). Runs as a user service, follows layout changes by
subscribing to sway input events.
"""

import glob
import json
import os
import subprocess
import sys
import time

VENDOR_ID = "45D4"  # BCORNE / BORNE
VIALRGB_SET_VALUE = 0x07
VIALRGB_ID_SET_MODE = 0x41
VIALRGB_MODE_SOLID = 2  # RGB_MATRIX_SOLID_COLOR as exposed by VialRGB

# Per-language (hue, sat, val), 0-255. Dim, on purpose. Board max_brightness=50.
# en is the neutral default: a cool, low-saturation white. ru is warm amber.
# (A static base + reactive keypress splash needs custom firmware; until then
# this is a steady solid-colour indicator.)
COLOR_EN = (140, 25, 14)   # cold white
COLOR_RU = (22, 200, 15)   # warm amber


def find_rawhid():
    """Return the /dev/hidrawN node that is the keyboard's Vial rawhid (FF60)."""
    for path in glob.glob("/sys/class/hidraw/hidraw*"):
        name = os.path.basename(path)
        dev = os.path.join(path, "device")
        try:
            with open(os.path.join(dev, "uevent")) as f:
                uevent = f.read()
            if f"HID_ID=" not in uevent or VENDOR_ID not in uevent.upper():
                continue
            with open(os.path.join(dev, "report_descriptor"), "rb") as f:
                desc = f.read()
            # usage page 0xFF60 -> bytes 06 60 FF in the report descriptor
            if b"\x06\x60\xff" in desc:
                return f"/dev/{name}"
        except OSError:
            continue
    return None


def set_color(hue, sat, val):
    node = find_rawhid()
    if not node:
        return False
    pkt = bytes([0x00, VIALRGB_SET_VALUE, VIALRGB_ID_SET_MODE,
                 VIALRGB_MODE_SOLID & 0xFF, VIALRGB_MODE_SOLID >> 8,
                 0, hue, sat, val])
    pkt += b"\x00" * (33 - len(pkt))
    try:
        fd = os.open(node, os.O_RDWR)
        try:
            os.write(fd, pkt)
            os.read(fd, 32)
        finally:
            os.close(fd)
        return True
    except OSError:
        return False


def active_layout():
    """Return the active xkb layout name reported by sway, or None."""
    try:
        out = subprocess.run(["swaymsg", "-t", "get_inputs"],
                             capture_output=True, text=True, timeout=5)
        inputs = json.loads(out.stdout)
    except (subprocess.SubprocessError, json.JSONDecodeError, OSError):
        return None
    for inp in inputs:
        name = inp.get("xkb_active_layout_name")
        if name:
            return name
    return None


def color_for(layout_name):
    if layout_name and "Russian" in layout_name:
        return COLOR_RU
    return COLOR_EN


def wait_for_sway():
    """Block until a sway IPC socket exists, exporting SWAYSOCK."""
    while True:
        socks = glob.glob(f"/run/user/{os.getuid()}/sway-ipc.*.sock")
        if socks:
            os.environ["SWAYSOCK"] = socks[0]
            return
        time.sleep(2)


def main():
    wait_for_sway()
    last = None

    def apply():
        nonlocal last
        cur = active_layout()
        if cur != last:
            last = cur
            set_color(*color_for(cur))

    apply()  # initial state

    # Stream sway input events; re-evaluate the layout on each.
    proc = subprocess.Popen(
        ["swaymsg", "-t", "subscribe", "-m", '["input"]'],
        stdout=subprocess.PIPE, text=True)
    try:
        for _line in proc.stdout:
            apply()
    finally:
        proc.terminate()


if __name__ == "__main__":
    sys.exit(main())
