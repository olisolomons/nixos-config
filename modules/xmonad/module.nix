{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  xmonadPkg = inputs.xmonad-config.packages.${system}.default;
in
{
  services.xserver = {
    enable = true;
    windowManager.session = [
      {
        name = "xmonad";
        manage = "window";
        start = ''
          ${xmonadPkg}/bin/xmonad-x86_64-linux &
          waitPID=$!
        '';
      }
    ];
  };
  services.displayManager.defaultSession = "none+xmonad";

  environment.systemPackages = with pkgs; [
    xmonadPkg
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

      ${pkgs.networkmanagerapplet}/bin/nm-applet &
      ${pkgs.pasystray}/bin/pasystray &
    '';
    xsession.enable = true;
  };
}
