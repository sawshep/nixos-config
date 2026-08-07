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
    extraGroups = [ "dialout" "libvirtd" "audio" "wheel" "networkmanager" "video" "plugdev" ];
    hashedPasswordFile = config.age.secrets.user-password.path;
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  services.udev.extraRules = ''
    # Allow members of plugdev group to access USB devices
    SUBSYSTEM=="usb", MODE="0664", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", OWNER="me", MODE="0600"
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true; # Enables better codec support
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
    mullvad-vpn.enable = true;
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

  };

  programs.virt-manager.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pkgsi686Linux.libva # Video acceleration
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
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  environment.systemPackages = with pkgs; [

    abcde # CD ripping software
    asunder
    exiftool
    fdk_aac
    kdePackages.elisa # Music player
    lame
    typora
    wineWow64Packages.stable
    wireguard-go
    wireguard-tools
    xfce4-whiskermenu-plugin

  ];

  home-manager.users.me = { config, pkgs, ... }:
  let
    prismlauncherNoNativeGlfw = pkgs.prismlauncher.override {
      # Minecraft 26.1.2 / LWJGL 3.4.1 expects Mojang's GLFW IME symbols
      # such as glfwSetPreeditCallback. nixpkgs' glfw3-minecraft 3.4 does
      # not provide them, so let LWJGL use the native GLFW from its jar.
      glfw3-minecraft = pkgs.runCommand "prismlauncher-no-native-glfw" { } ''
        mkdir -p $out/lib
      '';
    };
  in
  {
    nixpkgs.config.allowUnfree = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "me";
    home.homeDirectory = "/home/me";

    home.sessionPath = [ "$HOME/bin" ];

      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
    };

    home.shellAliases = {
      hm = "home-manager";
      clip = "xclip -selection clipboard";
      rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
      prismlauncher = "__GLX_VENDOR_LIBRARY_NAME=nvidia prismlauncher";
    };

    home.file = {
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
      anki # Flashcard program
      bash-language-server
      binwalk # Extract files from binary
      pkgs-unstable.bitwarden-desktop # Password manager
      caffeine-ng # Keep the screen awake
      calibre # Book management software
      catfish # File search
      cheese # Webcam viewer
      chirp # Handheld radio programmer
      pkgs-unstable.codex
      comaps # Mapping software
      crosspipe # Pipewire patchbay
      pkgs-unstable.darktable # RAW photo editor
      discord-canary # Messaging and voice call app
      drawing # Like Paint
      easyeffects # Pipewire audio effects
      evince # document viewer
      fastmail-desktop # Mail client
      file-roller # archive manager
      font-manager
      freerdp # RDP client
      freetube # Youtube client
      ghidra # Reverse engineering suite
      gigolo # Easily mount remote fs
      gimp # Image editor
      gnome-disk-utility # Simply manage disks
      gnucash # Double-entry accounting
      gnuradio # SDR framework
      gpa # GPG frontend
      gparted # Disk partitioner
      gqrx # Radio receiver
      guitarix # Digital amplifier
      hashcat # GPU hash cracker
      hcxtools # hashcat companion tools
      hugo # Static site generator
      hunspell # Spellcheck
      hunspellDicts.en-us-large # Spellcheck dict
      imhex # Fancy hex editor for RE
      imv # Image viewer
      inkscape # Vector image editor
      inspectrum # Spectrum inspector
      pkgs-unstable.joplin-desktop # Notes platform
      kdePackages.kcalc # Calculator
      kdePackages.kdenlive # Video editor
      libgourou # Process ebooks from command line
      libguestfs
      libreoffice # Office suite
      marktext # Markdown editor
    engrampa # archive manager
      mullvad-vpn # VPN client
      musescore # Music notation software
      orage # Desktop calendar
      pa_applet # Volume control applet
      pandoc # Document converter
      pavucontrol # PulseAudio volume control
      prismlauncherNoNativeGlfw # Minecraft launcher
      protontricks
      pwgen
      qjackctl # JACK patchbay
      remmina # GUI RDP/VNC/SSH
      resources # Process monitor
      rtl-sdr-librtlsdr
      s-tui # "stress" terminal monitoring tool
      signal-desktop # Secure messaging app
      sox # Audio transformation toolkit
      spotify # Music streaming service
      sshuttle # SSH proxy

      spotify # Music streaming service
      sshuttle # SSH proxy
      strawberry # Music player
      stress # Benchmarking
      system-config-printer # CUPS wrapper
      tenacity # Audio editor, Audacity fork
      tetex # LaTex distribution
      thonny # Python IDE for microcontrollers
      undervolt
      ungoogled-chromium # Chromium web browser without the spyware
      v4l-utils # Camera utilities
      virglrenderer # 3D acceleration for QEMU
      vscodium # IDE
      winetricks
      wireshark # Network capture tool
      xclip # Copy to clipboard from CLI
      xfburn # Burn CDs
      xfce4-appfinder
      xfce4-clipman-plugin
      xfce4-cpugraph-plugin
      xfce4-dict
      xfce4-fsguard-plugin
      xfce4-genmon-plugin
      xfce4-netload-plugin
      xfce4-panel
      xfce4-pulseaudio-plugin
      xfce4-sensors-plugin
      xfce4-systemload-plugin
      xfce4-volumed-pulse
      xfce4-weather-plugin
      xfce4-xkb-plugin
      xfdashboard
      yt-dlp # Youtube video downloader

      # Supporting Nix
      statix # Linter
      deadnix # Find dead expressions
      nixpkgs-fmt
      nixpkgs-lint

    ];

    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
  };
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

      #plugins = with pkgs.vimPlugins; [

      #  cmp-buffer
      #  cmp-nvim-lsp
      #  cmp-path
      #  luasnip
      #  nvim-cmp
      #  nvim-web-devicons
      #  vim-nix
      #  lualine-nvim
      #  neoterm
      #  nvim-lspconfig
      #  nvim-tree-lua
      #  nvim-treesitter
      #  vim-sandwich
      #  wezterm-nvim

      #];
      initLua = ''
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
      setSessionVariables = true;
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
