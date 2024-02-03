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
  ];
}
