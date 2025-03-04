{ self, lib, config, pkgs, ... }:

let
  weathermap = pkgs.fetchFromGitHub {
    owner = "librenms-plugins";
    repo = "Weathermap";
    # master as of 04.03.2025
    rev = "ea57b454eb042408a6628fc3d8dff8176563547f";
    hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2W1=";
  };
in

{
  sops.secrets."nms_db_pass" = {
    sopsFile = self + /secrets/management/nms.yaml;
    owner = config.services.librenms.user;
  };

  services.librenms = {
    enable = true;
    package = pkgs.librenms.override {
      plugins = [{
        dir = weathermap;
        name = "Weathermap";
      }];
    };
    database = {
      host = "svc-mari01.dd-ix.net";
      port = 3306;
      username = "librenms";
      passwordFile = config.sops.secrets."nms_db_pass".path;
      database = "librenms";
    };
    settings = { };
    environmentFile = "";
    nginx = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "nms.${config.dd-ix.domain}";
    };
  };

  systemd = {
    services.librenms-weathermap-poller = {
      description = "LibreNMS Weathermap Poller";

      serviceConfig = {
        Type = "oneshot";
        inherit (config.systemd.services.librenms-scheduler.serviceConfig) WorkingDirectory User Group;
        ExecStart = "${lib.getExe config.services.librenms.package.passthru.phpPackage} plugins/Weathermap/map-poller.php";
      };
    };

    timers.librenms-scheduler = {
      description = "LibreNMS Weathermap Poller";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # every 5min
        OnCalendar = "*:0/5";
        AccuracySec = "1second";
      };
    };
  };
}
