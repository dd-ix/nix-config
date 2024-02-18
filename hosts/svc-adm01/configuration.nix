{ self, config, pkgs, ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-adm01";
      mac = "42:df:f0:70:02:02";
      vlan = "a";

      v6Addr = "2a01:7700:80b0:7002::2/64";
    };
  };

  environment.variables.AROUTESERVER_WORKDIR = "/var/lib/arouteserver";

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
      host = "mta.dd-ix.net";
      from = "noreply@svc-adm01.dd-ix.net";
      user = "";
      password = "";
    };
  };

  systemd.services = {
    arouteserver = {
      enable = true;
      script = ''
        echo noop
      '';
      # every day 01:15
      startAt = "*-*-* 01:15:00";
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "arouteserver";
        WorkingDirectory = "%t/arouteserver";
        User = "arouteserver";
        LoadCredential = "config.yaml:${config.sops.secrets.arouteserver_config.path}";
        Environment = "CONFIG_PATH=%d/config.yaml";
      };
      unitConfig.OnFailure = "notify-arouteserver-failed.service";
    };
    notify-arouteserver-failed = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
        User = "restic-backup-failed";
        DynamicUser = true;
      };
      script = ''
        echo -e "Content-Type: text/plain; charset=UTF-8\r\nSubject: [DD-IX-AROUTESERVER] routeserver deployment failed\r\n\r\narouteserver deployment:\n\n$(systemctl status --full arouteserver)" | ${pkgs.msmtp}/bin/sendmail marcel.koch@dd-ix.net
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    git
    fping
    inetutils
    mc
    vim
    arouteserver
  ];

  system.stateVersion = "23.11";
}
