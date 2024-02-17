{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/node-red.nix
  ];
}
