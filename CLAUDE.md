# CLAUDE.md

This repository contains NixOS and Home Manager dotfiles for host `irnixos`.

## Scope

- `flake.nix`: flake entrypoint and inputs.
- `nixos/configuration.nix`: system-level NixOS configuration.
- `nixos/nvf.nix`: Neovim configuration through `nvf`.
- `home-manager/home.nix`: user-level Home Manager configuration.
- `home-manager/dotfiles/`: plain dotfiles and helper scripts.

## Common commands

- Apply NixOS config: `nh os switch .`
- Apply Home Manager config: `nh home switch .`
- Format repository: `treefmt`

## Working rules

- Prefer minimal changes and preserve the existing module layout.
- Keep formatting consistent with `treefmt`.
- When changing Neovim behavior, prefer builtin `nvf` or plugin functionality over custom Lua wrappers unless the custom behavior is clearly useful.
- After making changes, rebuild the affected Nix configuration and run the relevant verification steps before considering the work complete.
- Do not remove user changes in unrelated files. The worktree may be dirty.
- Treat `nixos/nvf.nix` as high-churn: review for accidental custom logic duplication before adding more Lua.

## Notes

- The flake targets:
  - NixOS configuration: `.#irnixos`
  - Home Manager configuration: `.#ir@irnixos`
- `nvf` is imported as a NixOS module from the flake input.
