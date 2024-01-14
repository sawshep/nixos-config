{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/firewall.nix
      ./modules/common.nix
      ./modules/user.nix
      ./modules/headless.nix
    ];

  networking.hostName = "changwang-cw56-58"; # Define your hostname.

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.xrdp.openFirewall = true;

  age.secrets.user-password.file = ./secrets/user-password.age;


  age.secrets.caddy-basicauth.file = ./secrets/caddy-basicauth.age;
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.age.secrets.caddy-basicauth.path;
  };

  services.caddy = {
    enable = true;
    extraConfig = ''
      spaceheaterlab.net {
          basicauth * {
            {$HTTP_BASIC_AUTH_USER} {$HTTP_BASIC_AUTH_PASSWORD}
        }

        root * /srv/www

        redir /octoprint /octoprint/
        reverse_proxy /octoprint/* 10.0.0.5:80 {
          header_up X-Scheme {scheme}
        }

        file_server
        encode gzip
      }
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


  #services.jellyfin.enable = false;
  #services.jellyseerr.enable = false;
  #services.prowlarr.enable = false;
  #services.radarr.enable = false;
  #services.sonarr.enable = false;

  #services.openvpn.servers = {
  #  # This leaks DNS request. It's just for proxying
  #  mullvad = {
  #    config = ''
  #      client
  #      dev tun
  #      resolv-retry infinite
  #      nobind
  #      persist-key
  #      persist-tun
  #      verb 3
  #      remote-cert-tls server
  #      ping 10
  #      ping-restart 60
  #      sndbuf 524288
  #      rcvbuf 524288
  #      cipher AES-256-GCM
  #      tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384
  #      proto udp
  #      auth-user-pass /run/agenix/openvpn-mullvad-userpass
  #      ca /run/agenix/openvpn-mullvad-ca
  #      tun-ipv6
  #      script-security 2
  #      fast-io
  #      remote-random
  #      remote 91.90.44.11 1196 # no-osl-ovpn-001
  #      remote 91.90.44.15 1196 # no-osl-ovpn-005
  #      remote 91.90.44.16 1196 # no-osl-ovpn-006
  #      remote 194.127.199.114 1196 # no-svg-ovpn-001
  #      remote 91.90.44.18 1196 # no-osl-ovpn-008
  #      remote 91.90.44.12 1196 # no-osl-ovpn-002
  #      remote 91.90.44.13 1196 # no-osl-ovpn-003
  #      remote 91.90.44.17 1196 # no-osl-ovpn-007
  #      remote 194.127.199.145 1196 # no-svg-ovpn-002
  #      remote 91.90.44.14 1196 # no-osl-ovpn-004
  #      route-nopull
  #      route 10.0.0.0 255.0.0.0
  #      '';
  #  };
  #};

  #services.transmission = {
  #  enable = false;
  #  settings = {
  #    watch-dir-enabled = true;
  #    watch-dir = "/srv/Shares/Transmission/Torrents";
  #    incomplete-dir-enabled = true;
  #    incomplete-dir = "/srv/Shares/Transmission/Incomplete";
  #    download-dir = "/srv/Shares/Transmission/Complete";
  #  };
  #};
  # Proxy transmission to split tunnel
  # LEAKS IP
  #systemd.services.transmission.environment.http_proxy = "socks5://10.8.0.1:1080";

  networking.firewall = {
    enable = true;
    # Block any traffic that Transmission does not tunnel. WIP.
    #extraCommands = ''
    #  #iptables -A OUTPUT -m owner --uid-owner transmission -i \! tun0 -j REJECT
    #'';
    allowedTCPPorts = [

      # Blocky
      53 # DNS

      # For Caddy
      80 # HTTP
      443 # HTTPS

    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
