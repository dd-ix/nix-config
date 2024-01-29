{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/privoxy.nix
  ];
}
