{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
  ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    unzip
    zip
    claude-code
  ];

  services.udiskie = {
    enable = true;
    tray = "auto"; # Adds a tray icon in polybar/i3bar to unmount drives safely
  };
}
