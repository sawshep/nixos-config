{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configurations/elitebook-835-g7.nix
      ./modules/common.nix
      ./modules/desktop.nix
      ./modules/user.nix
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "elitebook-835-g7"; # Define your hostname.
  networking.firewall.enable = false;

  boot = {
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };

  # Just generate the host key for Agenix
  services.openssh = {
    enable = false;
    openFirewall = false;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = false;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.steam.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.fprintd = {
    enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
