{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/mariadb.nix
  ];
}
