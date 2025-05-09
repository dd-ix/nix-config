{ lib, pkgs, config, options, ... }:

let
  cfg = config.dd-ix.microvm;
in
{
  options.dd-ix.microvm = {
    enable = lib.mkEnableOption "Whether to enable microvm settings.";

    inherit (options.microvm) vcpu mem;

    v4Addr = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    microvm = {
      hypervisor = "cloud-hypervisor";

      inherit (cfg) vcpu mem;

      interfaces = [{
        type = "tap";
        id = "vm-${config.networking.hostName}";
        inherit (config.dd-ix.host.networking) mac;
      }];

      virtiofsd.threadPoolSize = 16;

      binScripts.tap-up = lib.mkAfter ''
        ${lib.getExe' pkgs.iproute2 "ip"} link set dev 'vm-${config.networking.hostName}' master '${config.dd-ix.nets.${config.dd-ix.host.networking.net}.bridge}'
      '';

      shares = [
        {
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "store";
          proto = "virtiofs";
          socket = "store.socket";
        }
        {
          source = "/var/lib/microvms/${config.networking.hostName}/etc";
          mountPoint = "/etc";
          tag = "etc";
          proto = "virtiofs";
          socket = "etc.socket";
        }
        {
          source = "/var/lib/microvms/${config.networking.hostName}/var";
          mountPoint = "/var";
          tag = "var";
          proto = "virtiofs";
          socket = "var.socket";
        }
      ];
    };

    networking = {
      hosts = {
        # needed for callobara online
        "${config.dd-ix.host.networking.addr}" = [ config.networking.fqdn ];
      };
      ifstate = {
        enable = true;
        settings = {
          interfaces = [{
            name = "eth0";
            addresses = [ "${config.dd-ix.host.networking.addr}/${builtins.toString config.dd-ix.nets.${config.dd-ix.host.networking.net}.cidr}" ]
              ++ (lib.optional (cfg.v4Addr != null) cfg.v4Addr);
            link = {
              state = "up";
              kind = "physical";
              address = config.dd-ix.host.networking.mac;
            };
          }];
          routing.routes = [{ to = "::/0"; dev = "eth0"; via = "fe80::1"; }]
            ++ (lib.optional (cfg.v4Addr != null) {
            to = "0.0.0.0/0";
            dev = "eth0";
            via = if config.dd-ix.host.networking.net == "services" then "10.96.1.1" else "212.111.245.177";
          });
        };
      };
    };
  };
}
