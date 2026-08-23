{
  pkgs,
  lib,
  unstable,
  ...
}:

{
  home.packages = with pkgs; [
    xclip
    alacritty
    jq
    ripgrep
    tree
    gnumake
    nsxiv
    pinta
    zathura
    ffmpeg
    nil
    nixfmt
    (writeShellScriptBin "nrs" ''
      #!/usr/bin/env bash
      cd $HOME/src/nixos-config
      sudo nixos-rebuild --flake .#$(hostname) switch "$@"
    '')
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = unstable.neovim-unwrapped;
    plugins =
      (with unstable.vimPlugins; [
        telescope-nvim
        telescope-ui-select-nvim
        nvim-lspconfig
        nvim-treesitter
        rose-pine
        vim-fugitive
        vim-sexp
        conjure
      ])
      ++ (with unstable.vimPlugins.nvim-treesitter-parsers; [
        lua
        python
        java
        clojure
        haskell
        bash
        json
        yaml
        go
        nix
        vim
        vimdoc
        rust
      ]);
    extraConfig = ''
      lua  << CONFIG_END
      ${lib.fileContents ../../nvim/init.lua}
      CONFIG_END
    '';
  };

  programs.firefox =
    let
      lock-false = {
        Value = false;
        Status = "locked";
      };
      lock-true = {
        Value = true;
        Status = "locked";
      };
    in
    {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisablePocket = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
      };
      profiles.profile_0 = {
        id = 0;
        name = "profile_0";
        isDefault = true;
        settings = {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.search.suggest.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          "browser.urlbar.suggest.searches" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.startup.page" = 3;
          "browser.newtabpage.enabled" = "false";
          "browser.aboutConfig.showWarning" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "media.videocontrols.picture-in-picture.enabled" = false;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
        ];
      };
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

  services.caffeine.enable = true;

  programs.home-manager.enable = true;
}
