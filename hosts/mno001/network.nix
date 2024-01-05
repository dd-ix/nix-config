{ pkgs, ... }:
let
  bond_device_name = "bond"; # name of the bond interface
  first_device_name = "enp144s0"; # first port that should be part of the LAG
  second_device_name = "enp1440d1"; # second port that should be part of the LAG
in
{
 networking = {
    enableIPv6 = true;
    useDHCP = false;

    useNetworkd = true;
    wireguard.enable = true;

    nameservers = [
      "212.111.228.53" # IBH 1
      "193.36.123.53" # IBH 2
    ];
  };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "9.9.9.9" # QUAD 9
    ];
  };

  systemd.network = {
    enable = true;

    netdevs."10-${bond_device_name}" = {
      netDevConfig = {
        Name = "${bond_device_name}";
        Kind = "bond";
      };
      bondConfig = {
        Mode = "802.3ad"; # LACP 
        MIIMonitorSec = "250ms";
        LACPTransmitRate = "fast";
      };
    };

    networks."10-${bond_device_name}" = {
      matchConfig.Name = "${bond_device_name}";

      address = [ "212.111.245.178/29" ];
      routes = [
        {
          routeConfig.Gateway = "212.111.245.177";
        }
      ];

      networkConfig = {
        BindCarrier = [ "${first_device_name}" "${second_device_name}" ];
        DHCP = "no";
      };
    };

    networks."10-${first_device_name}-${bond_device_name}" = {
      matchConfig.Name = "${first_device_name}";
      networkConfig = {
        Bond = "${bond_device_name}"; # Enslaving to bond 
      };
    };

    networks."10-${second_device_name}-${bond_device_name}" = {
      matchConfig.Name = "${second_device_name}";
      networkConfig = {
        Bond = "${bond_device_name}"; # Enslaving to bond
      };
    };

  };

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 443 2222 ];
    allowedUDPPorts = [ ];
  };
}
