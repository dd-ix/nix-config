{ lib, config, pkgs, ... }:

{
  imports = [
    ./bind.nix
  ];

  dd-ix = {
    hostName = "svc-ns01";

    microvm = {
      mem = 1 * 1024;
      vcpu = 2;
    };

    monitoring = {
      enable = true;
    };
  };

  users.users.ixp-deploy = {
    isNormalUser = true;
    openssh.authorizedKeys = {
      keys = [
        # arouteserver@svc-adm01
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
      ] ++ config.users.users.root.openssh.authorizedKeys.keys;
    };
  };

  # https://wiki.nixos.org/wiki/Sudo
  security.sudo = {
    enable = true;

    execWheelOnly = lib.mkForce false;
    extraRules = [{
      commands = [{
        command = "/run/current-system/sw/bin/systemctl reload bind.service";
        options = [ "NOPASSWD" ];
      }];
      users = [ "ixp-deploy" ];
    }];
  };

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
