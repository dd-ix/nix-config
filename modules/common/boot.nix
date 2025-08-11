{ lib, ... }:

{
  boot = {
    tmp.cleanOnBoot = lib.mkDefault true;
    loader.systemd-boot = {
      configurationLimit = 10;
      editor = false;
    };
    # probably default with 25.11
    initrd.systemd.enable = true;
  };
}
