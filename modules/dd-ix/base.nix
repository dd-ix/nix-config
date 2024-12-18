{ lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh/tassilo
      ../../keys/ssh/melody
      ../../keys/ssh/fiasko
      ../../keys/ssh/marcel
      ../../keys/ssh/adb
      ../../keys/ssh/maurice
      ../../keys/ssh/robort
    ];
  };
  users.motd = ''
    DD-IX Production System
  '';
  services.openssh.enable = true;

  # mkDefault is 1000; so we set a default but override other mkDefaults 
  services.postgresql.package = pkgs.postgresql_16;
}
