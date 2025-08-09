{ lib, pkgs, ... }:

{
  users = {
    users.root.openssh.authorizedKeys.keys = import ../../keys/ssh.nix;
    motd = ''
      DD-IX Production System
    '';
  };

  services = {
    openssh.enable = true;

    # mkDefault is 1000; so we set a default but override other mkDefaults, lower is more powerful
    postgresql.package = lib.mkOverride 999 pkgs.postgresql_17;

  };
}
