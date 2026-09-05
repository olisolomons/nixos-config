{ pkgs, ... }:

{
  # Enable XFCE Desktop Environment
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };

  # System-wide packages required by themes/shortcuts
  environment.systemPackages = with pkgs; [
    volantes-cursors
    mint-y-icons
    ibus
  ];

  # Home Manager user configuration block
  home-manager.users.yourusername = {
    xfconf.settings = {
      xfce4-keyboard-shortcuts = {
        "commands/custom/<Primary><Alt>k" = "xfce4-terminal -e 'bash -c \"cd ~/Dropbox/Recipes; ./make.py; echo Press any key to exit.; read -n 1\"'";
        "commands/custom/Super_L" = "xfce4-popup-whiskermenu";
      };

      xsettings = {
        "Net/ThemeName" = "Mint-Y";
        "Gtk/CursorThemeName" = "volantes_light_cursors";
      };
    };
  };
}
