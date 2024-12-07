{ lib, config, ... }:

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

    netdevs = lib.mkMerge [
      {
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
        "20-ixp-peering".netdevConfig = {
          Name = "ixp-peering";
          Kind = "bridge";
        };
      }
      (builtins.listToAttrs (lib.flatten (
        lib.mapAttrsToList
          (name: value: [
            {
              name = "20-${bond_device_name}.${builtins.toString value.vlan}";
              value = {
                netdevConfig = {
                  Name = "${bond_device_name}.${toString value.vlan}";
                  Kind = "vlan";
                };
                vlanConfig.Id = value.vlan;
              };
            }
            {
              name = "20-${value.bridge}";
              value.netdevConfig = {
                Name = value.bridge;
                Kind = "bridge";
              };
            }
          ])
          config.dd-ix.nets
      )))
    ];

    networks = lib.mkMerge [
      {
        "10-${bond_device_name}" = {
          matchConfig.Name = "${bond_device_name}";

          vlan = [ "${bond_device_name}.100" "${bond_device_name}.101" "${bond_device_name}.102" "${bond_device_name}.103" "${bond_device_name}.104" "${bond_device_name}.301" "${bond_device_name}.601" ];
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

        "10-svc-management" = {
          matchConfig.Name = "svc-management";
          address = [ "2a01:7700:80b0:7000::2/64" ];
          routes = [{ routeConfig.Gateway = "fe80::1"; }];
        };

        "10-${ixp_peering_device_name}" = {
          matchConfig.Name = "${ixp_peering_device_name}";
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

        "40-bring-prj-up-bridges" = {
          matchConfig.Name = "prj-*";
          networkConfig = {
            DHCP = "no";
            LinkLocalAddressing = "no";
            KeepConfiguration = "yes";
          };
        };
      }
      (builtins.listToAttrs (lib.flatten (
        lib.mapAttrsToList
          (name: value: [
            {
              name = "10-${bond_device_name}.${builtins.toString value.vlan}";
              value = {
                matchConfig.Name = "${bond_device_name}.${builtins.toString value.vlan}";
                networkConfig.Bridge = value.bridge;
              };
            }
          ])
          config.dd-ix.nets
      )))
    ];
  };

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };
}
