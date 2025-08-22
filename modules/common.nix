{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports = [
    #./nix-alien.nix
    (import "${home-manager}/nixos")
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Pin to unstable
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  #age.secrets = {
  #  openvpn-mullvad-userpass = {
  #    file = ./secrets/openvpn-mullvad-userpass.age;
  #    owner = "openvpn";
  #  };
  #  openvpn-mullvad-ca = {
  #    file = ./secrets/openvpn-mullvad-ca.age;
  #    owner = "openvpn";
  #  };
  #};

  networking.networkmanager = {
     enable = true;
     dns = "default";
  };


  #networking.extraHosts = builtins.readFile (builtins.fetchurl { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"; });

  #services.resolved = {
  #  enable = true;
  #  dnssec = "true";
  #  domains = [ "~." ];
  #  fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  #  extraConfig = ''
  #    DNSOverTLS=yes
  #  '';
  #};


  # For accessing Samba shares
  services.gvfs.enable = true;

  services.usbmuxd.enable = true;

  # Enable CUPS to print documents.
  services.samba-wsdd.enable = true;
  services.printing = {
    enable = true;
    browsing = true;
    extraConf = ''
      BrowseLocalProtocols dnssd
      BrowseProtocols all
    '';
    drivers = with pkgs; [

      cups-filters
      cups-browsed
      brgenml1cupswrapper
      brgenml1lpr
      brlaser
      gutenprint
      gutenprintBin
      hplip
      postscript-lexmark
      samsung-unified-linux-driver
      splix

    ];
  };
  # Search for network printers
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  users.groups.plocate = { };

  virtualisation = {
    libvirtd.enable = true;
    libvirtd.qemu.swtpm.enable = true;

    docker = {
      enable = true;
      enableOnBoot = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };


  boot.supportedFilesystems = [ "ntfs" ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
  };

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
      HostName github.com
      User git
      IdentityFile ~/.ssh/github
  '';

  programs.bash.promptInit = ''
    if [ "$LOGNAME" = root ] || [ "`id -u`" -eq 0 ] ; then
      PS1='\[\033[01;31m\]\u@\h:\w \$\[\033[00m\] '
    else
      PS1='\u@\h:\w \$ '
    fi
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableLsColors = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 999999999;
    histFile = "$XDG_DATA_HOME/zsh/history";

    shellInit = ''
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
      autoload -Uz select-word-style
      select-word-style normal
      zstyle ':zle:*' word-style unspecified
      backward-kill-dir () {
        local WORDCHARS=$\{WORDCHARS/\/}
        zle backward-kill-word
        zle -f kill
      }
      zle -N backward-kill-dir
      bindkey '^[^?' backward-kill-dir
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;3C" forward-word
      bindkey "^[[1;3D" backward-word
    '';

    promptInit = ''
        PS1='%m:%~ %# '
    '';
  };

  #programs.gnupg.agent.pinentryPackage = "";
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

    (callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Compilation tools
    autoconf
    binutils
    gcc
    git
    m4
    gperf
    gitRepo
    curl
    procps
    glib
    gnumake
    ncurses5
    steam-run # Run alien executables

    # Filesystem programs
    exfatprogs # Debugging utils for exfat
    fuse3 # Virtual filesystem library
    ifuse # Mount iDevices
    extundelete # Recover deleted files from ext
    jmtpfs # MTP device filesystem
    e2fsprogs
    libimobiledevice # Detect iDevices
    samba # Connect to SMB shares
    safecopy # Data recovery tool
    ddrescue # Data recovery tool

    # Encryption utilities
    apg # Password generator
    age # Modern encryption tool
    rage # AGE in Rust
    gnupg # GNU privacy guard suite
    mokutil # Machine user key manager
    pinentry # Secure secret entry
    openssl
    cryptsetup

    # Hardware interfaces
    hdparm # Control drives
    lm_sensors # Query temperature sensors
    macchanger # Change MAC address
    pciutils # Query PCI busses
    usbutils # Query USB devices

    # Monitoring
    lsof # List open files
    htop # Process monitor
    iotop # I/O monitor
    powertop # Power usage stats

    # Nice-to-Haves
    magic-wormhole
    bc # Calculator
    dos2unix # Strip return carriages
    ed # For /REALLY/ dumb terminals
    ffmpeg # Audio/video conversion
    file # Tell what a file is
    jq # JSON parser
    killall # Kill process by name
    moreutils # Extention of coreutils
    plocate # Find files (quickly)
    rlwrap # Make programs play nice with arrow keys and keybinds
    screenfetch # System info
    tldr # Cheat-sheet command documentation
    tree # Display filetree
    units # Unit conversion
    unixtools.xxd # Hexdump
    util-linux # Useful linux utils

    # Network Tools
    inetutils # Common network clients and servers
    iptables # Custom granular routing
    networkmanager # Manages network connections
    nmap # Network mapper
    openvpn # OpenVPN 2 client
    #openvpn3 # OpenVPN 3 client
    wireguard-tools
    termshark # Wireshark TUI
    traceroute # Trace packet routing
    tshark # Wireshark CLI
    tunctl # Manage network tunnels
    wget # Web get
    zdns # DNS lookup utility

    podman-compose

    # Compression
    p7zip
    unrar
    unzip
    zip

    # Programming Languages
    powershell
    bun # Javascript runtime
    clojure # JVM-based Lisp
    #crystal # Compiled Ruby-like language
    ghc # Haskell compiler and interpreter
    openjdk # Java development kit and runtime environment
    php # HTML embedded scripting lanugage
    python3Full # All of Python
    racket # Dialect of Lisp
    ruby # The best language
    sbcl # Common Lisp
    sqlite # Structured query lanuage implementation

  ];
}
