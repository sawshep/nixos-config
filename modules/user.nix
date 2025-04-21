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

      aircrack-ng # Capture and crack air traffic
      amber-theme
      ameba
      andromeda-gtk-theme
      anki # Flashcard program
      arc-icon-theme
      bash-language-server
      beauty-line-icon-theme
      binwalk # Extract files from binary
      bitwarden # Password manager
      blender # Modeling software
      bottles # WINE wrapper
      burpsuite # Web exploitation framework
      caffeine-ng # Keep the screen awake
      capstone # Dissassembly library
      cheese # Webcam viewer
      cherrytree # Tree notes app
      clang-tools
      clooj # Clojure IDE
      colloid-icon-theme
      cppcheck
      crystal
      crystalline
      deadnix
      digikam # Photo management
      discord-canary # Messaging and voice call app
      dracula-icon-theme
      drawing # Like Paint
      easyeffects # Pipewire audio effects
      elementary-xfce-icon-theme
      enum4linux # SMB enumeration
      eslint
      evince # document viewer
      exploitdb # Search exploits from command line
      feroxbuster # Better directory enumeration
      file-roller # archive manager
      flare-floss # Reverse engineering tool
      font-manager
      foremost # Carve data from binaries
      freerdp # RDP client
      gcs # GURPS character sheet builder
      ghidra # Reverse engineering suite
      gimp # Image editor
      gnome-disk-utility # Simply manage disks
      gnome-resources # Process monitor
      gobuster # Everything enumeration
      google-java-format
      gopls
      gpa # GPG frontend
      gparted # Disk partitioner
      guitarix # Digital amplifier
      hashcat # GPU hash cracker
      hcxtools # hashcat companion tools
      heimdall # Flash android roms
      helvum # Pipewire patchbay
      hugo # Static site generator
      hunspell # Spellcheck
      hunspellDicts.en-us-large # Spellcheck dict
      imhex # Fancy hex editor for RE
      imv # Image viewer
      inkscape
      inkscape-with-extensions
      jdt-language-server
      jetbrains-mono
      john # CPU hash cracker
      kdePackages.kcalc # Calculator
      kdePackages.kdenlive # Video editor
      kora-icon-theme
      libreoffice # Office suite
      lua-language-server
      marksman
      marktext # Markdown editor
      marwaita
      matcha-gtk-theme
      mate.engrampa # archive manager
      mate.mate-icon-theme
      maxima # LISP computer algebra system
      metasploit # Exploitation framework
      mint-l-icons
      mint-y-icons
      musescore
      musescore # Music notation software
      netexec # Active Directory exploitation framework
      nixpkgs-fmt
      nixpkgs-lint
      nnn # File explorer
      nordzy-icon-theme
      numix-gtk-theme
      numix-icon-theme
      obs-studio
      openfortivpn # Fortinet vpn services
      openscad # Parametric CAD
      pa_applet # Volume control applet
      pandoc # Document converter
      papirus-icon-theme
      pavucontrol # PulseAudio volume control
      plano-theme
      protontricks
      prusa-slicer # Slicer for 3D printing
      python312Packages.flake8 # Python linter
      python312Packages.python-lsp-server
      qjackctl # JACK patchbay
      qogir-icon-theme
      qownnotes # WYSIWYG Markdown editor
      radare2
      ranger # File explorer
      remmina # GUI RDP/VNC/SSH
      reversal-icon-theme
      rizin
      rose-pine-icon-theme
      rubocop # Ruby analyzer
      rubocop # Ruby linter
      rubyPackages.solargraph # Ruby LSP
      rubyfmt # Ruby formatter
      rust-analyzer # Rust LSP
      rust-analyzer # Rust analyzer
      rustfmt # Rust formatter
      s-tui
      shellcheck
      signal-desktop # Secure messaging app
      slack
      solargraph # Ruby lang server
      spotify # Music streaming service
      sshuttle # SSH proxy
      statix
      stilo-themes
      strawberry # Music player
      stress
      system-config-printer # CUPS wrapper
      tela-circle-icon-theme
      tela-icon-theme
      tenacity # Audio editor, Audacity fork
      tetex
      thc-hydra # Brute forcer
      thonny # Python IDE for microcontrollers
      thunderbird # Email client
      tor-browser-bundle-bin
      transmission_4-qt # Torrent client
      tree-sitter
      typescript-language-server
      undervolt
      ungoogled-chromium # Chromium web browser without the spyware
      v4l-utils # Camera utilities
      vimix-icon-theme
      virglrenderer # 3D acceleration for QEMU
      volatility3 # Memory forensics tool
      vscode-langservers-extracted
      vscodium # IDE
      whitesur-gtk-theme
      whitesur-icon-theme
      windows10-icons
      winetricks
      wireshark # Network capture tool
      wpscan # Wordpress scanner
      xclip # Copy to clipboard from CLI
      xfce.catfish
      xfce.exo
      xfce.gigolo
      xfce.orage
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.xfburn
      xfce.xfce4-appfinder
      xfce.xfce4-clipman-plugin
      xfce.xfce4-cpugraph-plugin
      xfce.xfce4-dict
      xfce.xfce4-fsguard-plugin
      xfce.xfce4-genmon-plugin
      xfce.xfce4-icon-theme
      xfce.xfce4-netload-plugin
      xfce.xfce4-panel
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-sensors-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-volumed-pulse
      xfce.xfce4-weather-plugin
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-xkb-plugin
      xfce.xfdashboard
      xfce.xfwm4-themes
      xorg.xcursorthemes
      xorg.xev
      xsel
      xtitle
      xwinmosaic
      yara # Malware analyzer
      yaru-remix-theme
      yaru-theme
      yt-dlp # Youtube video downloader
      zap # Web pen testing proxy
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
