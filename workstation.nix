{ config, pkgs, ... }:

let
  lmstudio-nix = builtins.fetchTarball "https://github.com/Daaboulex/lmstudio-nix/archive/main.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/desktop.nix
      ./modules/common.nix
      ./modules/user.nix
      ./modules/headless.nix
      "${lmstudio-nix}/nixos-module.nix"
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  nixpkgs.config.nvidia.acceptLicense = true;

  networking = {
    useDHCP = false;
    defaultGateway = "10.0.0.1";
    interfaces.wlp8s0.ipv4.addresses = [
      { address = "10.0.0.7"; prefixLength = 24; }
    ];
    hostName = "codebreaker"; # Define your hostname.

    hosts = {
      "10.0.0.5" = ["radicale.spaceheaterlab.net"];
      "10.0.0.6" = ["lab.cyberhawks.org"];
      "10.0.0.7" = ["ai.spaceheaterlab.net"];
    };

    firewall = {
      enable = true;
      # For Caddy -> LM Studio
      allowedTCPPorts = [ 80 443 ];
    };
  };

  services.syncthing.openDefaultPorts = true;

  # Antivirus
  #services.clamav = {
  #  daemon.enable = true;
  #  updater.enable = true;
  #  scanner.enable = true;
  #  # Provides extra signatures
  #  fangfrisch.enable = true;
  #};

  #services.lmstudio = {
  #  enable = true;
  #  port = 1234;          # API port (default: 1234)
  #  openFirewall = false;  # Open firewall for API port
  #  dataDir = "/var/lib/lmstudio";  # Model storage directory
  #};

  services.caddy = {
    enable = true;
    virtualHosts."10.0.0.7" = {
        extraConfig = ''
          tls internal
          reverse_proxy http://localhost:1234
        '';
      };
    virtualHosts."ai.sawyers.cloud" = {
        extraConfig = ''
          tls internal
          reverse_proxy http://localhost:1234
        '';
      };
  };

  nixpkgs.config.cudaSupport = false;
  nix.settings = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://cache.flox.dev"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
  };


  hardware.hackrf.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 31415 ];
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 10;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.xrdp.openFirewall = true;

  #virtualisation.virtualbox.host.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  users.extraGroups.vboxusers.members = [ "me" ];

  services.i2pd.proto.i2cp.enable = true;
  users.extraGroups.i2c.members = [ "me" ];

  services.teamviewer.enable = true;

  environment.systemPackages = with pkgs; [

    teamviewer
    clamtk

    lmstudio

    exiftool

    i2c-tools
    liquidctl

    python311Packages.capstone
    python311Packages.pefile
    python311Packages.pycryptodome
    python311Packages.yara-python

    libbs2b
    libebur128
    libsndfile
    tbb

  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
