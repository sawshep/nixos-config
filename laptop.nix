{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/elitebook-835-g7.nix
      ./modules/common.nix
      ./modules/user.nix
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "elitebook-835-g7"; # Define your hostname.
  networking.firewall.enable = false;

  # Just generate the host key for Agenix
  services.openssh = {
    enable = true;
    openFirewall = false;
    hostKeys = [
      {
         path = "/etc/ssh/ssh_host_ed25519_key";
         type = "ed25519";
      }
    ];
  };

  programs.steam.enable = true;

  # Search for network printers
  services.avahi.enable = true;
  services.avahi.openFirewall = true;

  services.tor.enable = true;
  services.tor.client.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Disable = "Headset";
    };
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [

    wireguard-tools
    wireguard-go

    libticables2
    libticalcs2
    libticonv
    libtifiles2
    micropython
    pico-sdk
    ventoy-bin
    wineWowPackages.stable

    cudaPackages.cudatoolkit
    exiftool
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
  system.stateVersion = "22.05"; # Did you read the comment?

}

