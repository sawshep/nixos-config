# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/laptop.nix
      ./common.nix
      ./user.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "elitebook-835-g7"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  #powerManagement.powertop.enable = true;

  programs.steam.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [

      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      cnijfilter2
      gutenprint
      gutenprintBin
      hplip
      postscript-lexmark
      samsung-unified-linux-driver
      splix

    ];
  };
  # Search for network printers
  services.avahi.enable = true;
  services.avahi.openFirewall = true;

  services.tor.enable = true;
  services.tor.client.enable = true;

  #virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "me" ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [

    extundelete
    jq
    libticables2
    libticalcs2
    libticonv
    libtifiles2
    micropython
    pico-sdk
    powertop
    sqlite
    steam-run
    unixtools.xxd
    ventoy-bin
    wineWowPackages.stable
    winetricks

    aircrack-ng
    cudaPackages.cudatoolkit
    exiftool
    gobuster
    hashcat
    hcxtools
    john
    traceroute
    wireshark

    hunspell
    hunspellDicts.en-us-large
    libbs2b
    libebur128
    libsndfile
    tbb

    binwalk
    ddrescue
    foremost
    heimdall
    safecopy

    python3Full
    ruby_3_1
    sbcl
  ];


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

