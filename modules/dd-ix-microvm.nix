{ lib, config, options, ... }:
let
  cfg = config.dd-ix.microvm;
in
{
  options = {
    dd-ix.microvm = {
      enable = lib.mkEnableOption (lib.mkDoc "Whether to enable microvm settings.");

      vcpu = options.microvm.vcpu;
      mem = options.microvm.mem;

      hostName = options.networking.hostName;

      mac = lib.mkOption {
        type = lib.types.str;
      };

      vlan = lib.mkOption {
        type = lib.types.str; #lib.types.oneOf [ "inet" "srv" ];
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

  config = lib.mkIf cfg.enable {
    microvm = {
      hypervisor = "cloud-hypervisor";
      mem = 2048;
      vcpu = 2;

      interfaces = [{
        type = "tap";
        id = "vm-${cfg.vlan}-${cfg.hostName}";
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
          source = "/var/lib/microvms/${cfg.hostName}-mno001/etc";
          mountPoint = "/etc";
          tag = "etc";
          proto = "virtiofs";
          socket = "etc.socket";
        }
        {
          source = "/var/lib/microvms/${cfg.hostName}-mno001/var";
          mountPoint = "/var";
          tag = "var";
          proto = "virtiofs";
          socket = "var.socket";
        }
      ];
    };

    networking = {
      hostName = cfg.hostName;
      domain = "dd-ix.net";
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
        routing.routes = [{ to = "::/0"; dev = "eth0"; via = "fe80::defa"; }]
          ++ (lib.optional (cfg.v4Addr != null) { to = "0.0.0.0/0"; dev = "eth0"; via = "212.111.245.177"; });
      };
    };
  };
}
