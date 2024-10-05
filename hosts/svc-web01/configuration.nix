{ pkgs, ... }:
let
  addr = "2a01:7700:80b0:6001::13";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-web01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "82:5a:db:e0:53:63";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [
      {
        name = "dd-ix.net";
        group = "nginx";
      }
      {
        name = "www.dd-ix.net";
        group = "nginx";
      }
      {
        name = "content.dd-ix.net";
        group = "nginx";
      }
      {
        name = "talks.dd-ix.net";
        group = "nginx";
      }
    ];

    rpx = {
      domains = [ "dd-ix.net" "www.dd-ix.net" "content.dd-ix.net" "talks.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    monitoring = {
      enable = true;
    };
  };

  users.users.ddix-deploy = {
    isNormalUser = true;
    openssh.authorizedKeys = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
      ];
      keyFiles = [
        ../../keys/ssh/tassilo
        ../../keys/ssh/melody
        ../../keys/ssh/fiasko
        ../../keys/ssh/marcel
        ../../keys/ssh/adb
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
