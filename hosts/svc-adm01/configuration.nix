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
        RemainAfterExit = "yes";
      };
      mkFailureUnit = { name, prefix, unit }: {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          User = "ddix-ixp-failed-notification";
          DynamicUser = true;
        };
        script = ''
          echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-${prefix}] ${name} failed\r\n\r\ndeployment logs:\n\n$(journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value ${unit}`)" | ${lib.getExe pkgs.msmtp} noc@dd-ix.net
        '';
      };
    in
    {
      # build configs
      ddix-ixp-build = {
        enable = true;
        # every 4 hours
        startAt = "00/4:07";
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -t sflow_build,bird_build,eos_build,rdns_build";
        };
        unitConfig.OnFailure = "ddix-ixp-build-failed.service";
      };
      ddix-ixp-build-failed = mkFailureUnit { name = "build"; prefix = "BUILD"; unit = "ddix-ixp-build"; };

      # deploy rdns service
      ddix-ixp-deploy-rdns = {
        enable = true;
        # every 4 hours
        startAt = "03/4:15";
        after = [ "ddix-ixp-build.service" ];
        bindsTo = [ "ddix-ixp-build.service" ];
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t rdns_push,rdns_engage";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/rdns";
          OnFailure = "ddix-ixp-deploy-rdns-failed.service";
        };
      };
      ddix-ixp-deploy-rdns-failed = mkFailureUnit { name = "rdns deploy"; prefix = "DEPLOY"; unit = "ddix-ixp-deploy-rdns"; };

      # deploy sflow service
      ddix-ixp-deploy-sflow = {
        enable = true;
        # every 4 hours
        startAt = "03/4:15";
        after = [ "ddix-ixp-build.service" ];
        bindsTo = [ "ddix-ixp-build.service" ];
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t sflow_push";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/sflow";
          OnFailure = "ddix-ixp-deploy-sflow-failed.service";
        };
      };
      ddix-ixp-deploy-sflow-failed = mkFailureUnit { name = "sflow deploy"; prefix = "DEPLOY"; unit = "ddix-ixp-deploy-sflow"; };

      # deploy route server configs
      "ddix-ixp-deploy-rs@" = {
        after = [ "ddix-ixp-build.service" ];
        bindsTo = [ "ddix-ixp-build.service" ];
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t bird_push,bird_engage -l %i,";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/%i";
          OnFailure = "ddix-ixp-deploy-rs-failed@%i.service";
        };
      };
      "ddix-ixp-deploy-rs-failed@" = mkFailureUnit { name = "rs$ROUTE_SERVER_NAME deploy"; prefix = "DEPLOY"; unit = "ddix-ixp-deploy-rs@$ROUTE_SERVER_NAME"; } // {
        environment.ROUTE_SERVER_NAME = "%i";
      };

      "ddix-ixp-deploy-rs@ixp-rs01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "00/4:30";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-deploy-rs@ixp-rs02.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "02/4:30";
        overrideStrategy = "asDropin";
      };

      # deploy switches
      "ddix-ixp-deploy-sw@" = {
        after = [ "ddix-ixp-build.service" ];
        bindsTo = [ "ddix-ixp-build.service" ];
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true -t eos_push,eos_engage -l localhost,%i";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/%i";
          OnFailure = "ddix-ixp-deploy-sw-failed@%i.service";
        };
      };
      "ddix-ixp-deploy-sw-failed@" = mkFailureUnit { name = "rs$SWITCH_NAME deploy"; prefix = "DEPLOY"; unit = "ddix-ixp-deploy-sw@$SWITCH_NAME"; } // {
        environment.SWITCH_NAME = "%i";
      };
      "ddix-ixp-deploy-sw@ixp-c2-sw01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:20";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-deploy-sw@ixp-cc-sw01.dd-ix.net" = {
        enable = true;
        # every 4 hours
        startAt = "03/4:30";
        overrideStrategy = "asDropin";
      };

      # save configs
      ddix-ixp-commit = {
        enable = true;
        startAt = "22:00";
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-commit} -D";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/commit";
          OnFailure = "ddix-ixp-commit-failed.service";
        };
      };
      ddix-ixp-commit-failed = mkFailureUnit { name = "commit"; prefix = "COMMIT"; unit = "ddix-ixp-commit"; };
    };

  environment.systemPackages =
    let
      ddix-ixp-ctl = pkgs.writeShellApplication {
        name = "ddix-ixp-ctl";

        # NOTE: add dependencies as needed
        # runtimeInputs = with pkgs; [ ];

        text = builtins.readFile (self + /resources/ddix-ixp-ctl.sh);
      };
    in
    with pkgs; [
      git
      fping
      inetutils
      mc
      vim
      net-snmp
      ddix-ixp-ctl
    ];

  system.stateVersion = "23.11";
}
