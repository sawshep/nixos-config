{ config, pkgs, ... }:

let
  authorizedKeys = import ./authorized_keys.nix;
in
{
  age.secrets.user-password.file = ../secrets/user-password.age;

  users.users.me = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "libvirtd" "pulse" "jackaudio" "audio" "wheel" "networkmanager" "video"];
    hashedPasswordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  hardware.bluetooth.enable = true;

  location.provider = "geoclue2";

  services = {
    ollama.enable = true;
    fwupd.enable = true;
    redshift = {
      enable = true;
      brightness = {
        # Note the string values below.
        day = "1";
        night = "1";
      };
      temperature = {
        day = 5500;
        night = 3700;
      };
    };
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];

      xkb = {
        layout = "us";
        variant = "";
      };

      exportConfiguration = true;

      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };

    };

    displayManager = {
      defaultSession = "xfce";
    };

    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    blueman.enable = true;

    tor = {
      enable = true;
      client.enable = true;
      torsocks.enable = true;
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/me";
      user = "me";
      group = "users";
      guiAddress = "localhost:8384";
      overrideFolders = true;
      settings.devices = {
          "HP EliteBook 835 G7" = { id = "PDH4BFZ-4FU2BYM-XY2TZNM-YMC3D6Y-G6K2JYE-KKFFVBH-7NRQU55-KA6HNAX"; };
          "ChangWang CW56-58" = { id = "FE52R5J-66HHL7H-JPQILZO-4V4QEQ6-NYXJRXW-CI6B3VN-6A4NEYI-B76ORQQ"; };
          "ASUSTeK" = { id = "O2RXYBG-MXB3BJG-HDB4R5U-QBIMCPI-4BAHWJD-KRZ56HQ-TFGPDJA-MNKPLAM"; };
      };
      settings.folders = {
        "Binaries" = {
          path = "/home/me/bin";
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
          devices = [ "ChangWang CW56-58" "HP EliteBook 835 G7" "ASUSTeK" ];
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
  };

  programs.virt-manager.enable = true;

  programs.steam.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  programs.xfconf.enable = true;

  home-manager.users.me = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "me";
    home.homeDirectory = "/home/me";

    home.sessionPath = [ "$HOME/bin" ];

    home.shellAliases = {
      hm = "home-manager";
      sbcl = "rlwrap sbcl --userinit ~/.config/sbclrc";
      clip = "xclip -selection clipboard";
      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
    };

    home.file = {
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
            "MIN_WIDTH": 0,
            "MIN_HEIGHT": 0,
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

      drawing # Like Paint
      evince # document viewer
      font-manager
      mate.engrampa # archive manager
      gnome-disk-utility # Simply manage disks
      gparted # Disk partitioner
      inkscape
      xfce.gigolo
      xfce.catfish
      xfce.orage
      xfce.xfburn
      xfce.xfce4-fsguard-plugin
      xfce.thunar-archive-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-volumed-pulse
      xfce.exo
      xfce.xfce4-whiskermenu-plugin

      # GUI utilities
      #cutter
      #cutterPlugins.jsdec
      #cutterPlugins.rz-ghidra
      #cutterPlugins.sigdb
      #freecad # Parametric CAD software
      #yuzu # Switch emulator
      anki # Flashcard program
      bitwarden # Password manager
      blender # Modeling software
      bottles # WINE wrapper
      caffeine-ng # Keep the screen awake
      cheese # Webcam viewer
      cherrytree # Tree notes app
      clooj # Clojure IDE
      digikam # Photo management
      discord-canary # Messaging and voice call app
      easyeffects # Pipewire audio effects
      freerdp # RDP client
      gcs # GURPS character sheet builder
      ghidra # Reverse engineering suite
      gimp # Image editor
      gpa # GPG frontend
      guitarix # Digital amplifier
      helvum # Pipewire patchbay
      imhex # Fancy hex editor for RE
      imv # Image viewer
      kdePackages.kcalc # Calculator
      obs-studio
      kdePackages.kdenlive # Video editor
      libreoffice # Office suite
      marktext # Markdown editor
      maxima # LISP computer algebra system
      musescore # Music notation software
      networkmanager-fortisslvpn
      openfortivpn # Fortinet vpn services
      openscad # Parametric CAD
      pa_applet # Volume control applet
      pavucontrol # PulseAudio volume control
      prusa-slicer # Slicer for 3D printing
      qjackctl # JACK patchbay
      qownnotes # WYSIWYG Markdown editor
      radare2
      remmina # GUI RDP/VNC/SSH
      rizin
      signal-desktop # Secure messaging app
      slack
      spotify # Music streaming service
      strawberry # Music player
      system-config-printer # CUPS wrapper
      thonny # Python IDE for microcontrollers
      thunderbird # Email client
      tor-browser-bundle-bin
      transmission_4-qt # Torrent client
      ungoogled-chromium # Chromium web browser without the spyware
      virglrenderer # 3D acceleration for QEMU
      vscodium # IDE
      xfce.thunar-archive-plugin
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-volumed-pulse

      # Cybersecurity Tools
      aircrack-ng # Capture and crack air traffic
      binwalk # Extract files from binary
      burpsuite # Web exploitation framework
      capstone # Dissassembly library
      netexec # Active Directory exploitation framework
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
      #routersploit # Exploitation framework for embedded devices
      thc-hydra # Brute forcer
      volatility3 # Memory forensics tool
      wireshark # Network capture tool
      yara # Malware analyzer

      # Command Line Utilities
      hugo # Static site generator
      hunspell # Spellcheck
      hunspellDicts.en-us-large # Spellcheck dict
      nnn # File explorer
      #onionshare # P2P file sharing over TOR
      pandoc # Document converter
      protontricks
      ranger # File explorer
      sshuttle # SSH proxy
      tenacity # Audio editor, Audacity fork
      tetex
      v4l-utils # Camera utilities
      winetricks
      xclip # Copy to clipboard from CLI
      yt-dlp # Youtube video downloader

      # Programming Lanugage Support
      clang-tools
      cppcheck
      tree-sitter
      python312Packages.python-lsp-server
      python312Packages.flake8 # Python linter
      crystalline
      crystal
      ameba
      gopls
      typescript-language-server
      eslint
      lua-language-server
      jdt-language-server
      google-java-format
      vscode-langservers-extracted
      bash-language-server
      shellcheck
      rubocop # Ruby linter
      marksman
      nixpkgs-fmt
      nixpkgs-lint
      statix
      deadnix
      rubyfmt # Ruby formatter
      rust-analyzer # Rust LSP
      rustfmt # Rust formatter
      rubyPackages.solargraph # Ruby LSP

      jetbrains-mono
      amber-theme
      andromeda-gtk-theme
      arc-icon-theme
      beauty-line-icon-theme
      colloid-icon-theme
      dracula-icon-theme
      elementary-xfce-icon-theme
      kora-icon-theme
      marwaita
      matcha-gtk-theme
      mate.mate-icon-theme
      mint-l-icons
      mint-y-icons
      nordzy-icon-theme
      numix-gtk-theme
      numix-icon-theme
      papirus-icon-theme
      plano-theme
      qogir-icon-theme
      reversal-icon-theme
      rose-pine-icon-theme
      stilo-themes
      tela-circle-icon-theme
      tela-icon-theme
      vimix-icon-theme
      whitesur-gtk-theme
      whitesur-icon-theme
      windows10-icons
      xfce.xfce4-icon-theme
      xfce.xfwm4-themes
      xorg.xcursorthemes
      yaru-remix-theme
      yaru-theme
      zuki-themes
    ];

    xfconf.settings = {
      xfce4-terminal = {
        "binding-ambiguous-width" = "TERMINAL_AMBIGUOUS_WIDTH_BINDING_WIDE";
        "color-background" = "#24241f1f3131";
        "color-background-vary" = true;
        "color-bold-is-bright" = true;
        "color-bold-use-default" = true;
        "color-cursor" = "#dcdcdc";
        "color-cursor-use-default" = true;
        "color-foreground" = "#dcdcdc";
        "color-palette" = "#3f3f3f;#705050;#60b48a;#dfaf8f;#9ab8d7;#dc8cc3;#8cd0d3;#dcdcdc;#709080;#dca3a3;#72d5a3;#f0dfaf;#94bff3;#ec93d3;#93e0e3;#ffffff";
        "color-selection-use-default" = true;
        "color-use-theme" = false;
        "dropdown-show-borders" = false;
        "font-use-system" = false;
        "misc-bell" = false;
        "misc-bell-urgent" = false;
        "misc-cursor-blinks" = true;
        "misc-cursor-shape" = "TERMINAL_CURSOR_SHAPE_IBEAM";
        "misc-hyperlinks-enabled" = true;
        "misc-middle-click-opens-uri" = false;
        "misc-mouse-autohide" = false;
        "misc-right-click-action" = "TERMINAL_RIGHT_CLICK_ACTION_CONTEXT_MENU";
        "misc-show-unsafe-paste-dialog" = false;
        "misc-slim-tabs" = true;
        "scrolling-unlimited" = true;
        "tab-activity-color" = "#aa0000";
        "title-mode" = "TERMINAL_TITLE_REPLACE";
      };
    xfwm4 = {
      "borderless_maximize" = true;
      "box_move" = true;
      "box_resize" = true;
      "mousewheel_rollup" = false;
    };

    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Reversal";
        package = pkgs.reversal-icon-theme;
      };
      theme = {
        name = "WhiteSur-Light";
        package = pkgs.whitesur-gtk-theme;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=0
        '';
      };
      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=0
        '';
      };
    };

    programs.firefox.enable = true;
    programs.librewolf.enable = true;
    programs.mpv.enable = true;
    programs.zathura.enable = true;


    programs.git = {
      enable = true;
      userName = "Sawyer Shepherd";
      userEmail = "contact@sawyershepherd.org";
      extraConfig = {
        core = {
          sshCommand = "ssh -i ~/.ssh/github";
        };
      };
    };

    programs.gpg = {
      enable = true;
    };

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withRuby = true;
      withPython3 = true;

      plugins = with pkgs.vimPlugins; [

        lualine-nvim
	nvim-web-devicons

        neoterm
        nvim-tree-lua

        nvim-treesitter

        vim-sandwich
        nvim-lspconfig
	cmp-nvim-lsp
	nvim-cmp
	cmp-buffer
	cmp-path
	luasnip

	vim-nix
      ];
      extraLuaConfig = ''
        -- Basic settings
        vim.opt.signcolumn = "yes"
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.incsearch = true
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.cursorline = true
        vim.opt.showmode = false
        vim.opt.splitbelow = true
        vim.opt.splitright = true
        vim.opt.tabstop = 4
        vim.opt.softtabstop = 0
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 4
        vim.opt.smarttab = true
        vim.opt.textwidth = 60
        vim.opt.spell = true
        vim.opt.spelllang = { "en" }
        vim.opt.mouse = "a"
        vim.cmd("filetype plugin indent on")
        
        -- Keymaps
        local map = vim.api.nvim_set_keymap
        local opts = { noremap = true, silent = true }
        
        -- Visual mode tab/shift-tab
        map("v", "<Tab>", ">gv", {})
        map("v", "<S-Tab>", "<gv", {})
        
        -- Yank to end of line
        map("n", "Y", "y$", opts)
        
        -- Terminal mode: exit with Esc
        map("t", "<Esc>", [[<C-\><C-n>]], opts)
        
        -- Resize windows
        map("n", "<C-Up>", ":resize +2<CR>", opts)
        map("n", "<C-Down>", ":resize -2<CR>", opts)
        map("n", "<C-Right>", ":vertical resize +2<CR>", opts)
        map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
	-- LSP Setup
	local lspconfig = require('lspconfig')
	lspconfig.clangd.setup {}

	-- Autocompletion
	local cmp = require'cmp'
	cmp.setup {
	  snippet = {
	    expand = function(args)
	      require('luasnip').lsp_expand(args.body)
	    end,
	  },
	  sources = {
	    { name = 'nvim_lsp' },
	    { name = 'buffer' },
	    { name = 'path' },
	  },
	  mapping = cmp.mapping.preset.insert({
	    ['<Tab>'] = cmp.mapping.select_next_item(),
	    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
	    ['<CR>'] = cmp.mapping.confirm({ select = true }),
	  }),
	}

	-- Treesitter
	require'nvim-treesitter.configs'.setup {
	  highlight = { enable = true },
	}

        -- Tree
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- optionally enable 24-bit colour
        vim.opt.termguicolors = true

        -- empty setup using defaults
        require("nvim-tree").setup()

	-- Lualine
	require('lualine').setup()
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
