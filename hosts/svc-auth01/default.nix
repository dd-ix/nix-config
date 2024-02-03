{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/authentik.nix
  ];
}
