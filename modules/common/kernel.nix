{ lib, pkgs, config, ... }:

let
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (
          (!isUnstable && !kernelPackages.zfs.meta.broken)
          || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
        )
    )
    pkgs.linuxKernel.packages;
  latestZfsKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
  zfsEnabled = lib.meta.availableOn pkgs.hostPlatform pkgs.zfs
    && config.boot.zfs.enabled;
in
{
  # Note this might jump back and worth as kernel get added or removed.
  boot.kernelPackages = if zfsEnabled then latestZfsKernelPackage else pkgs.linuxPackages_latest;
}
