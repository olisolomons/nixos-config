{ pkgs, lib, ... }:

{
  home.stateVersion = "24.05";

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
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
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

  programs.home-manager.enable = true;
}
