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

    netdevs = {
      "10-${bond_device_name}" = {
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

      "20-${bond_device_name}.100" = {
        netdevConfig = {
          Name = "${bond_device_name}.100";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 100;
        };
      };

      "20-svc-internet".netdevConfig = {
        Name = "svc-internet";
        Kind = "bridge";
      };

      "20-${bond_device_name}.101" = {
        netdevConfig = {
          Name = "${bond_device_name}.101";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 101;
        };
      };

      "20-svc-services".netdevConfig = {
        Name = "svc-services";
        Kind = "bridge";
      };

      "20-${bond_device_name}.102" = {
        netdevConfig = {
          Name = "${bond_device_name}.102";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 102;
        };
      };

      "20-svc-management".netdevConfig = {
        Name = "svc-management";
        Kind = "bridge";
      };
    };

    networks = {
      "10-${bond_device_name}" = {
        matchConfig.Name = "${bond_device_name}";

        vlan = [ "${bond_device_name}.100" "${bond_device_name}.101" "${bond_device_name}.102" ];
      };

      "10-${first_device_name}-${bond_device_name}" = {
        matchConfig.Name = "${first_device_name}";
        networkConfig = {
          Bond = "${bond_device_name}"; # Enslaving to bond 
        };
      };

      "10-${second_device_name}-${bond_device_name}" = {
        matchConfig.Name = "${second_device_name}";
        networkConfig = {
          Bond = "${bond_device_name}"; # Enslaving to bond
        };
      };

      "10-${bond_device_name}.100" = {
        matchConfig.Name = "${bond_device_name}.100";
        networkConfig.Bridge = "svc-internet";
      };

      "10-svc-internet" = {
        matchConfig.Name = "10-svc-internet";

        address = [ "212.111.245.178/29" ];
        routes = [
          { routeConfig.Gateway = "212.111.245.177"; }
        ];
      };

      "30-microvm-svc-internet" = {
        matchConfig.Name = "vm-inet-*";
        networkConfig.Bridge = "svc-internet";
      };

      "10-${bond_device_name}.101" = {
        matchConfig.Name = "${bond_device_name}.101";
        networkConfig.Bridge = "svc-services";
      };

      "30-microvm-svc-services" = {
        matchConfig.Name = "vm-srv-*";
        networkConfig.Bridge = "svc-services";
      };

      "10-${bond_device_name}.102" = {
        matchConfig.Name = "${bond_device_name}.102";
        networkConfig.Bridge = "svc-management";
      };

      "10-svc-management" = {
        matchConfig.Name = "svc-management";
        address = [ "2a01:7700:80b0:7000::1/64" ];
        #routes = [ { routeConfig.Gateway = "fe80::defa"; } ];
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
