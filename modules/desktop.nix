{ pkgs, ... }:

{
  # Keep the graphical session in one module so every desktop host presents
  # the same appearance, while headless hosts do not inherit a display stack.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];

    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };

    displayManager.lightdm.greeters.gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };
  };

  services.displayManager.defaultSession = "xfce";

  fonts.packages = with pkgs; [
    jetbrains-mono
    lexend
  ];

  # Covers Qt applications launched outside the Home Manager session as well.
  qt = {
    enable = true;
    style = "adwaita";
  };

  programs.xfconf.enable = true;

  home-manager.users.me = { pkgs, ... }: {
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
      cursor-size = 24;
      cursor-theme = "Bibata-Modern-Classic";
      font-name = "Lexend 11";
      gtk-theme = "adw-gtk3";
      icon-theme = "Papirus";
      monospace-font-name = "JetBrains Mono 11";
    };

    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      font = {
        name = "Lexend";
        size = 11;
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 0;
      };
      # Whisker Menu is a GTK3 popup.  adw-gtk3 otherwise leaves some of its
      # container nodes transparent, which lets the desktop show through.
      gtk3.extraCss = ''
        #whiskermenu-window,
        #whiskermenu-window > frame,
        #whiskermenu-window scrolledwindow,
        #whiskermenu-window viewport,
        #whiskermenu-window .view,
        #whiskermenu-window treeview {
          background-color: #ffffff;
          background-image: none;
          color: #1f2328;
        }

        #whiskermenu-window .view:selected,
        #whiskermenu-window treeview:selected {
          background-color: #dbeafe;
          color: #1f2328;
        }
      '';
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 0;
      };
      gtk4.theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita";
    };

    xfconf.settings = {
      keyboard-layout = {
        "Default/XkbDisable" = false;
        "Default/XkbLayout" = "us";
        "Default/XkbVariant" = "altgr-intl";
      };
      xsettings = {
        "Gtk/CursorThemeName" = "Bibata-Modern-Classic";
        "Gtk/CursorThemeSize" = 24;
        "Gtk/FontName" = "Lexend 11";
        "Gtk/IconThemeName" = "Papirus";
        "Gtk/MonospaceFontName" = "JetBrains Mono 11";
        "Net/ThemeName" = "adw-gtk3";
      };
      xfce4-terminal = {
        "color-background" = "#ffffff";
        "color-background-vary" = false;
        "color-bold-is-bright" = false;
        "color-bold-use-default" = true;
        "color-cursor" = "#1f1f1f";
        "color-cursor-use-default" = false;
        "color-foreground" = "#1f1f1f";
        "color-palette" = "#2e3440;#bf616a;#a3be8c;#ebcb8b;#5e81ac;#b48ead;#88c0d0;#e5e9f0;#4c566a;#bf616a;#a3be8c;#ebcb8b;#5e81ac;#b48ead;#8fbcbb;#eceff4";
        "color-selection-use-default" = true;
        "color-use-theme" = false;
        "font-name" = "JetBrains Mono 11";
        "font-use-system" = false;
        "misc-bell" = false;
        "misc-bell-urgent" = false;
        "misc-cursor-blinks" = true;
        "misc-cursor-shape" = "TERMINAL_CURSOR_SHAPE_IBEAM";
        "misc-hyperlinks-enabled" = true;
        "misc-show-unsafe-paste-dialog" = false;
        "misc-slim-tabs" = true;
        "scrolling-unlimited" = true;
        "title-mode" = "TERMINAL_TITLE_REPLACE";
      };
      xfwm4 = {
        "borderless_maximize" = true;
        "general/title_font" = "Lexend Bold 11";
      };
    };

    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local config = wezterm.config_builder()

        config.default_prog = { "/run/current-system/sw/bin/zsh", "-l" }
        config.colors = {
          foreground = "#1f2328",
          background = "#ffffff",
          cursor_bg = "#1f2328",
          cursor_fg = "#ffffff",
          selection_bg = "#dbeafe",
          selection_fg = "#1f2328",
          ansi = {
            "#1f2328", "#c0392b", "#2f855a", "#9a6700",
            "#2f6f9f", "#8250df", "#0f766e", "#d0d7de",
          },
          brights = {
            "#57606a", "#cf222e", "#1a7f37", "#9a6700",
            "#0969da", "#8250df", "#0f766e", "#f6f8fa",
          },
        }
        config.window_background_opacity = 1.0
        config.font = wezterm.font_with_fallback({
          "JetBrains Mono",
          "Symbols Nerd Font",
        })
        config.font_size = 11.0
        config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
        config.window_decorations = "RESIZE"
        config.hide_tab_bar_if_only_one_tab = true
        config.use_fancy_tab_bar = false
        config.scrollback_lines = 10000
        config.enable_scroll_bar = true
        config.audible_bell = "Disabled"
        config.check_for_updates = false
        config.front_end = "WebGpu"
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
  };
}
