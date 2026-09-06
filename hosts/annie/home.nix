{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "24.05";

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      # Theme configuration
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      # Optional extensions
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        hidePodcasts
        shuffle # Enables shuffle+
      ];

      # Optional custom apps
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
      ];
    };

  programs.thunderbird = {
    enable = true;
    profiles = { };
  };
  programs.chromium.enable = true;

  home.packages = with pkgs; [
    unzip
    zip
    xclip
    jq
    ripgrep
    tree
    ffmpeg
    nil
    nixfmt
    (writeShellScriptBin "nrs" ''
      #!/usr/bin/env bash
      cd $HOME/src/nixos-config
      sudo nixos-rebuild --flake .#$(hostname) switch "$@"
    '')
    (writeShellScriptBin "do-updates" ''
      #!/usr/bin/env bash
      set -e
      cd "$HOME/src/nixos-config"
      echo "Updating flake inputs..."
      nix flake update
      echo "Rebuilding NixOS..."
      sudo nixos-rebuild --flake .#$(hostname) build "$@"
      echo "Press any key to activate the new version"
      read -n 1
      sudo nixos-rebuild --flake .#$(hostname) switch "$@"
    '')
    (pkgs.writeScriptBin "ignite_recipes" ''
      #!${pkgs.python3}/bin/python3
      ${builtins.readFile ./ignite_recipes.py}
    '')
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
    gimp
    p7zip
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins =
      (with pkgs.vimPlugins; [
        telescope-nvim
        telescope-ui-select-nvim
        nvim-lspconfig
        nvim-treesitter
        rose-pine
        vim-fugitive
        vim-sexp
      ])
      ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
        lua
        python
        bash
        json
        yaml
        nix
        vim
        vimdoc
      ]);
    extraConfig = ''
      lua  << CONFIG_END
      ${lib.fileContents ../../nvim/init.lua}
      CONFIG_END
    '';
    withRuby = false;
    withPython3 = false;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
      ".direnv"
      ".nvim.lua"
    ];
    settings = {
      user = {
        name = "Oli Solomons";
        email = "oli.solomons@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    extraConfig = ''
      set -g status off
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash.enable = true;

  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox service";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Restart = "on-failure";
    };
  };

  services.redshift = {
    enable = true;
    temperature = {
      day = 6500;
      night = 2150;
    };
    provider = "manual";
    latitude = 51.5;
    longitude = 0.1;
  };

  programs.home-manager.enable = true;
}
