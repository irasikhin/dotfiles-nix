#!/bin/sh

set -e

# Resolve the flake relative to this script, not the caller's CWD, so `.#`
# always refers to this repo regardless of where rebuild.sh is invoked from.
cd "$(dirname "$0")" || exit 1

sudo nixos-rebuild switch --flake .#irnixos
home-manager switch --flake .#ir@irnixos
