{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/common.nix
    ../../home-manager/i3.nix
  ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    unzip
    zip
    claude-code
  ];
  programs.thunderbird = {
    enable = true;
    profiles = { };
  };
}
