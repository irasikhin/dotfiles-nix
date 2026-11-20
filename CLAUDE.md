# CLAUDE.md

This repository contains NixOS and Home Manager dotfiles for host `irnixos`.

## Scope

- `flake.nix`: flake entrypoint and inputs.
- `nixos/configuration.nix`: system-level NixOS configuration.
- `home-manager/home.nix`: user-level Home Manager configuration.
- `home-manager/dotfiles/`: plain dotfiles and helper scripts.
- `home-manager/dotfiles/nvim/`: Neovim configuration (LazyVim, plain Lua).
- `home-manager/modules/neovim.nix`: editor binaries (LSP servers, formatters,
  linters, debug adapters) and the generated `nix-paths.lua` the config reads.

## Common commands

- Apply NixOS config: `nh os switch .`
- Apply Home Manager config: `nh home switch .`
- Format repository: `treefmt`

## Working rules

- Prefer minimal changes and preserve the existing module layout.
- Keep formatting consistent with `treefmt`.
- When changing Neovim behavior, prefer LazyVim extras and plugin options over custom Lua wrappers unless the custom behavior is clearly useful.
- After making changes, rebuild the affected Nix configuration and run the relevant verification steps before considering the work complete.
- Do not remove user changes in unrelated files. The worktree may be dirty.
- Treat `home-manager/dotfiles/nvim/` as high-churn: review for accidental custom logic duplication before adding more Lua.

## Notes

- The flake targets:
  - NixOS configuration: `.#irnixos`
  - Home Manager configuration: `.#ir@irnixos`
- `nvf` is gone: LazyVim plugins are fetched by `lazy.nvim` at runtime, while LSP
  servers, formatters and linters are installed declaratively in
  `home-manager/modules/neovim.nix` (Mason is disabled in the Neovim config,
  since Mason's runtime downloads do not run on NixOS).
