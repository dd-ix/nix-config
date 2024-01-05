{ pkgs, ... }:
let
  bond_device_name = "bond"; # name of the bond interface
  first_device_name = "enp144s0"; # first port that should be part of the LAG
  second_device_name = "enp144s0d1"; # second port that should be part of the LAG
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
      netdevConfig = {
        Name = "${bond_device_name}";
        Kind = "bond";
      };
      bondConfig = {
        Mode = "802.3ad"; # LACP 
        MIIMonitorSec = "250ms";
        LACPTransmitRate = "fast";
      };
    };

    netdevs."20-uplink" = {
      netdevConfig = {
        Name = "uplink";
        Kind = "vlan";
      };
      vlanConfig = {
        Id = 100;
      };
    };

    networks."10-${bond_device_name}" = {
      matchConfig.Name = "${bond_device_name}";

      vlan = [ "uplink" ];

      networkConfig = {
        DHCP = "no";
      };
    };

    networks."10-uplink" = {
      matchConfig.Name = "uplink";

      address = [ "212.111.245.178/29" ];
      routes = [
        {
          routeConfig.Gateway = "212.111.245.176";
        }
      ];

      vlan = [ "uplink" ];

      networkConfig = {
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
