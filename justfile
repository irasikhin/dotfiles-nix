# dotfiles-nix task runner. Run `just` to list recipes.
# Flake targets: NixOS `.#irnixos`, Home Manager `.#ir@irnixos`.

# show available recipes
default:
    @just --list

# build + activate the NixOS system
switch:
    nh os switch .

# build the system WITHOUT activating (sanity check)
build:
    nh os build .

# build + activate the Home Manager config
home:
    nh home switch .

# build + activate both system and Home Manager
all: switch home

# update flake inputs, then rebuild system + Home Manager
upgrade: update switch home

# format the whole repo
fmt:
    treefmt

# edit the encrypted ssh host config, then re-render + apply
edit-ssh:
    sops secrets/ssh-hosts.yaml
    git add secrets/ssh-hosts.yaml
    git diff --quiet --cached secrets/ssh-hosts.yaml || nh os switch .

# edit the shared encrypted secrets file (stage after)
edit-secrets:
    sops secrets/secrets.yaml
    git add secrets/secrets.yaml

# edit the VNC console secrets (read at runtime by scripts — no rebuild needed)
edit-vnc:
    sops secrets/vnc.yaml
    git add secrets/vnc.yaml

# re-encrypt all secrets to current .sops.yaml recipients (after adding a host/key)
rekey:
    sops updatekeys -y secrets/secrets.yaml secrets/ssh-hosts.yaml secrets/vnc.yaml

# update all flake inputs (or `just update <input>`)
update input="":
    nix flake update {{input}}

# remove old generations + collect garbage
clean:
    nh clean all
