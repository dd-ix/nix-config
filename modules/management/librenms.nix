{ self, lib, config, pkgs, ... }:

let
  weathermap = pkgs.stdenv.mkDerivation {
    pname = "librenms-weathermap";
    version = "2023-12-17-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "librenms-plugins";
      repo = "Weathermap";
      # master as of 04.03.2025
      rev = "ea57b454eb042408a6628fc3d8dff8176563547f";
      hash = "sha256-q+/j16FNVNseJMm1p7pj6YWX5RpGVp367+s/NChcxHo=";
    };

    postPatch = ''
      substituteInPlace weathermap.php \
        --replace-fail '/usr/bin/rrdtool' '${lib.getExe' pkgs.rrdtool "rrdtool"}'
    '';

    installPhase = ''
      mkdir $out
      mv * $out
      rm -rf $out/configs
      ln -s /var/lib/librenms-weathermap $out/configs
    '';
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

      locations."/plugins/Weathermap/" = {
        # taken from
        # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/monitoring/librenms.nix#L482C7-L483C62
        index = "index.php";
        tryFiles = "$uri $uri/ /index.php?$query_string";
        extraConfig = ''
          allow 2a01:7700:80b0:e000::/64;
          deny all;
        '';
      };
    };
  };

  systemd = {
    services.librenms-weathermap-poller = {
      description = "LibreNMS Weathermap Poller";

      path = [
        config.services.librenms.package.passthru.phpPackage
      ];

      serviceConfig = {
        Type = "oneshot";
        inherit (config.systemd.services.librenms-scheduler.serviceConfig) WorkingDirectory User Group;
        ExecStart = "${config.systemd.services.librenms-scheduler.serviceConfig.WorkingDirectory}/html/plugins/Weathermap/map-poller.php";
      };
    };

    timers.librenms-weathermap-poller = {
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
