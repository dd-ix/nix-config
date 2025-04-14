{ lib, config, pkgs, ... }:

{
  config = lib.mkIf config.boot.zfs.enabled {
    boot.zfs.package = pkgs.zfs_2_2;

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
