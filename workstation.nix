{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/desktop.nix
      ./modules/common.nix
      ./modules/user.nix
      ./modules/headless.nix
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
      # For Caddy -> Open WebUI
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

  services.ollama = {
    enable = true;
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0,1";
      OLLAMA_LLM_LIBRARY = "cuda_v11";
    };
    acceleration = "cuda";
  };

  services.caddy = {
    enable = true;
    virtualHosts."10.0.0.7" = {
        extraConfig = ''
          tls internal
          reverse_proxy http://localhost:8080
        '';
      };
    virtualHosts."ai.spaceheaterlab.net" = {
        extraConfig = ''
          tls internal
          reverse_proxy http://localhost:8080
        '';
      };
  };

  services.open-webui.enable = true;
  services.open-webui.openFirewall = true;

  services.hardware.openrgb = {
    enable = true;
    #package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
    #server = {
    #  port = 6742;
    #};
  };

  nixpkgs.config.cudaSupport = true;
  nix.settings = {
    substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
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

    cudaPackages.cuda_gdb
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cutensor
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcufile
    cudaPackages.libcurand
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    cudaPackages.nvidia_fs
    cudaPackages.saxpy


    exiftool
    ollama

    openrgb
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

  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
