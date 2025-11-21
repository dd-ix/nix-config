{ self, lib, config, pkgs, ... }:
let
  systems = lib.attrValues self.nixosConfigurations;
  users = lib.flatten (map (system: system.config.dd-ix.postgres) systems);
in
{
  sops.secrets = lib.listToAttrs (map
    (user: {
      name = "postgres_${user}";
      value = {
        sopsFile = self + "/secrets/management/postgres/postgres.yaml";
        owner = config.systemd.services.postgresql.serviceConfig.User;
      };
    })
    users);

  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    authentication = lib.mkForce ''
      local   all all              peer
      host    all all 127.0.0.1/8  md5
      host    all all ::1/128      md5
      hostssl all all 0.0.0.0/0    md5
      hostssl all all ::/0         md5
    '';
    ensureDatabases = users;
    ensureUsers = map
      (user: {
        name = user;
        ensureDBOwnership = true;
        ensurePasswordFile = config.sops.secrets."postgres_${user}".path;
      })
      users;
    settings = {
      ssl = true;
    };
  };

  systemd.services.postgresql.serviceConfig = {
    ExecStart = lib.mkForce (
      pkgs.writeShellScript "postgres.sh" ''
        exec ${config.services.postgresql.finalPackage}/bin/postgres \
          -c ssl_cert_file=''${CREDENTIALS_DIRECTORY}/fullchain.pem \
          -c ssl_key_file=''${CREDENTIALS_DIRECTORY}/key.pem
      ''
    );
    LoadCredential = [
      "fullchain.pem:${config.security.acme.certs."svc-pg01.dd-ix.net".directory}/fullchain.pem"
      "key.pem:${config.security.acme.certs."svc-pg01.dd-ix.net".directory}/key.pem"
    ];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = users;
  };
}
