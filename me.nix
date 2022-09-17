{ config, pkgs, ... }:

{
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
  };

  home.packages = with pkgs; [

    bitwarden
    discord
    easyeffects
    gimp
    imv
    libreoffice
    librewolf
    nextcloud-client
    pavucontrol
    spotify
    thunderbird
    tor-browser-bundle-bin
    transmission-qt
    yuzu

    ansible
    dict
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
  programs.mpv.enable = true;
  programs.zathura.enable = true;

  programs.git = {
    enable = true;
    userName = "Sawyer Shepherd";
    userEmail = "contact@sawyershepherd.org";
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
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
}
