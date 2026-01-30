{ config, pkgs, ... }:

let
  authorizedKeys = import ./authorized_keys.nix;
  pkgs-unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
in
{
  imports = [ ./syncthing.nix ];
  age.secrets.user-password.file = ../secrets/user-password.age;

  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.me = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "libvirtd" "audio" "wheel" "networkmanager" "video" "plugdev" ];
    hashedPasswordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  services.udev.extraRules = ''
    # Allow members of plugdev group to access USB devices
    SUBSYSTEM=="usb", MODE="0664", GROUP="plugdev"
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;  # Enables better codec support
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  hardware.rtl-sdr.enable = true;

  location.provider = "geoclue2";

  networking.firewall.allowedTCPPorts = [ 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];

  services = {
    #ollama.enable = true;
    #ollama.package = pkgs-unstable.ollama;
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
        variant = "altgr-intl";
      };

      exportConfiguration = true;

      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };

      displayManager = {
        lightdm = {
          enable = true;
          greeters.gtk = {
            enable = true;
            iconTheme = {
              name = "Reversal-dark";
              package = pkgs.reversal-icon-theme;
            };
            theme = {
              name = "WhiteSur-Dark";
              package = pkgs.whitesur-gtk-theme;
            };
            cursorTheme = {
              name = "WhiteSur-cursors";
              package = pkgs.whitesur-cursors;
              size = 24;
            };
          };
        };
        defaultSession = "xfce";
      };

    };

    pipewire = {
      enable = true;
      wireplumber.enable = true;
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          # Enable high-quality codecs
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          
          # Enable AAC codec support (important for AirPods)
          "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
          
          # Enable all Bluetooth roles for proper profile switching
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
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

  };

  programs.virt-manager.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pkgsi686Linux.libva  # Video acceleration
        pkgsi686Linux.libvdpau
        pkgsi686Linux.gtk3
        pkgsi686Linux.glibc
        pkgsi686Linux.SDL2
      ];
    };
  };

  programs.obs-studio.enable = true;
  programs.obs-studio.enableVirtualCamera = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  programs.xfconf.enable = true;

  environment.systemPackages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
      typora
      fdk_aac
      asunder
      lame
      abcde
  ];

  home-manager.users.me = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "me";
    home.homeDirectory = "/home/me";

    home.sessionPath = [ "$HOME/bin" ];

    programs.zsh.enable = true;

    home.shellAliases = {
      hm = "home-manager";
      sbcl = "rlwrap sbcl --userinit ~/.config/sbclrc";
      clip = "xclip -selection clipboard";
      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
      orca-slicer = "__GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=xcb orca-slicer";
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

    services.mpris-proxy.enable = true;

    home.packages = with pkgs; [

      aircrack-ng # Capture and crack air traffic
      amber-theme
      ameba
      anki # Flashcard program
      bash-language-server
      binwalk # Extract files from binary
      bitwarden-desktop # Password manager
      blender # Modeling software
      bottles # WINE wrapper
      burpsuite # Web exploitation framework
      caffeine-ng # Keep the screen awake
      calibre # Book management software
      capstone # Dissassembly library
      cheese # Webcam viewer
      cherrytree # Tree notes app
      clang-tools
      clooj # Clojure IDE
      comaps # Mapping software
      cppcheck
      crystal
      crystalline
      darktable
      deadnix
      digikam # Photo management
      discord-canary # Messaging and voice call app
      drawing # Like Paint
      easyeffects # Pipewire audio effects
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
      freetube # Youtube client
      gcs # GURPS character sheet builder
      ghidra # Reverse engineering suite
      gimp # Image editor
      gnome-disk-utility # Simply manage disks
      gnucash # Double-entry accounting
      gnuradio # SDR framework
      gobuster # Everything enumeration
      google-java-format
      gopls
      gpa # GPG frontend
      gparted # Disk partitioner
      gqrx # Radio receiver
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
      inspectrum # Spectrum inspector
      jdt-language-server
      jetbrains-mono
      john # CPU hash cracker
      kdePackages.kcalc # Calculator
      kdePackages.kdenlive # Video editor
      lexend
      libgourou # Process ebooks from command line
      libreoffice # Office suite
      lua-language-server
      marksman
      marktext # Markdown editor
      marwaita
      mate.engrampa # archive manager
      maxima # LISP computer algebra system
      metasploit # Exploitation framework
      musescore # Music notation software
      netexec # Active Directory exploitation framework
      nixpkgs-fmt
      nixpkgs-lint
      nnn # File explorer
      openfortivpn # Fortinet vpn services
      openscad # Parametric CAD
      orca-slicer # Slicer for 3D printing
      pa_applet # Volume control applet
      pandoc # Document converter
      pavucontrol # PulseAudio volume control
      prismlauncher # Minecraft launcher
      protontricks
      python312Packages.flake8 # Python linter
      python312Packages.python-lsp-server
      qjackctl # JACK patchbay
      qownnotes # WYSIWYG Markdown editor
      radare2
      ranger # File explorer
      remmina # GUI RDP/VNC/SSH
      resources # Process monitor
      reversal-icon-theme
      rizin
      rtl-sdr-librtlsdr
      rubocop # Ruby analyzer
      rubyfmt # Ruby formatter
      rust-analyzer # Rust analyzer
      rustfmt # Rust formatter
      s-tui
      signal-desktop # Secure messaging app
      slack
      solargraph # Ruby lang server
      spotify # Music streaming service
      sshuttle # SSH proxy
      statix
      strawberry # Music player
      stress
      system-config-printer # CUPS wrapper
      tenacity # Audio editor, Audacity fork
      tetex
      thc-hydra # Brute forcer
      thonny # Python IDE for microcontrollers
      tor-browser
      transmission_4-qt # Torrent client
      tree-sitter
      typescript-language-server
      undervolt
      ungoogled-chromium # Chromium web browser without the spyware
      v4l-utils # Camera utilities
      virglrenderer # 3D acceleration for QEMU
      volatility3 # Memory forensics tool
      vscode-langservers-extracted
      vscodium # IDE
      winetricks
      wireshark # Network capture tool
      wpscan # Wordpress scanner
      xclip # Copy to clipboard from CLI
      xfce.catfish
      xfce.exo
      xfce.gigolo
      xfce.orage
      xfce.xfburn
      xfce.xfce4-appfinder
      xfce.xfce4-clipman-plugin
      xfce.xfce4-cpugraph-plugin
      xfce.xfce4-dict
      xfce.xfce4-fsguard-plugin
      xfce.xfce4-genmon-plugin
      xfce.xfce4-netload-plugin
      xfce.xfce4-panel
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-sensors-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-volumed-pulse
      xfce.xfce4-weather-plugin
      xfce.xfce4-xkb-plugin
      xfce.xfdashboard
      xorg.xev
      xsel
      xtitle
      xwinmosaic
      yara # Malware analyzer
      yt-dlp # Youtube video downloader
      zap # Web pen testing proxy

    ];

    xfconf.settings = {
      keyboard-layout = {
        "Default/XkbDisable" = false;
        "Default/XkbLayout" = "us";
        "Default/XkbVariant" = "altgr-intl";
      };
      xsettings = {
        "Gtk/FontName" = "Lexend Light 12";
        "Gtk/MonospaceFontName" = "JetBrains Mono 12";
      };
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
        "font-use-system" = true;
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
      "general/title_font" = "Lexend Bold 12";
    };

    };

    home.pointerCursor = {
      name = "WhiteSur-cursors";
      package = pkgs.whitesur-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Reversal-dark";
        package = pkgs.reversal-icon-theme;
      };
      theme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-gtk-theme;
      };
      cursorTheme = {
        name = "WhiteSur-cursors";
        package = pkgs.whitesur-cursors;
        size = 24;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local config = wezterm.config_builder()

        -- Shell
        config.default_prog = { "/run/current-system/sw/bin/zsh", "-l" }

        -- Appearance
        config.color_scheme = "Wez"

        wezterm.on("window-config-reloaded", function(window)
                local overrides = window:get_config_overrides() or {}
                local appearance = window:get_appearance()
                local scheme = scheme_for_appearance(appearance)
                if overrides.color_scheme ~= scheme then
                        overrides.color_scheme = scheme
                        window:set_config_overrides(overrides)
                end
        end)

        config.font = wezterm.font_with_fallback({
                "JetBrains Mono",
                "Symbols Nerd Font",
        })
        config.font_size = 12.0

        -- Window
        config.window_padding = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8,
        }
        config.window_decorations = "RESIZE"
        config.hide_tab_bar_if_only_one_tab = true
        config.use_fancy_tab_bar = false

        -- Behavior
        config.scrollback_lines = 10000
        config.enable_scroll_bar = true
        config.audible_bell = "Disabled"
        config.check_for_updates = false

        -- GPU
        config.front_end = "WebGpu"

        -- Keybindings (keep defaults, add a few conveniences)
        config.keys = {
                { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
                { key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
                { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
                { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
                { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
        }

        return config
      '';
    };

    programs.firefox.enable = true;
    programs.librewolf.enable = true;
    programs.mpv.enable = true;
    programs.zathura.enable = true;
    programs.thunderbird = {
      enable = true;
      settings = {
        intl.date_time.pattern_override.time_short = "h:mm a";
      };
      profiles."mukqrcxm.default" = {
        isDefault = true;
      };
    };

    programs.git = {
      enable = true;
      settings.user.name = "Sawyer Shepherd";
      settings.user.email = "contact@sawyershepherd.org";
      settings = {
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

	cmp-buffer
	cmp-nvim-lsp
	cmp-path
	luasnip
	nvim-cmp
	nvim-web-devicons
	vim-nix
        lualine-nvim
        neoterm
        nvim-lspconfig
        nvim-tree-lua
        nvim-treesitter
        vim-sandwich
        wezterm-nvim

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
        vim.opt.textwidth = 80
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
