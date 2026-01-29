{ pkgs, lib, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        {
          command =
            "--no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet";
        }
        { command = "--no-startup-id ${pkgs.pasystray}/bin/pasystray"; }
        { command = "--no-startup-id blueman-applet"; }
      ];
      keybindings = lib.mkOptionDefault {
        "${modifier}+Tab" = "focus right";
        "${modifier}+b" = "bar mode toggle";

        "${modifier}+x" = "mode power";
        "${modifier}+z" = "mode brightness";
        "${modifier}+ctrl+z" = "mode audio";
        "${modifier}+r" = "mode launch";

        # Focus
        "${modifier}+j" = "focus left";
        "${modifier}+k" = "focus down";
        "${modifier}+l" = "focus up";
        "${modifier}+semicolon" = "focus right";

        # Move
        "${modifier}+Shift+j" = "move left";
        "${modifier}+Shift+k" = "move down";
        "${modifier}+Shift+l" = "move up";
        "${modifier}+Shift+semicolon" = "move right";

        Print = "exec ${pkgs.flameshot}/bin/flameshot gui";
      };
      window.border = 1;
      window.hideEdgeBorders = "smart";
      fonts = {
        size = 0.0; # Hide titles
      };
      modes = {
        power = {
          s = "exec systemctl suspend, mode default";
          l = "exec loginctl lock-session, mode default";
          u = "exec systemctl poweroff";
          r = "exec systemctl reboot";
          h = "exec systemctl hibernate, mode default";
          "Shift+l" = "exec pkill -u $USER, mode default";

          Escape = "mode default";
        };
        brightness = let b = "${pkgs.brightnessctl}/bin/brightnessctl";
        in {
          "${modifier}+z" = "exec ${b} set 1, mode default";
          z = "exec ${b} set 1, mode default";
          q = "exec ${b} set 2%+";
          a = "exec ${b} set 2%- --min-value 1";

          Escape = "mode default";
        };
        audio = let
          pactl = opt: val:
            "exec ${pkgs.pulseaudio}/bin/pactl set-sink-${opt} @DEFAULT_SINK@ ${val}";
        in {
          q = pactl "volume" "+10%";
          a = pactl "volume" "-10%";
          z = pactl "mute" "0" + ", mode default";
          "shift+z" = pactl "mute" "1" + ", mode default";

          Escape = "mode default";
        };
        launch = {
          f = "exec firefox, mode default";
          t = "exec alacritty, mode default";
          v =
            "exec --no-startup-id obs --startvirtualcam --minimize-to-tray --safe-mode, mode default";
          "Shift+v" = "exec --no-startup-id pkill obs, mode default";
          c = "exec chromium, mode default";

          Escape = "mode default";
        };
      };
    };
  };

  services.flameshot = {
    enable = true;
    settings.General = {
      disabledTrayIcon = true;
      showStartupLaunchMessage = false;
    };
  };
}
