{ self, lib, config, pkgs, ... }:
{
  dd-ix = {
    hostName = "svc-adm01";

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;
    };
    monitoring = {
      enable = true;
    };
  };

  environment.variables = {
    AROUTESERVER_WORKDIR = "/var/lib/arouteserver";
    AROUTESERVER_SECRETS_FILE = config.sops.secrets.arouteserver_config.path;
  };

  users.users.arouteserver = {
    isNormalUser = true;
  };

  sops.secrets = {
    arouteserver_config = {
      sopsFile = self + "/secrets/management/adm.yaml";
      owner = "arouteserver";
    };
    arouteserver_ssh_priv_key = {
      sopsFile = self + "/secrets/management/adm.yaml";
      mode = "0400";
      path = "/home/arouteserver/.ssh/id_ed25519";
      owner = "arouteserver";
    };
    arouteserver_ssh_known_hosts = {
      sopsFile = self + "/secrets/management/adm.yaml";
      mode = "0400";
      path = "/home/arouteserver/.ssh/known_hosts";
      owner = "arouteserver";
    };
  };

  programs.msmtp = {
    enable = true;
    accounts.default = {
      host = "svc-mta01.dd-ix.net";
      from = "noreply@svc-adm01.dd-ix.net";
      user = "";
      password = "";
    };
  };

  systemd.services =
    let
      serviceConfig = {
        Type = "oneshot";
        User = "arouteserver";
        Environment = [
          "AROUTESERVER_WORKDIR=/var/lib/arouteserver"
          "AROUTESERVER_SECRETS_FILE=${config.sops.secrets.arouteserver_config.path}"
        ];
      };
    in
    {
      # build configs
      "ddix-ixp-build" = {
        enable = true;
        script = ''
          echo [DD-IX] run IXP route server config build
          exec ${lib.getExe pkgs.ddix-ixp-deploy} -D -t sflow_build,bird_build,eos_build,rdns_build
        '';
        # every 4 hours
        startAt = "00/4:07";
        inherit serviceConfig;
        unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
      };

      # deploy rdns service
      "ddix-ixp-rdns" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:15";
        after = [ "ddix-ixp-build.service" ];
        requisite = [ "ddix-ixp-build.service" ];
        script = ''
          echo [DD-IX] run RDNS deployment
          exec ${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t rdns_push,rdns_engage
        '';
        serviceConfig = serviceConfig // {
          ConditionPathExists = "/var/lib/arouteserver/kill/rdns";
        };
        unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
      };

      # deploy sflow service
      "ddix-ixp-sflow" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:15";
        after = [ "ddix-ixp-build.service" ];
        requisite = [ "ddix-ixp-build.service" ];
        script = ''
          echo [DD-IX] run sflow deployment
          exec ${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t sflow_push
        '';
        serviceConfig = serviceConfig // {
          ConditionPathExists = "/var/lib/arouteserver/kill/sflow";
        };
        unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
      };

      # deploy route server configs
      "ddix-ixp-rs@" = {
        after = [ "ddix-ixp-build.service" ];
        requisite = [ "ddix-ixp-build.service" ];
        script = ''
          echo [DD-IX] run IXP route server deployment
          exec ${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t bird_push,bird_engage -l %i,
        '';
        serviceConfig = serviceConfig // {
          conditionPathExists = "/var/lib/arouteserver/kill/%i";
        };
        unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
      };
      "ddix-ixp-rs@ixp-rs01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "00/4:30";
      };
      "ddix-ixp-rs@ixp-rs02.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "02/4:30";
      };

      # deploy switches
      "ddix-ixp-sw@" = {
        after = [ "ddix-ixp-build.service" ];
        requisite = [ "ddix-ixp-build.service" ];
        script = ''
          echo [DD-IX] run IXP switch deployment
          exec ${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t eos_push,eos_engage -l localhost,%i
        '';
        serviceConfig = serviceConfig // {
          ConditionPathExists = "/var/lib/arouteserver/kill/%i";
        };
        unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
      };
      "ddix-ixp-sw@ixp-c2-sw01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:20";
      };
      "ddix-ixp-sw@ixp-cc-sw01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:30";
      };

      # save configs
      "ddix-ixp-commit" = {
        enable = true;
        script = ''
          echo [DD-IX] run ixp commit
          exec ${lib.getExe pkgs.ddix-ixp-commit} -D
        '';
        startAt = "22:00";
        serviceConfig = serviceConfig // {
          ConditionPathExists = "/var/lib/arouteserver/kill/commit";
        };
        unitConfig.OnFailure = "notify-ddix-ixp-commit-failed.service";
      };
      notify-ddix-ixp-deploy-failed = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-DEPLOY] deployment failed\r\n\r\ndeployment logs:\n\n$(journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value ddix-ixp-deploy`)" | ${lib.getExe pkgs.msmtp} noc@dd-ix.net
        '';
      };
      notify-ddix-ixp-commit-failed = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-DEPLOY] commit failed\r\n\r\ndeployment logs:\n\n$(journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value ddix-ixp-commit`)" | ${lib.getExe pkgs.msmtp} noc@dd-ix.net
        '';
      };
    };

  environment.systemPackages = with pkgs; [
    git
    fping
    inetutils
    mc
    vim
    net-snmp
  ];

  system.stateVersion = "23.11";
}
