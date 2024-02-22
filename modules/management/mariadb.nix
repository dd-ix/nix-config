{ self, lib, config, pkgs, ... }:
let
  systems = lib.attrValues self.nixosConfigurations;
  users = lib.flatten (map (system: system.config.dd-ix.mariadb) systems);
in
{
  sops.secrets = lib.listToAttrs (map
    (user: {
      name = "mari_${user}";
      value = {
        sopsFile = self + "/secrets/management/mari.yaml";
        owner = config.systemd.services.mysql.serviceConfig.User;
      };
    })
    users);

  networking.firewall.allowedTCPPorts = [ 3306 ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb_1011;
    settings.mysqld = {
      ssl_cert = "${config.security.acme.certs."svc-mari01.dd-ix.net".directory}/fullchain.pem";
      ssl_key = "${config.security.acme.certs."svc-mari01.dd-ix.net".directory}/key.pem";
#      require_secure_transport = true;
      skip-name-resolve = true;
    };
    ensureDatabases = users;
  };

  systemd.services.mysql.postStart = lib.mkMerge [
    (lib.concatMapStrings
      (user:
        ''
          ( echo "DROP USER IF EXISTS '${user}'@'%';"
            echo "CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY \"''$(cat ${config.sops.secrets."mari_${user}".path})\";"
            echo "GRANT ALL PRIVILEGES ON ${user}.* TO '${user}'@'%';"
          ) | ${config.services.mysql.package}/bin/mysql -N
        '')
      users)
  ];

  services.mysqlBackup = {
    enable = true;
    databases = users;
  };
}
