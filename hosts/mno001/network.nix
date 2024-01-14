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

      # 20-svc-internet
      "20-uplink" = {
        netdevConfig = {
          # svc-internet
          Name = "uplink";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 100;
        };
      };

      "20-br-svc-internet".netdevConfig = {
        Name = "br-svc-internet";
        Kind = "bridge";
      };

      "20-svc-services" = {
        netdevConfig = {
          Name = "svc-services";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 101;
        };
      };

      "20-br-svc-services".netdevConfig = {
        Name = "br-svc-services";
        Kind = "bridge";
      };

      "20-svc-management" = {
        netdevConfig = {
          Name = "svc-management";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 102;
        };
      };

      "20-br-svc-management".netdevConfig = {
        Name = "br-svc-management";
        Kind = "bridge";
      };
    };

    networks = {
      "10-${bond_device_name}" = {
        matchConfig.Name = "${bond_device_name}";

        vlan = [ "uplink" "svc-management" ];

        networkConfig = {
          DHCP = "no";
        };
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

      #"10-svc-internet" = {
      #  matchConfig.Name = "svc-internet";
      #  networkConfig.Bridge = "br-svc-internet";
      #};

      #10-br-svc-internet
      "10-uplink" = {
        #10-br-svc-internet
        matchConfig.Name = "uplink";

        address = [ "212.111.245.178/29" ];
        routes = [
          { routeConfig.Gateway = "212.111.245.177"; }
        ];

        # remove
        vlan = [ "uplink" ];

        # remove (is default)
        networkConfig = {
          DHCP = "no";
        };
      };

      "30-microvm-br-svc-internet" = {
        matchConfig.Name = "vm-inet-*";
        networkConfig.Bridge = "br-svc-internet";
      };

      "10-svc-services" = {
        matchConfig.Name = "svc-services";
        networkConfig.Bridge = "br-svc-services";
      };

      "30-microvm-br-svc-services" = {
        matchConfig.Name = "vm-srv-*";
        networkConfig.Bridge = "br-svc-services";
      };

      "10-svc-management" = {
        matchConfig.Name = "svc-management";
        networkConfig.Bridge = "br-svc-management";
      };

      "10-br-svc-management" = {
        matchConfig.Name = "br-svc-management";
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
