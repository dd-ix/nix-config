{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/weblate.nix
  ];
}
