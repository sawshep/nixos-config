# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  users.users.admin = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ];
  };

  #networking.nat = {
  #  enable = true;
  #  internalInterfaces = ["ve-+"];
  #  externalInterface = "eno1";
  #  enableIPv6 = true;
  #};

  #systemd.services.vaultwarden = {
  #  description = "Vaultwarden Podman Container";
  #  requires = [ "podman.service" ];
  #  after = [ "podman.service" ];

  #  serviceConfig = {
  #    Type = "simple";
  #    ExecStartPre = ''
  #      ${pkgs.podman}/bin/podman pull vaultwarden/server
  #      ${pkgs.podman}/bin/podman stop vaultwarden || true
  #      ${pkgs.podman}/bin/podman rm vaultwarden || true
  #    '';
  #    ExecStart = ''
  #      ${pkgs.podman}/bin/podman run --name vaultwarden \
  #        -p 8000:80 \
  #        -p 3012:3012 \
  #        -v /var/lib/vaultwarden:/data \
  #        --restart=always \
  #        vaultwarden/server
  #    '';
  #    ExecStop = "${pkgs.podman}/bin/podman stop vaultwarden";
  #    ExecReload = "${pkgs.podman}/bin/podman restart vaultwarden";
  #    TimeoutStartSec = "5m";
  #    KillMode = "mixed";
  #  };
  #};

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    ports = [ 31415 ];
  };

  services.fail2ban = {
    enable = true;
    maxretry = 10;
  };

  services.jellyfin.enable = true;

  services.samba = {
    enable = false;
    enableNmbd = true;
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
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [

      22000 # Syncthing
      31415 # SSH

    ];
    allowedUDPPorts = [

      21027 # Syncthing
      22000

    ];
  };

}
