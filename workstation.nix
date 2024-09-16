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

  networking.hostName = "codebreaker"; # Define your hostname.

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
  users.extraGroups.vboxusers.members = [ "me" ];

  environment.systemPackages = with pkgs; [

    cudaPackages.cudatoolkit
    #libGLU libGL
    #linuxPackages.nvidia_x11
    #xorg.libXi xorg.libXmu freeglut
    #xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib

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
