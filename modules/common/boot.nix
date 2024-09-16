{ lib, ... }:

{
  boot.tmp.cleanOnBoot = lib.mkDefault true;
}
