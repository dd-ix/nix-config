{ self, lib, config, options, ... }:

let
  mkMac = seed:
    let
      hash = builtins.hashString "md5" seed;
      c = off: builtins.substring off 2 hash;
    in
    "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";
  globalConfig = config;
in
{
  options.dd-ix = {
    nets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
        options = {
          netId = lib.mkOption {
            type = lib.types.str;
          };

          cidr = lib.mkOption {
            type = lib.types.int;
          };

          prefix = lib.mkOption {
            type = lib.types.str;
            default = "${config.netId}::/${builtins.toString config.cidr}";
          };

          vlan = lib.mkOption {
            type = lib.types.int;
          };

          #gw = {
          #  hostId = lib.mkOption {
          #    type = lib.types.str;
          #  };

           # addr = lib.mkOption {
           #   type = lib.types.str;
           #   default = "${config.netId}::${config.gw.hostId}";
           # };
          #};
        };
      }));
    };

    host = lib.mkOption {
      type = lib.types.submodule ({ name, config, ... }: {
        options = {
          fqdn = lib.mkOption {
            type = lib.types.str;
            default = "${name}.dd-ix.net";
          };

          mac = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = mkMac config.fqdn;
          };

          net = lib.mkOption {
            type = lib.types.enum (builtins.attrNames globalConfig.dd-ix.nets);
          };

          interfaceId = lib.mkOption {
            type = lib.types.str;
          };

          addr = lib.mkOption {
            type = lib.types.str;
            default = "${globalConfig.dd-ix.nets.${config.net}.netId}::${config.interfaceId}";
          };
        };
      });
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf options.dd-ix.host.type;
    };
  };

  imports =
    let
      hosts = builtins.attrNames (builtins.readDir (self + /hosts));
    in
    [
      ./nets.nix
    ]
    ++ (map (name: self + /hosts/${name}/data.nix) hosts);

  config = {
    dd-ix.host = config.dd-ix.hosts.${config.networking.hostName};
  };
}
