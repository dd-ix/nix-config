{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/pretix.nix
  ];
}
