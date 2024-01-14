{ config, pkgs, ... }:

let
  authorizedKeys = import ./authorized_keys.nix;
in
{
  age.secrets.user-password.file = ../secrets/user-password.age;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    hashedPasswordFile = config.age.secrets.user-password.path;
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
}
