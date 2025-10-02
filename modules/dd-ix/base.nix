{ lib, pkgs, ... }:

{
  users = {
    users.root.openssh.authorizedKeys.keys = import ../../keys/ssh.nix;
    # https://patorjk.com/software/taag/#p=display&f=Small&t=DD-IX&x=none&v=4&h=4&w=80&we=false
    motd = ''
       ___  ___     _____  __
      |   \|   \ __|_ _\ \/ /
      | |) | |) |___| | >  < 
      |___/|___/   |___/_/\_\
    '';
  };

  services = {
    openssh.enable = true;

    # mkDefault is 1000; so we set a default but override other mkDefaults, lower is more powerful
    postgresql.package = lib.mkOverride 999 pkgs.postgresql_17;
  };
}
