{ ... }: {
  imports = [
    ./configuration.nix
    ./bird.nix
    ../../modules/ixp/as112.nix
  ];
}
