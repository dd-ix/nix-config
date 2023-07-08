{ pkgs, ... }:
let
  bond_name = "bond";
in
{

  networking = {
    enableIPv6 = true;
    useDHCP = false;

    useNetworkd = true;
    wireguard.enable = true;
  };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "212.111.228.53" # IBH 1
      "193.36.123.53" # IBH 2
      "9.9.9.9" # QUAD 9
    ];
  };

  systemd.network = {
    enable = true;

    netdevs."10-${bond_name}" = {
      netDevConfig = {
        Name = "${bond_name}";
        Kind = "bond";
      };
      bondConfig = {
        Mode = "802.3ad"; # LACP 
        MIIMonitorSec = "250ms";
        LACPTransmitRate = "fast";
      };
    };

    networks."10-${bond_name}" = {
      matchConfig.Name = "${bond_name}";

      address = [ "212.111.245.178/29" ];
      routes = [
        {
          routeConfig.Gateway = "212.111.245.177";
        }
      ];

      networkConfig = {
        BindCarrier = [ "eno2" "eno3" ];
        DHCP = "no";
      };
    };

    networks."10-eno2-${bond_name}" = {
      matchConfig.Name = "eno2";
      networkConfig = {
        Bond = "${bond_name}"; # Enslaving to bond 
      };
    };

    networks."10-eno3-${bond_name}" = {
      matchConfig.Name = "eno3";
      networkConfig = {
        Bond = "${bond_name}"; # Enslaving to bond
      };
    };

  };

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 443 ];
    allowedUDPPorts = [ ];
  };
}
