{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = "dell-xps";

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  hardware.ipu6.enable = true;
  hardware.ipu6.platform = "ipu6ep";
  hardware.firmware = [ pkgs.ivsc-firmware ];
  hardware.sensor.iio.enable = true;
  services.pipewire.wireplumber.extraConfig."10-ipu6-libcamera" = {
    "monitor.libcamera" = "enabled";
    "monitor.v4l2" = "disabled";
  };

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=20 card_label="Zoom-Camera" exclusive_caps=1
  '';

  environment.pathsToLink = [ "/libexec" ];
  environment.systemPackages = with pkgs; [ git v4l-utils obs-studio gnomeExtensions.appindicator ];

  programs.dconf.enable = true;

  system.stateVersion = "24.05";
}
