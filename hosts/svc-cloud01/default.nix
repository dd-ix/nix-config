{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/nextcloud.nix
  ];
}
