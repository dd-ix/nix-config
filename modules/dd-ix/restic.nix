{ self, config, lib, pkgs, ... }:
let
  cfg = config.dd-ix.restic;
in
{
  options.dd-ix.restic = {
    enable = lib.mkEnableOption (lib.mdDoc "dd-ix restic");
    name = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."restic_${cfg.name}/pw" = {
      sopsFile = self + "/secrets/management/restic/${cfg.name}.yaml";
      owner = "root";
    };

    sops.secrets."restic_${cfg.name}/repo" = {
      sopsFile = self + "/secrets/management/restic/${cfg.name}.yaml";
      owner = "root";
    };

    services.restic.backups."${cfg.name}" = {
      initialize = true;

      passwordFile = config.sops.secrets."restic_${cfg.name}/pw".path;
      repositoryFile = config.sops.secrets."restic_${cfg.name}/repo".path;

      paths = [
        "/etc/ssh"
        "/etc/nixos"
        "/var/lib"
      ];

      timerConfig = {
        OnCalendar = "00/12:20";
        Persistent = true;
      };

      pruneOpts = [ ];
      #pruneOpts = [
      #  "--keep-hourly 2"
      #  "--keep-daily 7"
      #  "--keep-weekly 5"
      #  "--keep-monthly 12"
      #  "--keep-yearly 5"
      #];
    };

    systemd.services."restic-backups-${cfg.name}".unitConfig.OnFailure = "notify-backup-failed-${cfg.name}.service";

    programs.msmtp = {
      enable = true;
      accounts.default = {
        host = "svc-mta01.dd-ix.net";
        from = "noreply@svc-hv01.dd-ix.net";
        user = "";
        password = "";
      };
    };

    systemd.services."notify-backup-failed-${cfg.name}" = {
      enable = true;
      description = "Notify on failed backup ${cfg.name}";

      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-BACKUP] Backup job ${cfg.name} failed\r\n\r\nBackup job ${cfg.name} failed:\n\n$(journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-${cfg.name}`)" | ${lib.getExe pkgs.msmtp} noc@dd-ix.net
      '';
    };
  };
}
