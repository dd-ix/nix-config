{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/netbox.nix
  ];
}
