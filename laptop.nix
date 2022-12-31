# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configurations/laptop.nix
      ./common.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "elitebook-835-g7"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ]; # HP printer driver
  };

  #virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "me" ];

  services.xserver = {
    enable = true;
    #videoDrivers = [ "" ];
    exportConfiguration = true;

    displayManager.defaultSession = "xfce";
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  services.pipewire = {
    enable = true;
    media-session.enable = true;
    wireplumber.enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  }; 

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "pulse" "jackaudio" "audio" "wheel" "networkmanager" ];
  };

  users.groups.plocate = { };

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [

    binutils
    extundelete
    fuse3
    gcc
    gnumake
    jq
    mokutil
    plocate
    podman-compose
    samba
    sqlite
    unixtools.xxd
    unrar
    ventoy-bin
    wineWowPackages.stable
    winetricks

    aircrack-ng
    cudaPackages.cudatoolkit
    exiftool
    gobuster
    hashcat
    john
    nmap
    traceroute
    wireshark

    hunspell
    hunspellDicts.en-us-large
    libbs2b
    libebur128
    libsndfile
    tbb

    binwalk
    ddrescue
    foremost
    hdparm
    heimdall
    safecopy

    python3Full
    ruby_3_1
    sbcl
  ];

  # For accessing Samba shares
  services.gvfs.enable = true;

  home-manager.users.me = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "me";
    home.homeDirectory = "/home/me";

    programs.bash.enable = true;

    home.sessionPath =  [ "$HOME/bin" ];

    home.shellAliases = {
      dict = "dict --config ~/dict.conf";
      hm = "home-manager";
      sbcl = "rlwrap sbcl --userinit ~/.config/sbclrc";
    };

    programs.dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    home.file = {
      dict = {
        target = "./.config/dict.conf";
        text = "server dict.org\n";
      };
      sbcl = {
        target = "./.config/sbclrc";
        text = ''
          #-quicklisp
          (let ((quicklisp-init (merge-pathnames ".local/share/quicklisp/setup.lisp"
          				       (user-homedir-pathname))))
            (when (probe-file quicklisp-init)
              (load quicklisp-init)))
        '';
      };
      discord = {
        target = "./.config/discord/settings.json";
        text = ''
          {
            "SKIP_HOST_UPDATE": true,
            "IS_MAXIMIZED": false,
            "IS_MINIMIZED": false,
            "WINDOW_BOUNDS": {
              "x": 245,
              "y": 582,
              "width": 1016,
              "height": 764
            }
          }
        '';
      };
    };

    home.packages = with pkgs; [

      bitwarden
      discord
      prusa-slicer
      easyeffects
      gimp
      imv
      libreoffice
      nextcloud-client
      pavucontrol
      spotify
      thunderbird
      tor-browser-bundle-bin
      transmission-qt
      yuzu
      freecad
      blender

      ansible
      dict
      tenacity
      muse
      nnn
      onionshare
      pandoc
      ranger
      screenfetch
      torsocks
      xboxdrv
      xclip
      youtube-dl

      rubocop
      rust-analyzer
      scry
      solargraph
      tree-sitter

    ];

    programs.firefox.enable = true;
    programs.librewolf.enable = true;
    #programs.librewolf = {
    #  enable = true;
    #  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #    ipfs-companion
    #  ];
    #};
    programs.mpv.enable = true;
    programs.zathura.enable = true;

    programs.git = {
      enable = true;
      userName = "Sawyer Shepherd";
      userEmail = "contact@sawyershepherd.org";
    };

    programs.gpg = {
      enable = true;
      #homedir = "${config.xdg.dataHome}/gnupg";
    };

    programs.neovim = {
      enable = true;

      coc = {
        enable = true;
        settings.crystal = {
          command = "scry";
          filetypes = [ "crystal" "cr" ];
        };
      };

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withRuby = true;
      withPython3 = true;

      plugins = with pkgs.vimPlugins; [

        lightline-vim
        nnn-vim
        neoterm
        nvim-treesitter
        vim-fugitive
        vim-lightline-coc
        vim-nix
        vim-sandwich
        vim-slime
        vim-vinegar
        vimspector

        coc-css
        coc-git
        coc-highlight
        coc-html
        coc-java
        coc-json
        coc-pairs
        coc-prettier
        coc-pyright
        coc-rls
        coc-solargraph
        coc-yaml

      ];
      extraConfig = ''
        set signcolumn=yes
        set ignorecase
        set smartcase
        filetype plugin indent on
        set tabstop=4
        set softtabstop=0
        set expandtab
        set shiftwidth=4
        set smarttab
        set number relativenumber
        set cursorline
        set tw=60
        set encoding=UTF-8
        set mouse=a
        noremap Y y$
        let g:slime_target = "neovim"
        tnoremap <Esc> <C-\><C-n>
      '';
    };

    xdg = {
      enable = true;
      #mimeApps.enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "$HOME/desk";
        documents = "$HOME/doc";
        download = "$HOME/down";
        music = "$HOME/music";
        pictures = "$HOME/media";
        publicShare = "$HOME/pub";
        templates = "$HOME/temp";
        videos = "$HOME/media";
      };
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "22.05";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
    programs.home-manager.path = "$HOME/proj/home-manager";
  	
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

