{ pkgs, lib, ... }:

{
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
    xclip
    alacritty

    jq
    ripgrep
    tree
    gnumake
    unzip
    zip

    (writeShellScriptBin "nrs" ''
      sudo nixos-rebuild switch -I nixos-config=$HOME/.config/home-manager/configuration.nix
    '')
    prismlauncher
    jdk21 # for prismlauncher

    nsxiv
    pinta
    zathura
    vlc

    ffmpeg
    nil # nix language server
    nixfmt-classic
    caffeine-ng # for command-line usage, see service below
  ];

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

  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        {
          command =
            "--no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet";
        }
        { command = "--no-startup-id ${pkgs.pasystray}/bin/pasystray"; }
      ];
      keybindings = lib.mkOptionDefault {
        "${modifier}+Tab" = "focus right";
        "${modifier}+b" = "bar mode toggle";

        "${modifier}+x" = "mode power";
        "${modifier}+z" = "mode brightness";
        "${modifier}+ctrl+z" = "mode audio";
        "${modifier}+r" = "mode launch";

        Print = "exec ${pkgs.flameshot}/bin/flameshot gui";
      };
      window.border = 1;
      window.hideEdgeBorders = "smart";
      fonts = {
        size = 0.0; # Hide titles
      };
      modes = {
        power = {
          s = "exec systemctl suspend, mode default";
          l = "exec loginctl lock-session, mode default";
          u = "exec systemctl poweroff";
          r = "exec systemctl reboot";
          h = "exec systemctl hibernate, mode default";
          "Shift+l" = "exec pkill -u $USER, mode default";

          Escape = "mode default";
        };
        brightness = let b = "${pkgs.brightnessctl}/bin/brightnessctl";
        in {
          "${modifier}+z" = "exec ${b} set 1, mode default";
          z = "exec ${b} set 1, mode default";
          q = "exec ${b} set 2%+";
          a = "exec ${b} set 2%- --min-value 1";

          Escape = "mode default";
        };
        audio = let
          pactl = opt: val:
            "exec ${pkgs.pulseaudio}/bin/pactl set-sink-${opt} @DEFAULT_SINK@ ${val}";
        in {
          q = pactl "volume" "+10%";
          a = pactl "volume" "-10%";
          z = pactl "mute" "0" + ", mode default";
          "shift+z" = pactl "mute" "1" + ", mode default";

          Escape = "mode default";
        };
        launch = {
          f = "exec firefox, mode default";
          t = "exec alacritty, mode default";

          Escape = "mode default";
        };
      };
    };
    # start on workspace 1
    extraConfig = "exec i3-msg workspace 1";
  };

  services.flameshot = {
    enable = true;
    settings.General = {
      disabledTrayIcon = true;
      showStartupLaunchMessage = false;
    };
  };

  programs.firefox = let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
    nur = import (builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
      url =
        "https://github.com/nix-community/NUR/archive/e8f2bc12692938b61f559d946204c4caceed8af9.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "18yx1bj9d4y70c6ff0101qprnwfq1r74b8705c9ibvq1vnav5a50";
    }) { inherit pkgs; };
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
              "media.videocontrols.picture-in-picture.enabled" = false;
            };
          extensions.packages = with nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
          ];
        };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = (with pkgs.vimPlugins; [
      telescope-nvim
      telescope-ui-select-nvim
      nvim-lspconfig
      nvim-treesitter
      rose-pine
      vim-fugitive
      vim-sexp
      conjure
    ]) ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
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
    ]);
    extraConfig = ''
      lua  << CONFIG_END
      ${lib.fileContents ./nvim/init.lua}
      CONFIG_END
    '';
  };

  programs.git = {
    enable = true;
    userName = "Oli Solomons";
    userEmail = "oli.solomons@gmail.com";
    ignores = [ ".envrc" ".direnv" ".nvim.lua" ];
    extraConfig = { init.defaultBranch = "main"; };
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

  services.keybase.enable = true;
  services.caffeine.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
