{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/grafana.nix
  ];
}
