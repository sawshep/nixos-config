# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./common.nix
      <home-manager/nixos>
    ];


  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev"; # or "nodev" for efi only
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # FILESYSTEMS

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];


  networking.hostName = "co";

  services.openssh.enable = true;
  services.tor.enable = true;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ]; # HP printer driver
  };

  virtualisation = {
    virtualbox.host.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  users.extraGroups.vboxusers.members = [ "me" ];

  hardware.opengl.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    # For dual display configuration
    screenSection = ''
      Option "metamodes" "DP-2: 3840x2160_144 +0+0, DP-0: 1920x1080_60_0 +3840+120 {rotation=left}"
    '';

    displayManager.defaultSession = "xfce";
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  sound.enable = true;
  services.pipewire = {
    enable = true;
    media-session.enable = true;
    wireplumber.enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  }; 

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  users.groups.plocate = { };

  environment.systemPackages = with pkgs; [

    apg
    binutils
    extundelete
    gcc
    gnumake
    samba
    gnupg
    home-manager
    jq
    p7zip
    plocate
    rlwrap
    sqlite
    tldr
    unixtools.xxd
    unrar
    fuse3
    unzip
    zip

    aircrack-ng
    cudaPackages.cudatoolkit
    exiftool
    gobuster
    hashcat
    john
    nmap
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
    hdparm
    heimdall
    safecopy

    python3Full
    ruby_3_1
    sbcl
  ];

  # For accessing Samba shares
  services.gvfs.enable = true;

  # Must be enabled systemwide to work, unfortunately
  programs.steam.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
