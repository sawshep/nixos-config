{ config, pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Pin to unstable
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  nix.settings.auto-optimise-store = true;

  networking.networkmanager.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  environment.variables.EDITOR = "nvim";

  programs.ssh.extraConfig = ''
    Host *
      ServerAliveInterval 30
      ServerAliveCountMax 6
    Host github.com
      IdentityFile ~/.ssh/github
      IdentitiesOnly yes
  '';

  programs.bash.promptInit = ''
    if [ "$LOGNAME" = root ] || [ "`id -u`" -eq 0 ] ; then
      PS1='\[\033[01;31m\]\u@\h:\w \$\[\033[00m\] '
    else
      PS1='\u@\h:\w \$ '
    fi
  '';

  environment.shellAliases = {
    ll = "ls -l";
    la = "ls -l --almost-all";
    ip = "ip --color";
    untar = "tar -xafv";
    xxz = "xz -T0 -9e -v";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  environment.systemPackages = with pkgs; [

    apg
    file
    git
    glib
    gnupg
    htop
    inetutils
    iotop
    killall
    lm_sensors
    lsof
    macchanger
    moreutils
    networkmanager
    p7zip
    pciutils
    rlwrap
    tldr
    tree
    unzip
    wget

  ];
}
