{ self, lib, config, pkgs, ... }:

let
  defaultSnmpConfig = builtins.fetchurl {
    # last update: 2025-03-31
    url = "https://raw.githubusercontent.com/prometheus/snmp_exporter/3983af3304147ae54e63671cc3c0acd6cdc39664/snmp.yml";
    sha256 = "sha256:1dyggchank04jf9vdvhc00ylxdi8fl7mwww18zyfv7iaibfgkvy6";
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
