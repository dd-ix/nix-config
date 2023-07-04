{ pkgs, ... }:
let
  bond_name = "bond0";
in
{

  # LACP on first two ports
  networking.bonds."${bond_name}" = {
    interfaces = [ "eno2" "eno3" ];
    driverOptions = {
      mode = "802.3ad";
      lacp_rate = "fast";
    };
  };

  # Static IP Address
  networking.interfaces."${bond_name}" = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "212.111.245.178";
        prefixLength = 29;
      }
    ];
  };

  # Default Gateway
  networking.defaultGateway.address = "212.111.245.177";

  # nameservers
  networking.nameservers = [ "212.111.228.53" "193.36.123.53" ];

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 443 ];
    allowedUDPPorts = [ ];
  };
}
