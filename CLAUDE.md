# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Flake-based NixOS + Home Manager configuration for two machines, with shared modules. Home Manager runs as a NixOS module (applied via `nixos-rebuild`, not `home-manager switch`).

## Structure

```
flake.nix                              — inputs (nixpkgs 25.11, nixpkgs-unstable, NUR, home-manager), both nixosConfigurations
hosts/
  adele/                               — desktop machine (i3/lightdm)
    configuration.nix
    hardware-configuration.nix
    home.nix
  dell-xps/                            — Dell XPS laptop (GNOME/GDM)
    configuration.nix
    hardware-configuration.nix
    home.nix
modules/
  nixos/common.nix                     — shared system config (locale, pipewire, user, keyboard, networking)
  home-manager/common.nix              — shared HM config (neovim, firefox, git, tmux, direnv, common packages)
nvim/init.lua                          — single shared neovim config
home-manager/
  i3.nix                               — i3 window manager config (imported by hosts/adele/home.nix)
  i3-mode-extension/                   — custom GNOME shell extension for i3-style modes (used by dell-xps)
bg.jpg                                 — lightdm background (adele)
```

## Applying changes

Run from the repo root:

```bash
# Applies NixOS system config + home-manager together
sudo nixos-rebuild --flake .#adele switch      # on adele
sudo nixos-rebuild --flake .#dell-xps switch   # on dell-xps

# Update all flake inputs
nix flake update
```

## Key conventions

- **Shared vs host-specific**: add to `modules/*/common.nix` if both machines need it; add to `hosts/<name>/` if it's machine-specific.
- **Nix formatting**: 2-space indentation (`nixfmt-classic` + `nil` LSP).
- **NUR**: added as a flake input with `nur.overlays.default`. Available as `pkgs.nur` in both NixOS and HM modules (via `useGlobalPkgs = true`). No manual hash pinning needed.
- **Unstable channel**: passed as `unstable` arg to home-manager modules via `extraSpecialArgs`. Neovim and its plugins come from `unstable`. Add `unstable` to module args to use it.
- **Treesitter parsers**: managed by Nix (`auto_install = false`). Add parsers to the list in `modules/home-manager/common.nix`, from `unstable.vimPlugins.nvim-treesitter-parsers`.
- **`useGlobalPkgs = true`**: HM uses the system's pkgs instance, so NixOS overlays (NUR, unstable) are available in HM modules without re-importing.
- **adele-specific**: i3/lightdm, TeamViewer, prismlauncher, keybase, caffeine-ng.
- **dell-xps-specific**: GNOME/GDM, bluetooth, Intel IPU6 camera, v4l2loopback virtual webcam, Zoom, Slack, custom i3-mode GNOME extension.
