{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./xfce.nix
  ];

  networking.hostName = "annie";

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.dconf.enable = true;

  system.stateVersion = "24.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  # system froze on wake up - try s2idle instead of deep
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # printing
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  users.users.annie = {
    isNormalUser = true;
    description = "Annie";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services.snapserver = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        bind_to_address = "0.0.0.0";
      };
      tcp-control = {
        enabled = true;
        port = 1705;
        bind_to_address = "0.0.0.0";
      };
      http = {
        enabled = true;
        port = 1780;
        bind_to_address = "0.0.0.0";
      };
      stream = {
        source = "pipe:///run/snapserver/pipewire?name=DesktopAudio&sampleformat=48000:16:2&codec=pcm";
      };
    };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  # Load module-pipe-sink to create a virtual output device named "Snapcast"
  systemd.user.services.snapcast-sink = {
    wantedBy = [ "default.target" ];
    wants = [ "pipewire.service" ];
    after = [ "pipewire.service" ];
    path = with pkgs; [
      pulseaudio
      systemd
      coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "2s";
    };
    script = ''
      # Wait until system-level snapserver is active
      until systemctl is-active --quiet snapserver.service; do
        sleep 0.5
      done

      # Ensure the FIFO exists
      while [ ! -p /run/snapserver/pipewire ]; do
        sleep 0.5
      done

      pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000 channels=2
    '';
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      1704
      1705
      1780
      4953
    ];
    allowedUDPPorts = [ 5353 ]; # mDNS / Avahi discovery
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
