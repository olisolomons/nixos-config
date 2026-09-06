{ pkgs, ... }:

{
  # Enable XFCE Desktop Environment
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme.name = "Mint-Y";
        extraConfig = ''
          background = ${./Quadrasineaur.jpg}
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    python3
    xfce4-whiskermenu-plugin
    xfce4-pulseaudio-plugin
    xfce4-clipman-plugin
    volantes-cursors
    mint-y-icons
    mint-themes
    ibus
  ];

  # Home Manager user configuration block
  home-manager.users.annie = { config, ... }: {
    home.file."Desktop/IN.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=IN Document
      Comment=Open IN.odt in LibreOffice
      Exec=xdg-open "/home/annie/Dropbox/Documents/£/IN.odt"
      Icon=libreoffice-writer
      Terminal=false
      Categories=Office;
    '';

    home.activation.createDesktopShortcuts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      DESKTOP_FILE="$HOME/Desktop/Recipes.desktop"

      # 1. Remove any old store symlink
      $DRY_RUN_CMD rm -f "$DESKTOP_FILE"

      # 2. Write standard desktop shortcut directly into user home space
      $DRY_RUN_CMD cat << 'EOF' > "$DESKTOP_FILE"
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=Recipes
      Comment=Open Recipes folder in Thunar
      Exec=thunar "/home/annie/Dropbox/Recipes"
      Icon=${./recipes.xpm}
      Terminal=false
      Categories=Utility;
      EOF

      # 3. Give user write permissions (clears lock emblem)
      $DRY_RUN_CMD chmod 644 "$DESKTOP_FILE"
    '';

    systemd.user.services.xfce4-clipman = {
      Unit = {
        Description = "XFCE Clipboard Manager";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-clipman";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xfconf.settings = {
      xfce4-keyboard-shortcuts = {
        "commands/custom/<Primary><Alt>k" =
          "xfce4-terminal -e 'bash -c \"cd ~/Dropbox/Recipes; ./make.py; echo Press any key to exit.; read -n 1\"'";
        "commands/custom/Super_L" = "xfce4-popup-whiskermenu";
        # Ctrl first, then Super
        "xfwm4/custom/<Primary><Super>Left" = "tile_left_key";
        "xfwm4/custom/<Primary><Super>Right" = "tile_right_key";
        "xfwm4/custom/<Primary><Super>Up" = "maximize_window_key";

        # Super first, then Ctrl
        "xfwm4/custom/<Super><Primary>Left" = "tile_left_key";
        "xfwm4/custom/<Super><Primary>Right" = "tile_right_key";
        "xfwm4/custom/<Super><Primary>Up" = "maximize_window_key";
      };

      xsettings = {
        "Net/ThemeName" = "Mint-Y";
        "Net/IconThemeName" = "Mint-Y";
        "Gtk/CursorThemeName" = "volantes_light_cursors";
      };

      xfwm4 = {
        "general/theme" = "Mint-Y";
        "general/button_layout" = "O|HMC";
        "general/workspace_count" = 1;
        "general/tile_on_move" = true;
      };
      xfce4-desktop = {
        "desktop-icons/file-icons/show-home" = false;
        "desktop-icons/file-icons/show-filesystem" = false;
        "desktop-icons/file-icons/show-trash" = false;
        "desktop-icons/file-icons/show-removable" = false;
      };

      xfce4-panel = {
        "configver" = 2;
        "panels" = [ 1 ];

        # Panel Properties - Inserted IDs 2, 3, 4 after Whisker Menu (1)
        "panels/panel-1/position" = "p=10;x=0;y=0";
        "panels/panel-1/length" = 100;
        "panels/panel-1/position-locked" = true;
        "panels/panel-1/size" = 28;
        "panels/panel-1/autohide-behavior" = 0;
        "panels/panel-1/plugin-ids" = [
          1
          2
          3
          4
          6
          7
          8
          12
          13
          17
          15
        ];

        # Plugin 1: Whisker Menu
        "plugins/plugin-1" = "whiskermenu";
        "plugins/plugin-1/button-icon" = "start-here";
        "plugins/plugin-1/hover-switch-category" = true;
        "plugins/plugin-1/favorites-in-recent" = true;
        "plugins/plugin-1/position-search-alternate" = true;
        "plugins/plugin-1/position-categories-alternate" = true;
        "plugins/plugin-1/favorites" = [
          "firefox.desktop"
          "thunderbird.desktop"
          "pix.desktop"
          "org.gnome.Calculator.desktop"
          "mintinstall.desktop"
          "xfce4-taskmanager.desktop"
        ];
        "plugins/plugin-1/recent" = [
          "system-config-printer.desktop"
          "com.spotify.Client.desktop"
          "google-chrome.desktop"
          "firefox.desktop"
        ];

        # Plugin 2: Thunar Launcher
        "plugins/plugin-2" = "launcher";
        "plugins/plugin-2/items" = [ "thunar.desktop" ];

        # Plugin 3: Thunderbird Launcher
        "plugins/plugin-3" = "launcher";
        "plugins/plugin-3/items" = [ "thunderbird.desktop" ];

        # Plugin 4: Chromium Launcher
        "plugins/plugin-4" = "launcher";
        "plugins/plugin-4/items" = [ "chromium-browser.desktop" ];

        # Plugin 6: Tasklist
        "plugins/plugin-6" = "tasklist";
        "plugins/plugin-6/show-handle" = false;
        "plugins/plugin-6/grouping" = 1;
        "plugins/plugin-6/show-labels" = true;
        "plugins/plugin-6/flat-buttons" = false;
        "plugins/plugin-6/window-scrolling" = false;

        # Plugin 7: Separator
        "plugins/plugin-7" = "separator";
        "plugins/plugin-7/expand" = true;
        "plugins/plugin-7/style" = 0;

        # Plugin 8: Systray
        "plugins/plugin-8" = "systray";
        "plugins/plugin-8/show-frame" = false;
        "plugins/plugin-8/square-icons" = true;

        # Plugin 12: PulseAudio
        "plugins/plugin-12" = "pulseaudio";
        "plugins/plugin-12/enable-keyboard-shortcuts" = true;
        "plugins/plugin-12/show-notifications" = true;

        # Plugin 13: Clock
        "plugins/plugin-13" = "clock";
        "plugins/plugin-13/digital-layout" = 1;

        # Plugin 17: Actions
        "plugins/plugin-17" = "actions";
        "plugins/plugin-17/appearance" = 0;
        "plugins/plugin-17/ask-confirmation" = false;
        "plugins/plugin-17/items" = [
          "-lock-screen"
          "-switch-user"
          "-separator"
          "+suspend"
          "-hibernate"
          "-hybrid-sleep"
          "-separator"
          "+shutdown"
          "+restart"
          "-separator"
          "-logout"
          "-logout-dialog"
        ];

        # Plugin 15: Show Desktop
        "plugins/plugin-15" = "showdesktop";
      };
    };
  };
}
