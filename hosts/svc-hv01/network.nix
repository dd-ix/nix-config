{ pkgs, ... }:
let
  bond_device_name = "bond"; # name of the bond interface
  first_device_name = "enp144s0"; # first port that should be part of the LAG
  second_device_name = "enp144s0d1"; # second port that should be part of the LAG
  ixp_peering_device_name = "eno2";
in
{
  networking = {
    enableIPv6 = true;
    useDHCP = false;

    useNetworkd = true;
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

      "20-${bond_device_name}.103" = {
        netdevConfig = {
          Name = "${bond_device_name}.103";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 103;
        };
      };

      "20-svc-lab".netdevConfig = {
        Name = "svc-lab";
        Kind = "bridge";
      };

      "20-${bond_device_name}.104" = {
        netdevConfig = {
          Name = "${bond_device_name}.104";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 104;
        };
      };

      "20-svc-admin".netdevConfig = {
        Name = "svc-admin";
        Kind = "bridge";
      };

      "20-${bond_device_name}.301" = {
        netdevConfig = {
          Name = "${bond_device_name}.301";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 301;
        };
      };

      "20-svc-ixp-mgmt".netdevConfig = {
        Name = "svc-ixp-mgmt";
        Kind = "bridge";
      };

      "20-ixp-peering".netdevConfig = {
        Name = "ixp-peering";
        Kind = "bridge";
      };
    };

    networks = {
      "10-${bond_device_name}" = {
        matchConfig.Name = "${bond_device_name}";

        vlan = [ "${bond_device_name}.100" "${bond_device_name}.101" "${bond_device_name}.102" "${bond_device_name}.103" "${bond_device_name}.104" "${bond_device_name}.301" ];
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

      "30-microvm-svc-internet" = {
        matchConfig.Name = "i-*";
        networkConfig.Bridge = "svc-internet";
      };

      "10-${bond_device_name}.101" = {
        matchConfig.Name = "${bond_device_name}.101";
        networkConfig.Bridge = "svc-services";
      };

      "30-microvm-svc-services" = {
        matchConfig.Name = "s-*";
        networkConfig.Bridge = "svc-services";
      };

      "10-${bond_device_name}.102" = {
        matchConfig.Name = "${bond_device_name}.102";
        networkConfig.Bridge = "svc-management";
      };

      "10-svc-management" = {
        matchConfig.Name = "svc-management";
        address = [ "2a01:7700:80b0:7000::2/64" ];
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
      };

      "10-${bond_device_name}.103" = {
        matchConfig.Name = "${bond_device_name}.103";
        networkConfig.Bridge = "svc-lab";
      };

      "30-microvm-svc-lab" = {
        matchConfig.Name = "l-*";
        networkConfig.Bridge = "svc-lab";
      };

      "10-${bond_device_name}.104" = {
        matchConfig.Name = "${bond_device_name}.104";
        networkConfig.Bridge = "svc-admin";
      };

      "30-microvm-svc-admin" = {
        matchConfig.Name = "a-*";
        networkConfig.Bridge = "svc-admin";
      };

      "10-${bond_device_name}.301" = {
        matchConfig.Name = "${bond_device_name}.301";
        networkConfig.Bridge = "svc-ixp-mgmt";
      };

      "30-microvm-svc-ixp-mgmt" = {
        matchConfig.Name = "im-*";
        networkConfig.Bridge = "svc-ixp-mgmt";
      };

      "10-${ixp_peering_device_name}" = {
        matchConfig.Name = "${ixp_peering_device_name}";
        networkConfig.Bridge = "ixp-peering";
      };

      "30-microvm-ixp-peering" = {
        matchConfig.Name = "p-*";
        networkConfig.Bridge = "ixp-peering";
      };

      "40-bring-svc-up-bridges" = {
        matchConfig.Name = "svc-*";
        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = "no";
          KeepConfiguration = "yes";
        };
      };

      "40-bring-ixp-up-bridges" = {
        matchConfig.Name = "ixp-*";
        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = "no";
          KeepConfiguration = "yes";
        };
      };
    };
  };

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };
}
