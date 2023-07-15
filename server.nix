# Hardware agnostic server configuration

{ config, pkgs, ... }:

{
  users.users.admin = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ];
  };

  services.openssh = {
    enable = true;
    ports = [ 31415 ];
    openFirewall = true;
    settings = {
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 10;
  };

  services.caddy = {
    enable = true;
    extraConfig = ''
      spaceheaterlab.net {
        root * /srv/www

	redir /jellyfin /jellyfin/
	reverse_proxy /jellyfin/* localhost:8096

	redir /jellyseerr /jellyseerr/
	reverse_proxy /jellyseerr/* localhost:5055

	file_server
	encode gzip
      }
    '';
  };

  services.jellyfin.enable = true;
  services.transmission.enable = true;
  services.jellyseerr.enable = true;
  services.prowlarr.enable = true;
  services.radarr.enable = true;
  services.sonarr.enable = true;

  services.samba = {
    openFirewall = true;
    package = pkgs.sambaFull; # For printer support
    enable = true;
    enableNmbd = true;
    securityType = "user";
      #load printers = yes
      #printing = cups
      #printcap name = cups
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
      #printers = {
      #  path = "/var/spool/samba";
      #  public = "yes";
      #  browseable = "yes";
      #  "guest ok" = "yes";
      #  writeable = "no";
      #  printable = "yes";
      #  "create mode" = "0700";
      #};
      Jellyfin = {
        path = "/srv/Shares/Jellyfin";
	public = "yes";
        "guest only" = "yes";
        "guest ok" = "yes";
	writable = "yes";
        "create mask" = "777";
        browseable = "yes";
      }; 
    };
  };

  # Allow printing over network shares with Samba
  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];
  
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [

      5355 # LLMNR
      5357 # WSD
      22000 # Syncthing

    ];
    allowedUDPPorts = [

      21027 # Syncthing
      22000 # Syncthing

    ];
  };

}
