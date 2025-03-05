{
  services.prometheus.exporters.snmp = {
    enable = true;
    configurationPath = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/prometheus/snmp_exporter/main/snmp.yml";
      sha256 = "sha256:16w3zgi8dgwx72a47y8qywxg6dfs0p032v233m8vrn2f5biy5n25";
    };
    openFirewall = true;
  };
}
