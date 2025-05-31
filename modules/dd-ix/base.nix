{ lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh/tassilo_1
      ../../keys/ssh/tassilo_2
      ../../keys/ssh/melody
      ../../keys/ssh/fiasko
      ../../keys/ssh/marcel
      ../../keys/ssh/adb
      ../../keys/ssh/maurice
      ../../keys/ssh/robort
      ../../keys/ssh/gedeon
    ];
  };
  users.motd = ''
    DD-IX Production System
  '';
  services.openssh.enable = true;

  # mkDefault is 1000; so we set a default but override other mkDefaults 
  services.postgresql.package = lib.mkOverride 999 pkgs.postgresql_17;
}
