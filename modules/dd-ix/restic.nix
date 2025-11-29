{ config, lib, pkgs, ... }:

let
  cfg = config.dd-ix.restic;
in
{
  options.dd-ix.restic = {
    enable = lib.mkEnableOption (lib.mdDoc "dd-ix restic");
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "restic/pw".owner = "root";
      "restic/repo".owner = "root";
    };

    services.restic.backups."data" = {
      initialize = true;

      passwordFile = config.sops.secrets."restic/pw".path;
      repositoryFile = config.sops.secrets."restic/repo".path;

      inherit (cfg) paths;

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

    systemd.services."restic-backups-data".unitConfig.OnFailure = "notify-backup-failed.service";

    programs.msmtp = {
      enable = true;
      accounts.default = {
        host = "svc-mta01.dd-ix.net";
        from = "noreply@svc-hv01.dd-ix.net";
        user = "";
        password = "";
      };
    };

    systemd.services."notify-backup-failed" = {
      enable = true;
      description = "Notify on failed backup ${config.networking.fqdn}";

      serviceConfig.Type = "oneshot";

      script = ''
        echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-BACKUP] Backup job ${config.networking.fqdn} failed\r\n\r\nBackup job ${config.networking.fqdn} failed:\n\n$(journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-data`)" | ${lib.getExe pkgs.msmtp} noc@dd-ix.net
      '';
    };
  };
}
