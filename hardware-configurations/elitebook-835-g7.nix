# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      luks.devices."drv".device = "/dev/disk/by-uuid/f8f2adb7-6f21-4f38-b659-d38435487e1d";
      availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    plymouth.enable = false;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernelParams = [ "resume_offset=47517297" ];
    resumeDevice = "/dev/disk/by-uuid/5f412f9a-4adb-4b64-809b-43dd099fa601";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5f412f9a-4adb-4b64-809b-43dd099fa601";
    fsType = "btrfs";
    options = [ "relatime" ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/5f412f9a-4adb-4b64-809b-43dd099fa601";
    fsType = "btrfs";
    options = [ "subvol=swap" "noatime" ];
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7EB2-92E8";
      fsType = "vfat";
    };

  swapDevices = [ {
    device = "/swap/swapfile";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  #hardware.graphics.extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
  #hardware.graphics.extraPackages = with pkgs; [ rocm-opencl-runtime ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };
}
