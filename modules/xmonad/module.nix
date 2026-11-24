{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # --- NixOS system layer ---
  programs.brightnessctl.enable = true;

  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      package = inputs.xmonad-config.packages.${system}.default;
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    pulseaudio # provides pactl
    xmobar
    trayer
    dmenu
    flameshot
    playerctl
  ];

  # --- Home Manager layer for oli ---
  home-manager.users.oli = {
    xdg.configFile."xmobar/xmobarrc".source = ./xmobarrc;

    xsession.initExtra = ''
      ${pkgs.trayer}/bin/trayer \
        --edge top \
        --align right \
        --widthtype request \
        --padding 6 \
        --SetDockType true \
        --SetPartialStrut true \
        --expand true \
        --transparent true \
        --alpha 0 \
        --height 20 &
    '';
    xsession.enable = true;
  };
}
