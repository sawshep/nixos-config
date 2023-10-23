{ config, pkgs, ... }:

{
  imports = [
    ./nix-alien.nix
    <home-manager/nixos>
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Pin to unstable
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  nix.settings.auto-optimise-store = true;

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets = {
    openvpn-mullvad-userpass = {
      file = ./secrets/openvpn-mullvad-userpass.age;
      owner = "openvpn";
    };
    openvpn-mullvad-ca = {
      file = ./secrets/openvpn-mullvad-ca.age;
      owner = "openvpn";
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "none"; # We use Blocky instead
  };
  networking.nameservers = [
    "localhost"
    "1.1.1.1"
    "1.0.0.1"
  ];

  services.blocky = {
    enable = true;
    settings = {
      upstream.default = [
        # Cloudflare DoH
        "https://one.one.one.one/dns-query"
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      #Enable Blocking of certian domains.
      blocking = {
        blackLists = {
          #Adblocking
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };


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
  users.extraGroups.vboxusers.members = [ "me" ];

  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    libvirtd.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
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

    (callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Compilation tools
    autoconf
    binutils
    gcc
    git
    glib
    gnumake
    steam-run # Run alien executables

    # Filesystem programs
    exfatprogs # Debugging utils for exfat
    fuse3 # Virtual filesystem library
    ifuse # Mount iDevices
    extundelete # Recover deleted files from ext
    jmtpfs # MTP device filesystem
    libimobiledevice # Detect iDevices
    samba # Connect to SMB shares
    safecopy # Data recovery tool
    ddrescue # Data recovery tool
    pmount # Mount removable devices as a user

    # Encryption utilities
    apg # Password generator
    age # Modern encryption tool
    rage # AGE in Rust
    gnupg # GNU privacy guard suite
    mokutil # Machine user key manager
    pinentry # Secure secret entry

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
    bc # Calculator
    dict # Dictionary
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
    openvpn3 # OpenVPN 3 client
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
    bun # Javascript runtime
    clojure # JVM-based Lisp
    crystal # Compiled Ruby-like language
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
