{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/sflow_exporter.nix
  ];
}
