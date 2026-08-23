{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = "adele";

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.lightdm = {
      enable = true;
      background = ../../bg.jpg;
      greeters.mini = {
        enable = true;
        user = "oli";
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = left
          [greeter-theme]
          background-image-size = 10px, 10px
        '';
      };
    };
    displayManager.sessionCommands = ''
      xset -dpms
      xset s off
      ${pkgs.lightlocker}/bin/light-locker --no-lock-on-lid --lock-after-screensaver=0 &
    '';
  };
  services.displayManager.defaultSession = "none+i3";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.dconf.enable = true;

  services.teamviewer.enable = true;
  systemd.services.teamviewerd.wantedBy = lib.mkForce [];

  system.stateVersion = "24.05";
}
