{ self, lib, config, pkgs, ... }:

let
  defaultSnmpConfig = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/prometheus/snmp_exporter/main/snmp.yml";
    sha256 = "sha256:16w3zgi8dgwx72a47y8qywxg6dfs0p032v233m8vrn2f5biy5n25";
  };
  preStartScript = pkgs.writeShellApplication {
    name = "prometheus-snmp-exporter-pre-start";
    runtimeInputs = with pkgs; [ yq-go ];
    text = /* bash */ ''
      yq eval \
        ". * {\"auths\": {\"public_v2\": { \"community\": \"$(cat "''${SNMP_COMMUNITY_FILE}")\" }}}" \
        ${defaultSnmpConfig} > /run/prometheus-snmp-exporter/config.yaml
    '';
  };
in
{
  sops.secrets = {
    "snmp_exporter/community" = {
      sopsFile = self + "/secrets/management/exp.yaml";
    };
  };

  services.prometheus.exporters.snmp = {
    enable = true;
    enableConfigCheck = false;
    configurationPath = "/run/prometheus-snmp-exporter/config.yaml";
    openFirewall = true;
  };

  systemd.services.prometheus-snmp-exporter = {
    environment.SNMP_COMMUNITY_FILE = "%d/snmp_community";

    serviceConfig = {
      RuntimeDirectory = "prometheus-snmp-exporter";
      RuntimeDirectoryMode = "0700";
      ExecStartPre = lib.getExe preStartScript;
      LoadCredential = [
        "snmp_community:${config.sops.secrets."snmp_exporter/community".path}"
      ];
    };
  };
}
