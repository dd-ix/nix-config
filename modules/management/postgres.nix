{ lib, config, pkgs, ... }:
let
  cfg = config.services.postgresql;

  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/databases/postgresql.nix#L7-L21
  postgresql =
    let
      base = if cfg.enableJIT && !cfg.package.jitSupport then cfg.package.withJIT else cfg.package;
    in
    if cfg.extraPlugins == [ ]
    then base
    else base.withPackages (_: cfg.extraPlugins);

  startPostgres = pkgs.writeShellScript "postgres.sh" ''
    ${postgresql}/bin/postgres \
      -c ssl_cert_file=''${CREDENTIALS_DIRECTORY}/fullchain.pem \
      -c ssl_key_file=''${CREDENTIALS_DIRECTORY}/key.pem
  '';
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    settings = {
      ssl = true;
    };
  };

  systemd.services.postgresql.serviceConfig = {
    ExecStart = lib.mkForce "${startPostgres}/bin/postgres.sh";
    LoadCredential = [
      "fullchain.pem:${config.security.acme.certs."svc-pg01.dd-ix.net".directory}/fullchain.pem"
      "key.pem:${config.security.acme.certs."svc-pg01.dd-ix.net".directory}/key.pem"
    ];
  };
}
