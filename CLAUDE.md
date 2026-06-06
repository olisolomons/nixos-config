# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

NixOS + Home Manager configuration for a single-user desktop (user: `oli`, hostname: `nixos`). Two config files cover different layers:

- `home.nix` — Home Manager: user packages, dotfiles, and program configuration (neovim, git, tmux, firefox, i3, direnv, etc.)
- `configuration.nix` — NixOS system config: boot, networking, display server, audio, keyboard layout, system services

The neovim config lives in `nvim/init.lua` and is inlined into `home.nix` via `lib.fileContents`.

## Applying changes

```bash
# Apply home-manager changes (home.nix)
home-manager switch

# Apply NixOS system changes (configuration.nix)
nrs   # shell alias defined in home.nix — runs: sudo nixos-rebuild switch -I nixos-config=$HOME/.config/home-manager/configuration.nix
```

## Key conventions

- **Nix formatting**: 2-space indentation (enforced by `nixfmt-classic` + `nil` LSP).
- **NUR (Nix User Repository)**: used for Firefox extensions (`nur.repos.rycee.firefox-addons`). The NUR tarball hash is pinned; update both the `url` revision and `sha256` together when bumping. NUR is imported in both `home.nix` and `configuration.nix` — keep the pinned revision in sync.
- **Treesitter parsers**: managed entirely by Nix (`auto_install = false`). Add parsers to the `nvim-treesitter-parsers` list in `home.nix`, not from within neovim.
- **LSP servers**: configured in `nvim/init.lua` but the binaries must be available on `$PATH` (install via `home.packages` or a project `devShell`). Currently configured: `nil_ls` (Nix), `ts_ls` (TypeScript via `npx`), `pyright`, `clojure_lsp`, `ocamllsp`, `lua_ls`, `gopls`.
- **i3 modes**: power (`Super+x`), brightness (`Super+z`), audio (`Super+Ctrl+z`), launch (`Super+r`).
