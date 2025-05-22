{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/loki.nix
  ];
}
