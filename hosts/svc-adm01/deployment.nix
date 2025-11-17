{ self, lib, config, pkgs, ... }:

{
  environment.variables = {
    AROUTESERVER_WORKDIR = "/var/lib/arouteserver";
    AROUTESERVER_SECRETS_FILE = config.sops.secrets.arouteserver_config.path;
  };

  users.users.arouteserver = {
    isNormalUser = true;
  };

  programs.ssh.knownHosts = {
    "svc-exp01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBnoPxmjrJWHWmlToNgGkcJ7CF3PChqoAqF61DhJZOI";
      extraHostNames = [ "2a01:7700:80b0:4101::3" ];
    };
    "ixp-rs01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjPKbIa2hwA+GQiJdYeMyhgMu5qZBz7bUw2ftEtrhsu";
      extraHostNames = [ "2a01:7700:80b0:4001::2" ];
    };
    "ixp-rs02.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYzxiWCG/wN52qVAtCInWveri6NWKKChNgpEIaszz0g";
      extraHostNames = [ "2a01:7700:80b0:4002::2" ];
    };
    "ixp-c2-sw01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXbqgEwymEUJTpjwrHZb0fIZAfDrxqrmDRw7aRu7pl8";
      extraHostNames = [ "2a01:7700:80b0:4000::2" ];
    };
    "ixp-cc-sw01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJobOPBbwEh35mw/E2rOY/8wNJpMZgBXLI5sPOeXoVt2";
      extraHostNames = [ "2a01:7700:80b0:4000::1" ];
    };
    "svc-web01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTMSvzHkyiY58yZGu8F0016QhTI0rYdyyLu8HJY0CdT";
      extraHostNames = [ "2a01:7700:80b0:6001::13" ];
    };
    "svc-ns01.dd-ix.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGB4Br/o28AzkE6cPzjQCGs1TE4Ii0lGFVVFY/TWunee";
      extraHostNames = [ "2a01:7700:80b0:6000::53" ];
    };
    "con-ddix-lab.ibh.net" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONsjsqz+S/G6hzN+yZNTiPdfaj+u7lDJUve88geo/M6";
      extraHostNames = [ "2a01:7700:8fe0:8::2" ];
    };
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
      # NOTE: workaround because RemainAfterExit does not work with timers
      ddix-ixp-build-trigger = {
        enable = true;
        # every 4 hours
        startAt = "00/4:07";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "systemctl restart ddix-ixp-build";
        };
      };

      # build configs
      ddix-ixp-build = {
        enable = true;
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-deploy} -D -t sflow_build,bird_build,eos_build,rdns_build";
          RemainAfterExit = "yes";
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
        # every 4 hours
        startAt = "03/4:20";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-deploy-sw@ixp-cc-sw01.dd-ix.net" = {
        # every 4 hours
        startAt = "03/4:30";
        overrideStrategy = "asDropin";
      };

      # save configs
      "ddix-ixp-commit@" = {
        enable = true;
        serviceConfig = serviceConfig // {
          ExecStart = "${lib.getExe pkgs.ddix-ixp-commit} -D -l %i";
        };
        unitConfig = {
          ConditionPathExists = "!/var/lib/arouteserver/kill/%i";
          OnFailure = "ddix-ixp-commit-failed@%i.service";
        };
      };
      "ddix-ixp-commit-failed@%i" = mkFailureUnit { name = "$DEVICE_NAME commit"; prefix = "COMMIT"; unit = "ddix-ixp-commit@$DEVICE_NAME"; } // {
        environment.DEVICE_NAME = "%i";
      };
      "ddix-ixp-commit@ixp-rs01.dd-ix.net" = {
        startAt = "22:00";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-commit@ixp-rs02.dd-ix.net" = {
        startAt = "22:00";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-commit@ixp-c2-sw01.dd-ix.net" = {
        startAt = "22:00";
        overrideStrategy = "asDropin";
      };
      "ddix-ixp-commit@ixp-cc-sw01.dd-ix.net" = {
        startAt = "22:00";
        overrideStrategy = "asDropin";
      };
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
}
