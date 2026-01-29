{ pkgs, lib, unstable, ... }:
let
  i3ModeExtensionUuid = "i3mode@nixos.local";

  i3ModeExtension = pkgs.stdenv.mkDerivation {
    name = "gnome-extension-i3-mode";
    src = ./i3-mode-extension;

    # Add glib to build inputs to get the compiler
    nativeBuildInputs = [ pkgs.glib ];

    installPhase = ''
      # Define the target directory
      export EXT_DIR=$out/share/gnome-shell/extensions/${i3ModeExtensionUuid}
      mkdir -p $EXT_DIR

      # Copy all files
      cp -r * $EXT_DIR

      # Compile the schemas inside the output directory
      glib-compile-schemas $EXT_DIR/schemas/ '';
  };
in {
  imports = [ ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "oli";
  home.homeDirectory = "/home/oli";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    claude-code
    xclip
    alacritty
    jq
    ripgrep
    tree
    gnumake
    nsxiv
    pinta
    zathura
    vlc
    ffmpeg
    nil # nix language server
    nixfmt-classic
    zoom-us
    unstable.omnissa-horizon-client
    pkgs.gnomeExtensions.appindicator
    i3ModeExtension
    slack
  ];
  home.sessionVariables = {
    XDG_DATA_DIRS = "$GSETTINGS_SCHEMA_DIR:$XDG_DATA_DIRS";
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.chromium.enable = true;
  programs.firefox = let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
  in {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;
    };

    # ---- PROFILES ----
    # Switch profiles via about:profiles page.
    # For options that are available in Home-Manager see
    # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.profiles
    profiles = {
      profile_0 =
        { # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
          id = 0; # 0 is the default profile; see also option "isDefault"
          name = "profile_0"; # name as listed in about:profiles
          isDefault = true; # can be omitted; true if profile ID is 0
          settings =
            { # specify profile-specific preferences here; check about:config for options
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
              "browser.newtabpage.activity-stream.feeds.section.topstories" =
                lock-false;
              "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includePocket" =
                lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" =
                lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeDownloads" =
                lock-false;
              "browser.newtabpage.activity-stream.section.highlights.includeVisited" =
                lock-false;
              "browser.newtabpage.activity-stream.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.system.showSponsored" =
                lock-false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" =
                lock-false;
              "browser.newtabpage.activity-stream.feeds.section.highlights" =
                false;
              "browser.startup.homepage" = "about:blank";
              "browser.startup.page" = 3; # reopen tabs from last session
              "browser.newtabpage.enabled" = "false";
              "browser.aboutConfig.showWarning" = false;
              "browser.toolbars.bookmarks.visibility" = "never";
            };
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
          ];
        };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = unstable.neovim-unwrapped;
    plugins = (with unstable.vimPlugins; [
      telescope-nvim
      telescope-ui-select-nvim
      nvim-lspconfig
      nvim-treesitter
      rose-pine
      vim-fugitive
      vim-sexp
      conjure
    ]) ++ (with unstable.vimPlugins.nvim-treesitter-parsers; [
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
      ${lib.fileContents ./nvim/init.lua}
      CONFIG_END
    '';
  };

  programs.git = {
    enable = true;
    ignores = [ ".envrc" ".direnv" ".nvim.lua" ];
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
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.bash.enable = true;

  services.dunst.enable = true;
  services.caffeine.enable = true;

  dconf.settings = {
    "org/gnome/desktop/input-sources" = { xkb-options = [ "ctrl:nocaps" ]; };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      # Add the UUID of the extension to the enabled list
      enabled-extensions =
        [ "appindicatorsupport@rgcjonas.gmail.com" i3ModeExtensionUuid ];
    };
    # Modify existing window manager bindings
    # --- 1. DISABLE & REMAP BUILT-IN KEYS ---
    "org/gnome/desktop/wm/keybindings" = {
      # Remove Alt+Tab, Keep Super+Tab
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
      # Completely disable Alt+Tab variants
      switch-windows = [ ];
      switch-windows-backward = [ ];

      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      # Disable the default Logout (Ctrl+Alt+Del)
      logout = [ ];
    };

    "org/gnome/shell/extensions/i3mode" = {
      launch-mode = [ "<Super>r" ];
      power-mode = [ "<Super>x" ];
    };

    # screen blank
    "org/gnome/desktop/session" = { idle-delay = 0; };
    "org/gnome/desktop/interface" = { show-battery-percentage = true; };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-battery-timeout = 300;
      sleep-inactive-ac-timeout = 1800;
      idle-dim = false;
    };
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.6; };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
