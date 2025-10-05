{ self, config, pkgs, ... }:

{
  sops.secrets."uptime_kuma_push_token" = {
    sopsFile = self + /secrets/ixp/as112.yaml;
  };

  systemd.services.ddix-as112-healthcheck = {
    script = builtins.readFile ./check-health.sh;
    # every 10 min
    startAt = "*:0/10";
    path = [
      config.services.knot.package
      pkgs.curl
    ];
    serviceConfig = {
      Type = "oneshot";
      inherit (config.systemd.services.knot.serviceConfig) User Group;
      LoadCredential = [
        "uptime_kuma_push_token:${config.sops.secrets."uptime_kuma_push_token".path}"
      ];
    };
  };
}
