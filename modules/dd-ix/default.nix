{ ... }:
{
  imports = [
    ./base.nix
    ./cleanup.nix
    ./general-options.nix
    ./dns.nix
    ./networking.nix
    ./time.nix
    ./acme.nix
    ./fpx.nix
    ./rpx.nix
    ./postgres.nix
    ./nginx.nix
    ./restic.nix
    ./mariadb.nix
    ./monitoring.nix
  ];
}
