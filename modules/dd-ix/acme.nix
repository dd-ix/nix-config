{ self, lib, config, ... }:
let
  cfg = config.dd-ix.acme;
in
{
  options.dd-ix.acme = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        group = lib.mkOption {
          type = lib.types.str;
          default = config.security.acme.defaults.group;
        };
      };
    });
    default = [ ];
  };

  config = lib.mkMerge [
    {
      security.acme = {
        acceptTerms = true;
        defaults.email = "noc@dd-ix.net";
      };
    }
    (lib.mkIf ((lib.length cfg) != 0) {

      sops.secrets = lib.listToAttrs (map
        (domain: {
          name = "rfc2136_${domain.name}";
          value = {
            sopsFile = self + "/secrets/management/rfc2136/${domain.name}.yaml";
            owner = "root";
          };
        })
        cfg);

      security.acme.certs = lib.listToAttrs (map
        (domain: {
          name = "${domain.name}";
          value = {
            dnsProvider = "rfc2136";
            group = domain.group;
            credentialsFile = config.sops.secrets."rfc2136_${domain.name}".path;
          };
        })
        cfg);

      systemd.services = lib.listToAttrs (map
        (domain: {
          name = "acme-${domain.name}";
          value.environment = lib.mkIf config.dd-ix.useFpx {
            http_proxy = config.networking.proxy.httpProxy;
            https_proxy = config.networking.proxy.httpsProxy;
          };
        })
        cfg);
    })
  ];
}
