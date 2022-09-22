{ config, pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  # Pin to unstable
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  nix.settings.auto-optimise-store = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.neovim = {
  	enable = true;
	viAlias = true;
  };
  environment.variables.EDITOR = "nvim";

  programs.bash.promptInit = ''
    if [ "$LOGNAME" = root ] || [ "`id -u`" -eq 0 ] ; then
      PS1='\[\033[01;31m\]\u@\h:\w \$\[\033[00m\] '
    else
      PS1='\u@\h:\w \$ '
    fi
  '';

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

    file
    git
    lsof
    htop
    inetutils
    iotop
    lm_sensors
    moreutils
    networkmanager
    pciutils
    tree
    wget

  ];
}