{ config, pkgs, ... }:

{
  imports = [
    ./nix-alien.nix
    "${builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz"}/modules/sops" # Sops
    <home-manager/nixos>
  ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Pin to unstable
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  nix.settings.auto-optimise-store = true;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  # For accessing Samba shares
  services.gvfs.enable = true;

  services.usbmuxd.enable = true;

  # Enable CUPS to print documents.
  services.samba-wsdd.enable = true;
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

  users.groups.plocate = { };

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

  programs.gnupg.agent.pinentryFlavor = "tty";
  programs.gnupg.agent.enable = true;

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

    autoconf
    binutils
    gcc
    git
    glib
    gnumake

    exfatprogs
    fuse3
    ifuse
    jmtpfs
    libimobiledevice
    samba

    apg
    gnupg
    mokutil
    pinentry

    hdparm
    lm_sensors
    macchanger
    pciutils
    usbutils

    bc
    file
    htop
    iotop
    killall
    lsof
    moreutils
    nmap
    plocate
    pmount
    rlwrap
    tldr
    tree
    wget

    ffmpeg
    inetutils
    networkmanager
    podman-compose

    p7zip
    unrar
    unzip
    zip

  ];
}
