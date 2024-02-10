{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/vaultwarden.nix
  ];
}
