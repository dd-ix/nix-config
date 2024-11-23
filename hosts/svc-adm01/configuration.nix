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

  systemd.services = {
    ddix-ixp-deploy = {
      enable = true;
      script = ''
        echo [DD-IX] run ixp deployment
        ${lib.getExe pkgs.ddix-ixp-deploy} -D -e engage_config=true
      '';
      # every 6 hours
      startAt = "00/6:20";
      serviceConfig = {
        Type = "oneshot";
        User = "arouteserver";
        Environment = [
          "AROUTESERVER_WORKDIR=/var/lib/arouteserver"
          "AROUTESERVER_SECRETS_FILE=${config.sops.secrets.arouteserver_config.path}"
        ];
      };
      unitConfig.OnFailure = "notify-ddix-ixp-deploy-failed.service";
    };
    ddix-ixp-commit = {
      enable = true;
      script = ''
        echo [DD-IX] run ixp commit
        ${lib.getExe pkgs.ddix-ixp-commit} -D
      '';
      startAt = "22:00";
      serviceConfig = {
        Type = "oneshot";
        User = "arouteserver";
        Environment = [
          "AROUTESERVER_WORKDIR=/var/lib/arouteserver"
          "AROUTESERVER_SECRETS_FILE=${config.sops.secrets.arouteserver_config.path}"
        ];
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
