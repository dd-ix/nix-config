{ lib, ... }:

{
  boot = {
    tmp.cleanOnBoot = lib.mkDefault true;
    loader.grub.configurationLimit = 10;
    loader.systemd-boot.configurationLimit = 10;
    # probably default with 25.11
    initrd.systemd.enable = true;
  };
}
