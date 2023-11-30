{ config, pkgs, ... }:

{
#  age.secrets.user-password.file = ./secrets/user-password.age;
#  age.identityPaths = [ "/home/me/.ssh/id_ed25519" ];

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "pulse" "jackaudio" "audio" "wheel" "networkmanager" "video"];
    #passwordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHe4JdAXSDsJFeVAlY9vq+y3mFDZIPoBArAIfgt38vEW" # Firewall user
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHshr48iQqsn1H5ErCNVIdxaLMyt5X//ZRuhMg+WIVfq" # Firewall root
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJd0gD46Ddn2Bsl0+MIxkxO8AyupYfXj2Y9Z6xOnkMlt" # Laptop user
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEjID3NU5MMHJgsqvPXPTpaSAF8O1dq6rbMAeesbkQA me@asustek
" # Desktop user
    ];
  };

  services.xserver = {
    enable = true;

    # Keymap
    layout = "us";
    xkbVariant = "";

    exportConfiguration = true;

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };

    displayManager = {
      defaultSession = "xfce";
    };
  };

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  }; 

  # Low latency
  environment.etc = {
    "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
      context.properties = {
        default.clock.rate = 48000
        default.clock.quantum = 32
        default.clock.min-quantum = 32
        default.clock.max-quantum = 32
      }
    '';
  };


  programs.steam.enable = true;

  services.tor = {
    enable = true;
    client.enable = true;
    torsocks.enable = true;
  };


  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/home/me";
    user = "me";
    group = "users";
    guiAddress = "localhost:8384";
    overrideFolders = true;
    devices = {
	"HP EliteBook 835 G7" = { id = "PDH4BFZ-4FU2BYM-XY2TZNM-YMC3D6Y-G6K2JYE-KKFFVBH-7NRQU55-KA6HNAX"; };
	"ChangWang CW56-58" = { id = "FE52R5J-66HHL7H-JPQILZO-4V4QEQ6-NYXJRXW-CI6B3VN-6A4NEYI-B76ORQQ"; };
    };
    folders = {
      "Binaries" = {
        path = "/home/me/bin";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Cyber" = {
        path = "/home/me/cyber";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Desktop" = {
        path = "/home/me/desk";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Documents" = {
        path = "/home/me/doc";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Downloads" = {
        path = "/home/me/down";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Music" = {
        path = "/home/me/music";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Media" = {
        path = "/home/me/media";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
      "Thunderbird" = {
      	path = "/home/me/.thunderbird";
	devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" ];
	versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "7776000"; # 90 days
          };
        };
      };
    };
  };

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
      clip = "xclip -selection clipboard";
      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
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

      # GUI utilities
      anki # Flashcard program
      bitwarden # Password manager
      blender # Modeling software
      bottles # WINE wrapper
      caffeine-ng # Keep the screen awake
      cherrytree # Tree notes app
      clooj # Clojure IDE
      digikam # Photo management
      discord-canary # Messaging and voice call app
      easyeffects # Pipewire audio effects
      freecad # Parametric CAD software
      freerdp # RDP client
      gcs # GURPS character sheet builder
      ghidra # Reverse engineering suite
      gimp # Image editor
      gpa # GPG frontend
      guitarix # Digital amplifier
      helvum # Pipewire patchbay
      imhex # Fancy hex editor for RE
      imv # Image viewer
      kcalc # Calculator
      kdenlive # Video editor
      libreoffice # Office suite
      maxima # LISP computer algebra system
      obsidian # Markdown editor
      openscad # Parametric CAD
      pa_applet # Volume control applet
      pavucontrol # PulseAudio volume control
      prusa-slicer # Slicer for 3D printing
      qjackctl # JACK patchbay
      qownnotes # WYSIWYG Markdown editor
      remmina # GUI RDP/VNC/SSH
      spotify # Music streaming service
      strawberry # Music player
      system-config-printer # CUPS wrapper
      thonny # Python IDE for microcontrollers
      thunderbird # Email client
      tor-browser-bundle-bin
      transmission-qt # Torrent client
      ungoogled-chromium # Chromium web browser without the spyware
      virt-manager
      vscodium # IDE
      xfce.thunar-archive-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-volumed-pulse
      yuzu # Switch emulator

      # Cybersecurity Tools
      aircrack-ng # Capture and crack air traffic
      binwalk # Extract files from binary
      burpsuite # Web exploitation framework
      capstone # Dissassembly library
      crackmapexec # Active Directory exploitation framework
      enum4linux # SMB enumeration
      exploitdb # Search exploits from command line
      flare-floss # Reverse engineering tool
      foremost # Carve data from binaries
      gobuster # Everything enumeration
      feroxbuster # Better directory enumeration
      hashcat # GPU hash cracker
      hcxtools # hashcat companion tools
      heimdall # Flash android roms
      john # CPU hash cracker
      wpscan # Wordpress scanner
      zap # Web pen testing proxy
      metasploit # Exploitation framework
      routersploit # Exploitation framework for embedded devices
      thc-hydra # Brute forcer
      volatility3 # Memory forensics tool
      wireshark # Network capture tool
      yara # Malware analyzer

      # Command Line Utilities
      hugo # Static site generator
      hunspell # Spellcheck
      hunspellDicts.en-us-large # Spellcheck dict
      nnn # File explorer
      onionshare # P2P file sharing over TOR
      pandoc # Document converter
      protontricks
      ranger # File explorer
      tenacity # Audio editor, Audacity fork
      winetricks
      xboxdrv # XBox controller drivers
      xclip # Copy to clipboard from CLI
      youtube-dl # Youtube video downloader

      # Programming Lanugage Support
      clojure-lsp # Clojure LSP
      #crystalline # Crystal LSP
      leiningen # Clojure project manager
      rubocop # Ruby analyzer
      #ruby-lsp # Ruby LSP
      #rubyfmt # Ruby formatter
      rust-analyzer # Rust analyzer
      rustfmt # Rust formatter
      scry # Crystal analyzer
      solargraph # Ruby lang server

    ];

    programs.emacs = {
      enable = false;
      package = pkgs.emacs-gtk;
      extraPackages = emacsPackages: (with emacsPackages; [

        elisp-format
        evil
        lispy
        lispyville
        magit
        use-package

      ]);
      extraConfig = ''
        (require 'use-package)

        (use-package evil)
        (use-package magit)
        (use-package elisp-format)
        ;(use-package lispy)
        ;(use-package lispyville)
        (evil-mode 1)
        (add-hook 'lispy-mode-hook #'lispyville-mode)

        (recentf-mode 1)
        (setq history-length 25)
        (savehist-mode 1)
        (save-place-mode 1)
        (global-auto-revert-mode 1)
        (setq global-auto-revert-non-file-buffers t)

      '';
    };


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
      mime.enable = true;
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
}
