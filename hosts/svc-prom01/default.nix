{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/prometheus.nix
  ];
}
