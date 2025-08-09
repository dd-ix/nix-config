{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "megaraid_sas" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ "igb" "mlx4_en" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "rpool/root/nixos";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/nix" = {
      device = "rpool/root/nixos/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/var/lib" = {
      device = "rpool/data";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F124-300A";
      fsType = "vfat";
      options = [ "X-mount.mkdir" "fmask=0022" "dmask=0022" ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
