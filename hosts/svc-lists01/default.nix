{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/mailman.nix
  ];
}
