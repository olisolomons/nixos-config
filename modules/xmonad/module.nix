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

    services.network-manager-applet.enable = true;
    services.pasystray.enable = true;

    systemd.user.services.trayer = {
      Unit = {
        Description = "Trayer system tray";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = ''
          ${pkgs.trayer}/bin/trayer \
            --edge top \
            --align right \
            --widthtype request \
            --heighttype pixel \
            --height 17 \
            --padding 4 \
            --SetDockType true \
            --SetPartialStrut true \
            --expand true \
            --transparent true \
            --alpha 0 \
            --tint 0x5f5f5f
        '';
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.network-manager-applet.Unit.After = [ "trayer.service" ];
    systemd.user.services.pasystray.Unit.After = [ "trayer.service" ];
  };
}
