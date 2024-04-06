{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/obs/prometheus2.nix
  ];
}
