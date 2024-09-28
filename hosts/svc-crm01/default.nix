{ ... }: {
  imports = [
    ./configuration.nix
    ../../modules/management/odoo.nix
  ];
}
