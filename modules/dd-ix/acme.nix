{ self, lib, config, ... }:
let
  cfg = config.dd-ix.acme;
in
{
  options.dd-ix.acme = {
    enable = lib.mkEnableOption (lib.mkDoc "Whether to enable dd-ix acme settings.");

    domain = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."rfc2136_${cfg.domain}" = {
      sopsFile = self + "/secrets/management/rfc2136/${cfg.domain}.yaml";
      owner = "root";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "noc@dd-ix.net";

      certs."${cfg.domain}" = {
        dnsProvider = "rfc2136";
        credentialsFile = config.sops.secrets."rfc2136_${cfg.domain}".path;
      };
    };

    systemd.services."acme-${cfg.domain}".environment = lib.mkIf config.dd-ix.useFpx {
      http_proxy = config.networking.proxy.httpProxy;
      https_proxy = config.networking.proxy.httpsProxy;
    };
  };
}
