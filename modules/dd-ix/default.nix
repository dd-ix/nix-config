{ ... }:
{
  imports = [
    ./base.nix
    ./general-options.nix
    ./dns.nix
    ./time.nix
    ./acme.nix
    ./fpx.nix
    ./rpx.nix
    ./postgres.nix
    ./nginx.nix
    ./restic.nix
    ./mariadb.nix
    ./monitoring.nix
    ./redis.nix
  ];
}
