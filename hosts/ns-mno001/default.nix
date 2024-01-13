{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/bind.nix
  ];
}
