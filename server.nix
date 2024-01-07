# Hardware agnostic server configuration

{ config, pkgs, ... }:

let authorizedKeys = import ./authorized_keys.nix; in
{
  age.secrets.user-password.file = ./secrets/user-password.age;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    passwordFile = config.age.secrets.user-password.path;
  };

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

  services.caddy = {
    enable = true;
    extraConfig = ''
      spaceheaterlab.net {
        root * /srv/www

	#redir /jellyfin /jellyfin/
	#reverse_proxy /jellyfin/* localhost:8096

	file_server
	encode gzip
      }
      #jellyseerr.spaceheaterlab.net {
      #  reverse_proxy localhost:5055
      #}
      radicale.spaceheaterlab.net {
        reverse_proxy localhost:5232
      }
    '';
  };

  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "localhost:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/srv/radicale/htpasswd";
        htpasswd_encryption = "bcrypt";
      };
    };
  };


  services.jellyfin.enable = false;
  services.jellyseerr.enable = false;
  services.prowlarr.enable = false;
  services.radarr.enable = false;
  services.sonarr.enable = false;

  services.openvpn.servers = {
    # This leaks DNS request. It's just for proxying
    mullvad = {
      config = ''
        client
        dev tun
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        verb 3
        remote-cert-tls server
        ping 10
        ping-restart 60
        sndbuf 524288
        rcvbuf 524288
        cipher AES-256-GCM
        tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384
        proto udp
        auth-user-pass /run/agenix/openvpn-mullvad-userpass
        ca /run/agenix/openvpn-mullvad-ca
        tun-ipv6
        script-security 2
        fast-io
        remote-random
        remote 91.90.44.11 1196 # no-osl-ovpn-001
        remote 91.90.44.15 1196 # no-osl-ovpn-005
        remote 91.90.44.16 1196 # no-osl-ovpn-006
        remote 194.127.199.114 1196 # no-svg-ovpn-001
        remote 91.90.44.18 1196 # no-osl-ovpn-008
        remote 91.90.44.12 1196 # no-osl-ovpn-002
        remote 91.90.44.13 1196 # no-osl-ovpn-003
        remote 91.90.44.17 1196 # no-osl-ovpn-007
        remote 194.127.199.145 1196 # no-svg-ovpn-002
        remote 91.90.44.14 1196 # no-osl-ovpn-004
        route-nopull
        route 10.0.0.0 255.0.0.0
        '';
    };
  };

  services.transmission = {
    enable = false;
    settings = {
      watch-dir-enabled = true;
      watch-dir = "/srv/Shares/Transmission/Torrents";
      incomplete-dir-enabled = true;
      incomplete-dir = "/srv/Shares/Transmission/Incomplete";
      download-dir = "/srv/Shares/Transmission/Complete";
    };
  };
  # Proxy transmission to split tunnel
  # LEAKS IP
  #systemd.services.transmission.environment.http_proxy = "socks5://10.8.0.1:1080";

  networking.firewall = {
    enable = true;
    # Block any traffic that Transmission does not tunnel. WIP.
    extraCommands = ''
      #iptables -A OUTPUT -m owner --uid-owner transmission -i \! tun0 -j REJECT
    '';
    allowedTCPPorts = [

      # Blocky
      53 # DNS

      # For Caddy
      80 # HTTP
      443 # HTTPS

    ];
  };
}
