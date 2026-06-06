{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../home-manager/i3.nix
  ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    prismlauncher
    jdk21
    caffeine-ng
    unzip
    zip
    claude-code
  ];

  services.keybase.enable = true;
}
