{ pkgs, lib, unstable, ... }:

let
  i3ModeExtensionUuid = "i3mode@nixos.local";
  i3ModeExtension = pkgs.stdenv.mkDerivation {
    name = "gnome-extension-i3-mode";
    src = ../../home-manager/i3-mode-extension;
    nativeBuildInputs = [ pkgs.glib ];
    installPhase = ''
      export EXT_DIR=$out/share/gnome-shell/extensions/${i3ModeExtensionUuid}
      mkdir -p $EXT_DIR
      cp -r * $EXT_DIR
      glib-compile-schemas $EXT_DIR/schemas/
    '';
  };
in {
  imports = [ ../../modules/home-manager/common.nix ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    zoom-us
    unstable.omnissa-horizon-client
    pkgs.gnomeExtensions.appindicator
    i3ModeExtension
    slack
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "$GSETTINGS_SCHEMA_DIR:$XDG_DATA_DIRS";
  };

  programs.chromium.enable = true;

  services.dunst.enable = true;

  dconf.settings = {
    "org/gnome/desktop/input-sources" = { xkb-options = [ "ctrl:nocaps" ]; };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" i3ModeExtensionUuid ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
      switch-windows = [ ];
      switch-windows-backward = [ ];
      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      logout = [ ];
    };
    "org/gnome/shell/extensions/i3mode" = {
      launch-mode = [ "<Super>r" ];
      power-mode = [ "<Super>x" ];
    };
    "org/gnome/desktop/session" = { idle-delay = 0; };
    "org/gnome/desktop/interface" = { show-battery-percentage = true; };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-battery-timeout = 300;
      sleep-inactive-ac-timeout = 1800;
      idle-dim = false;
    };
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.6; };
  };
}
