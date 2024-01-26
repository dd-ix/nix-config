{ self, lib, config, ... }:
let
  cfg = config.dd-ix.acme;
in
{
  options = {
    enable = lib.mkEnableOption (lib.mkDoc "Whether to enable dd-ix acme settings.");

    domain = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkif cfg.enable {
    sops.secrets."rfc2136_${cfg.domain}_key" = {
      sopsFile = self + "/secrets/management/rfc2136/${cfg.domain}.yaml";
      owner = "root";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "noc@dd-ix.net";

      certs."${cfg.domain}" = {
        dnsProvider = "rfc2136";
        credentialsFile = config.sops.secrets."rfc2136_${cfg.domain}_key".path;
      };
    };
  };
}
