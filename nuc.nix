# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/nuc.nix
      ./common.nix
      <home-manager/nixos>
    ];

  networking.hostName = "nuc";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  #virtualisation.podman = {
  #  enable = true;
  #  dockerCompat = true;
  #  #defaultNetwork.dnsname.enable = true; # So containers can communicte
  #};

  #networking.nat = {
  #  enable = true;
  #  internalInterfaces = ["ve-+"];
  #  externalInterface = "eno1";
  #  enableIPv6 = true;
  #};

  containers.vaultwarden = {
    autoStart = true;
    #privateNetwork = true;
    #hostAddress = "192.168.100.10";
    #localAddress = "192.168.100.11";
    #hostAddress6 = "fc00::1";
    #localAddress6 = "fc00::2";
    config = { config, pkgs, ... }: {

      system.stateVersion = "22.05";

      environment.systemPackages = with pkgs; [
        vaultwarden
      ];

      users.users.vaultwarden = {
        isNormalUser = true;
      };


      systemd.services.vaultwarden = {
        #wantedby = [ "multi-user.target" ];
	after = [ "network.target" ];
	#description = [ "Vaultwarden password manager" ];
	serviceConfig = {
	  Type = "simple";
	  User = "vaultwarden";
	  WorkingDirectory = "/home/vaultwarden";
	  RuntimeDirectory = "data";
	  RuntimeDirectoryMode = "0750";
	  Environment = "\"WEB_VAULT_ENABLED=false\"";
	  ExecStart = "vaultwarden";
	};
      };

      networking.firewall = {
        enable = true;
	allowedTCPPorts = [ 8000 ];
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.jellyfin.enable = true;

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Jellyfin Samba %v Share
      netbios name = jellyfin
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      encrypt passwords = true
      invalid users = root
    '';
    shares = {
      Jellyfin = {
        path = "/srv/Shares/Jellyfin";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        #"force user" = "username";
        #"force group" = "groupname";
      }; 
    };
  };
  

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
