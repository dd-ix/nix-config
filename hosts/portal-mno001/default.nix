{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/ixp-manager.nix
  ];
}
