#!/bin/sh

set -e

sudo nixos-rebuild switch --flake .#irnixos
home-manager switch --flake .#irasikhin@irnixos
