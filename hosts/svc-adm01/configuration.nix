{ self, config, pkgs, ... }:
let
  ddix-ansible-bird = pkgs.fetchFromGitHub {
    owner = "dd-ix";
    repo = "ddix-ansible-bird";
    rev = "ad23d8857aded93b32a8940529ff551c313d9623";
    hash = "sha256-cVLYlcAHtYuxMRAxV558Lw76QVCHkOKa35KJnZ3MjU8=";
  };
  ddix-bird-build = pkgs.writeShellScriptBin "ddix-bird-build" ''
    cd ${ddix-ansible-bird}/plays
    exec ${pkgs.ansible}/bin/ansible-playbook build.yml $@
  '';
  ddix-bird-push = pkgs.writeShellScriptBin "ddix-bird-push" ''
    cd ${ddix-ansible-bird}/plays
    exec ${pkgs.ansible}/bin/ansible-playbook push.yml $@
  '';
in

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
        echo [DD-IX] building bird config
        ${ddix-bird-build}/bin/ddix-bird-build
        echo [DD-IX] deploying bird config
        ${ddix-bird-push}/bin/ddix-bird-push
      '';
      path = with pkgs; [
        arouteserver
        bgpq4
        openssh
      ];
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
    bgpq4
    arouteserver
    ddix-bird-build
    ddix-bird-push
  ];

  system.stateVersion = "23.11";
}
