{
  imports = [
    ./anubis.nix
    ./base.nix
    ./general-options.nix
    ./dns.nix
    ./time.nix
    ./acme.nix
    ./fpx.nix
    ./postgres.nix
    ./nginx.nix
    ./restic.nix
    ./mariadb.nix
    ./monitoring.nix
    ./redis.nix
  ];

  boot.initrd.network.checkKernelModules.enable = false;
}
