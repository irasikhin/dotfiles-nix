#!/usr/bin/env bash

set -euo pipefail

umask 077

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
KEEPASS_DIR="${HOME}/.keepass"
PASS_DB_PATH="${KEEPASS_DIR}/pass.kdbx"
WKEYS_DB_PATH="${KEEPASS_DIR}/wkeys.kdbx"
NEXTCLOUD_KEEPASS_DIR="${HOME}/Nextcloud/keepass"
BACKUP_PREFIX="pass-store-backup"
BACKUP_EXTENSION=".tar.gz.enc"

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/backup-pass-keepass.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM HUP

usage() {
  cat <<'EOF'
Usage:
  backup_pass_to_keepass.sh [--password-file /path/to/file]

Password file formats:
  1. Named values:
       backup=...
       pass_kdbx=...
       wkeys_kdbx=...

  2. Three non-empty lines in order:
       line 1 -> backup password
       line 2 -> pass.kdbx password
       line 3 -> wkeys.kdbx password
EOF
}

require_pykeepass() {
  if ! python3 - <<'PY' >/dev/null 2>&1; then
import pykeepass
PY
    echo "python3 with pykeepass is required. Rebuild Home Manager and try again." >&2
    exit 1
  fi
}

prompt_password_twice() {
  local prompt="$1"
  local first second

  while true; do
    printf '%s\n' "$prompt" >&2
    IFS= read -r -s first
    printf '\n'
    printf 'Repeat %s\n' "$prompt" >&2
    IFS= read -r -s second
    printf '\n'

    if [[ -z $first ]]; then
      echo "Password cannot be empty." >&2
      continue
    fi

    if [[ $first != "$second" ]]; then
      echo "Passwords do not match." >&2
      continue
    fi

    printf '%s' "$first"
    return 0
  done
}

read_passwords_from_file() {
  local password_file="$1"
  local backup_password=""
  local pass_db_password=""
  local wkeys_db_password=""
  local -a lines=()
  local line

  if [[ ! -f $password_file ]]; then
    echo "Password file not found: ${password_file}" >&2
    exit 1
  fi

  while IFS= read -r line || [[ -n $line ]]; do
    [[ -n $line ]] || continue
    [[ $line =~ ^[[:space:]]*# ]] && continue

    case "$line" in
    backup=*)
      backup_password="${line#backup=}"
      ;;
    pass_kdbx=*)
      pass_db_password="${line#pass_kdbx=}"
      ;;
    wkeys_kdbx=*)
      wkeys_db_password="${line#wkeys_kdbx=}"
      ;;
    *)
      lines+=("$line")
      ;;
    esac
  done <"$password_file"

  if [[ -z $backup_password && -z $pass_db_password && -z $wkeys_db_password ]]; then
    if ((${#lines[@]} < 3)); then
      echo "Password file must contain either named values or at least three non-empty lines." >&2
      exit 1
    fi
    backup_password="${lines[0]}"
    pass_db_password="${lines[1]}"
    wkeys_db_password="${lines[2]}"
  fi

  if [[ -z $backup_password || -z $pass_db_password || -z $wkeys_db_password ]]; then
    echo "Password file must define backup, pass_kdbx, and wkeys_kdbx passwords." >&2
    exit 1
  fi

  printf '%s\n%s\n%s\n' "$backup_password" "$pass_db_password" "$wkeys_db_password"
}

confirm_overwrite() {
  local path="$1"
  local reply

  if [[ ! -e $path ]]; then
    return 0
  fi

  while true; do
    printf 'Overwrite %s? [y/N]: ' "$path" >&2
    IFS= read -r reply
    case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    [nN] | [nN][oO] | "") return 1 ;;
    *) echo "Enter y or n." >&2 ;;
    esac
  done
}

create_pass_backup() {
  local backup_password="$1"
  local backup_file="$2"
  local archive_file="$TEMP_DIR/pass-store-backup.tar.gz"
  local passphrase_file="$TEMP_DIR/pass-backup.passphrase"

  tar -C "$PASSWORD_STORE_DIR" -czf "$archive_file" .
  printf '%s' "$backup_password" >"$passphrase_file"

  openssl enc \
    -aes-256-cbc \
    -pbkdf2 \
    -salt \
    -in "$archive_file" \
    -out "$backup_file" \
    -pass "file:$passphrase_file"

  echo "Created encrypted pass backup: ${backup_file}"
}

create_pass_keepass_db() {
  local db_password="$1"
  local target_db="$2"
  local temp_db="$TEMP_DIR/pass.kdbx"
  local password_file="$TEMP_DIR/pass-kdbx.password"

  require_pykeepass
  printf '%s' "$db_password" >"$password_file"

  env PASSWORD_STORE_DIR="$PASSWORD_STORE_DIR" \
    TARGET_DB="$temp_db" \
    DB_PASSWORD_FILE="$password_file" \
    python3 - <<'PY'
import os
import subprocess
from pathlib import Path

from pykeepass import PyKeePass, create_database


def parse_entry(raw: str):
    lines = raw.splitlines()
    password = ""
    username = ""
    url = ""
    notes = []

    if lines:
        first = lines[0]
        if ": " in first:
            lines = [first] + lines[1:]
        else:
            password = first
            lines = lines[1:]

    for line in lines:
        if ": " in line:
            key, value = line.split(": ", 1)
            lowered = key.strip().lower()
            value = value.strip()
            if lowered in {"login", "user", "username"} and not username:
                username = value
                continue
            if lowered in {"url", "website"} and not url:
                url = value
                continue
        notes.append(line)

    return password, username, url, "\n".join(notes)


store = Path(os.environ["PASSWORD_STORE_DIR"]).expanduser()
database = Path(os.environ["TARGET_DB"])
db_password = Path(os.environ["DB_PASSWORD_FILE"]).read_text()

create_database(str(database), password=db_password)
kp = PyKeePass(str(database), password=db_password)
groups = {"": kp.root_group}


def ensure_group(group_path: str):
    if group_path in groups:
        return groups[group_path]
    current = ""
    parent = kp.root_group
    for segment in group_path.split("/"):
        if not segment:
            continue
        current = f"{current}/{segment}" if current else segment
        if current not in groups:
            groups[current] = kp.add_group(parent, segment)
        parent = groups[current]
    return parent


entry_files = []
for entry_file in store.rglob("*.gpg"):
    relative_parts = entry_file.relative_to(store).parts
    if any(part.startswith(".") for part in relative_parts):
        continue
    entry_files.append(entry_file)

for entry_file in sorted(entry_files):
    relative = entry_file.relative_to(store).with_suffix("")
    pass_name = relative.as_posix()
    raw = subprocess.check_output(["pass", "show", pass_name], text=True)
    password, username, url, notes = parse_entry(raw)
    group_path = relative.parent.as_posix()
    if group_path == ".":
        group_path = ""
    group = ensure_group(group_path)
    kp.add_entry(
        group,
        relative.name,
        username,
        password,
        url=url or None,
        notes=notes or None,
        force_creation=True,
    )

kp.save()
PY
  mv "$temp_db" "$target_db"
  echo "Created KeePass export: ${target_db}"
}

create_wkeys_keepass_db() {
  local db_password="$1"
  local target_db="$2"
  local temp_db="$TEMP_DIR/wkeys.kdbx"
  local password_file="$TEMP_DIR/wkeys-kdbx.password"
  local gnupg_archive="$TEMP_DIR/gnupg-backup.tar.gz"

  require_pykeepass
  printf '%s' "$db_password" >"$password_file"

  if [[ -d "$HOME/.gnupg" ]]; then
    tar -C "$HOME" \
      --exclude='.gnupg/S.gpg-agent*' \
      --exclude='.gnupg/*.lock' \
      --exclude='.gnupg/.#lk*' \
      --exclude='.gnupg/random_seed' \
      -czf "$gnupg_archive" \
      .gnupg
  fi

  env TARGET_DB="$temp_db" \
    DB_PASSWORD_FILE="$password_file" \
    HOME_DIR="$HOME" \
    GNUPG_ARCHIVE="$gnupg_archive" \
    python3 - <<'PY'
import base64
import os
from pathlib import Path

from pykeepass import PyKeePass, create_database


def random_password():
    return base64.b64encode(os.urandom(24)).decode("ascii")


def attach_file(kp, group, file_path: Path, note: str):
    entry = kp.add_entry(
        group,
        file_path.name,
        "",
        random_password(),
        notes=note,
        force_creation=True,
    )
    binary_id = kp.add_binary(file_path.read_bytes())
    entry.add_attachment(binary_id, file_path.name)


database = Path(os.environ["TARGET_DB"])
db_password = Path(os.environ["DB_PASSWORD_FILE"]).read_text()
home_dir = Path(os.environ["HOME_DIR"]).expanduser()

create_database(str(database), password=db_password)
kp = PyKeePass(str(database), password=db_password)
ssh_group = kp.add_group(kp.root_group, "SSH")
gpg_group = kp.add_group(kp.root_group, "GPG")

ssh_dir = home_dir / ".ssh"
if ssh_dir.is_dir():
    ssh_files = []
    for ssh_file in ssh_dir.iterdir():
        if not ssh_file.is_file():
            continue
        name = ssh_file.name
        if name.startswith("config") or name.startswith("known_hosts") or name.endswith(".old"):
            continue
        ssh_files.append(ssh_file)
    for ssh_file in sorted(ssh_files):
        attach_file(kp, ssh_group, ssh_file, f"Original path: {ssh_file}")

gnupg_archive = Path(os.environ["GNUPG_ARCHIVE"])
if gnupg_archive.exists():
    attach_file(kp, gpg_group, gnupg_archive, f"Backup of {home_dir / '.gnupg'} without runtime socket and lock files.")

kp.save()
PY

  mv "$temp_db" "$target_db"
  echo "Created key vault: ${target_db}"
}

main() {
  local backup_password pass_db_password wkeys_db_password
  local backup_timestamp backup_file
  local password_file=""
  local -a file_passwords=()

  while (($# > 0)); do
    case "$1" in
    --password-file)
      if (($# < 2)); then
        echo "--password-file requires a path." >&2
        exit 1
      fi
      password_file="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
    esac
  done

  if [[ ! -d $PASSWORD_STORE_DIR ]]; then
    echo "Password store not found: ${PASSWORD_STORE_DIR}" >&2
    exit 1
  fi

  mkdir -p "$NEXTCLOUD_KEEPASS_DIR" "$KEEPASS_DIR"

  if [[ -n $password_file ]]; then
    mapfile -t file_passwords < <(read_passwords_from_file "$password_file")
    backup_password="${file_passwords[0]}"
    pass_db_password="${file_passwords[1]}"
    wkeys_db_password="${file_passwords[2]}"
  else
    backup_password="$(prompt_password_twice "backup password")"
    pass_db_password="$(prompt_password_twice "pass.kdbx password")"
    wkeys_db_password="$(prompt_password_twice "wkeys.kdbx password")"
  fi

  if [[ $backup_password == "$pass_db_password" || $backup_password == "$wkeys_db_password" || $pass_db_password == "$wkeys_db_password" ]]; then
    echo "All three passwords must be different." >&2
    exit 1
  fi

  if ! confirm_overwrite "$PASS_DB_PATH"; then
    echo "Aborted: ${PASS_DB_PATH} was not overwritten." >&2
    exit 1
  fi

  if ! confirm_overwrite "$WKEYS_DB_PATH"; then
    echo "Aborted: ${WKEYS_DB_PATH} was not overwritten." >&2
    exit 1
  fi

  backup_timestamp="$(date +"%Y%m%d-%H%M%S")"
  backup_file="${NEXTCLOUD_KEEPASS_DIR}/${BACKUP_PREFIX}-${backup_timestamp}${BACKUP_EXTENSION}"

  create_pass_backup "$backup_password" "$backup_file"
  create_pass_keepass_db "$pass_db_password" "$PASS_DB_PATH"
  create_wkeys_keepass_db "$wkeys_db_password" "$WKEYS_DB_PATH"
}

main "$@"
