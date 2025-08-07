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
    assertions = [
      # https://gitea.c3d2.de/c3d2/nix-defaults/src/commit/51adf1d57b8e87f6fd43c90cc7fcca0e38dcc7a1/flake.nix#L16-L19
      {
        assertion = builtins.any (lib.hasPrefix "zfs.zfs_arc_max") config.boot.kernelParams;
        message = "boot.kernelParams must set zfs.zfs_arc_max when zfs is enabled to mitigate runaway RAM usage.";
      }
    ];

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
