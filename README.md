# dotfiles-nix

My NixOS + Home Manager setup for a ThinkPad P14s Gen2 (AMD). Host is `irnixos`.

## Layout

```
flake.nix              entrypoint
nixos/
  configuration.nix    system config
  modules/             networking, locale, display, audio, users,
                       packages, secrets, security
  nvf/                 neovim (via notashelf/nvf)
home-manager/
  home.nix
  modules/             packages, shell, terminals, services, desktop
  dotfiles/            sway, waybar, fuzzel, swaync, kpass, scripts
secrets/               sops-encrypted
treefmt.nix
```

## Usage

```sh
nh os switch .         # rebuild system
nh home switch .       # rebuild user env
treefmt                # format
nix develop            # shell with sops, age, nh, formatters, hooks
```

Targets: `.#irnixos` and `.#ir@irnixos`.

## Inputs

nixpkgs-unstable, home-manager, nixos-hardware (P14s AMD Gen2),
[nvf](https://github.com/notashelf/nvf), nix-jetbrains-plugins, treefmt-nix,
sops-nix, git-hooks.nix, nix-index-database, plus one private input.

## Checks

`nix flake check` runs treefmt, deadnix, statix, check-added-large-files,
ripsecrets and detect-private-keys. Same hooks fire in `nix develop`.

## Secrets

`sops` + age. Only the encrypted yaml/env files are in git. Decryption
happens at activation via sops-nix.

## Notes to self

- keep modules small, don't reshuffle the layout for fun
- prefer nvf options to custom lua
- rebuild after every change, don't trust dry-run alone

## License

MIT, see [LICENSE](./LICENSE).
