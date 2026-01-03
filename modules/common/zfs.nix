{ lib, config, pkgs, ... }:

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
      zfs.package = pkgs.zfs_2_4;
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
