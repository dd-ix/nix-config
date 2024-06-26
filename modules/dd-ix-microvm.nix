{ lib, config, options, ... }:
let
  cfg = config.dd-ix.microvm;
in
{
  options = {
    dd-ix = {

      microvm = {
        enable = lib.mkEnableOption (lib.mkDoc "Whether to enable microvm settings.");

        vcpu = options.microvm.vcpu;
        mem = options.microvm.mem;


        mac = lib.mkOption {
          type = lib.types.str;
        };

        vlan = lib.mkOption {
          type = lib.types.str; #lib.types.oneOf [ "i" "s" "l" ];
        };

        v6Addr = lib.mkOption {
          type = lib.types.str;
        };

        v4Addr = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    microvm = {
      hypervisor = "cloud-hypervisor";
      vcpu = cfg.vcpu;
      mem = cfg.mem;

      interfaces = [{
        type = "tap";
        id = "${cfg.vlan}-${config.dd-ix.hostName}";
        mac = cfg.mac;
      }];

      shares = [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "store";
          proto = "virtiofs";
          socket = "store.socket";
        }
        {
          source = "/var/lib/microvms/${config.dd-ix.hostName}/etc";
          mountPoint = "/etc";
          tag = "etc";
          proto = "virtiofs";
          socket = "etc.socket";
        }
        {
          source = "/var/lib/microvms/${config.dd-ix.hostName}/var";
          mountPoint = "/var";
          tag = "var";
          proto = "virtiofs";
          socket = "var.socket";
        }
      ];
    };

    networking.ifstate = {
      enable = true;
      settings = {
        interfaces = [{
          name = "eth0";
          addresses = [ cfg.v6Addr ]
            ++ (lib.optional (cfg.v4Addr != null) cfg.v4Addr);
          link = {
            state = "up";
            kind = "physical";
            address = cfg.mac;
          };
        }];
        routing.routes = [{ to = "::/0"; dev = "eth0"; via = "fe80::1"; }]
          ++ (lib.optional (cfg.v4Addr != null) {
          to = "0.0.0.0/0";
          dev = "eth0";
          via = if cfg.vlan == "s" then "10.96.1.1" else "212.111.245.177";
        });
      };
    };
  };
}
