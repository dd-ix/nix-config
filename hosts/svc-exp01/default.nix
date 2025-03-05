{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/sflow_exporter.nix
    ../../modules/obs/snmp_exporter.nix
  ];
}
