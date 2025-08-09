{ lib, config, ... }:

{
  networking.ifstate = {
    enable = true;

    settings = {
      # ignore vm tap interfaces
      parameters.ignore.ifname = [ "^vm-.+$" "^vnet\\d+$" ];

      interfaces = {
        # unknown, unused
        enp0s29u1u1u5 = {
          link.kind = "physical";
          identify = { parent_dev_name = "usb-0000:00:1d.0-1.1.5"; parent_dev_bus_name = "pci"; };
        };

        # 1G rj45 onboard interfaces
        # used in ixp-as11201
        eth0 = {
          link.kind = "physical";
          identify = { parent_dev_name = "0000:06:00.0"; parent_dev_bus_name = "pci"; };
        };
        # used in prj-llb01
        eth1 = {
          link.kind = "physical";
          identify = { parent_dev_name = "0000:06:00.1"; parent_dev_bus_name = "pci"; };
        };
        # unused
        eth2 = {
          link.kind = "physical";
          identify = { parent_dev_name = "0000:06:00.2"; parent_dev_bus_name = "pci"; };
        };
        # unused
        eth3 = {
          link.kind = "physical";
          identify = { parent_dev_name = "0000:06:00.3"; parent_dev_bus_name = "pci"; };
        };

        # 10G sfp+ interfaces
        eth4 = {
          link = { state = "up"; kind = "physical"; master = "bond"; };
          identify.perm_address = "00:02:c9:23:4c:20";
        };
        eth5 = {
          link = { state = "up"; kind = "physical"; master = "bond"; };
          identify.perm_address = "00:02:c9:23:4c:21";
        };

        bond.link = {
          state = "up";
          kind = "bond";
          # 802.3ad
          bond_mode = 4;
          bond_ad_lacp_rate = 1;
          # layer3+4
          bond_xmit_hash_policy = 1;
          bond_miimon = 100;
          bond_updelay = 300;
        };
      }
      //
      (builtins.foldl'
        (last: current:
          last // {
            "${current.value.bridge}" = {
              addresses = lib.optional (current.name == "management") "2a01:7700:80b0:7000::2/64";
              link = { state = "up"; kind = "bridge"; };
            };
            "bond.${builtins.toString current.value.vlan}".link = {
              state = "up";
              kind = "vlan";
              link = "bond";
              vlan_id = current.value.vlan;
              master = current.value.bridge;
            };
          })
        { }
        (lib.attrsToList config.dd-ix.nets));
      routing.routes = [{
        to = "::/0";
        dev = "svc-management";
        via = "fe80::1";
      }];
    };
  };

  boot.initrd.network = {
    enable = true;

    ifstate = {
      enable = true;
      allowIfstateToDrasticlyIncreaseInitrdSize = true;
      inherit (config.networking.ifstate) settings;
    };

    ssh = {
      enable = true;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
    };

    postCommands = ''
      zpool import -a
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };
}
