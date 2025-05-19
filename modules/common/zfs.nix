{ lib, config, pkgs, ... }:

let
  zfsVersion = "2_2";
  # original source: https://github.com/nix-community/srvos/blob/main/nixos/mixins/latest-zfs-kernel.nix
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages."zfs_${zfsVersion}".meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestZfsKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{

  config = lib.mkIf config.boot.zfs.enabled {
    boot = {
      # Note this might jump back and worth as kernel get added or removed.
      kernelPackages = latestZfsKernelPackage;
      zfs.package = pkgs."zfs_${zfsVersion}";
    };

    services.zfs = {
      autoSnapshot = {
        enable = true;
        frequent = 4;
        hourly = 7;
        daily = 6;
        weekly = 2;
        monthly = 1;
      };

      autoScrub = {
        enable = true;
      };
    };
  };
}
