{ pkgs, ... }:
let
  addr = "2a01:7700:80b0:6001::13";
  domains = [
    "dd-ix.net"
    "www.dd-ix.net"
    "content.dd-ix.net"
    "talks.dd-ix.net"
    "opening.dd-ix.net"
  ];
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

    acme = map (name: { inherit name; group = "nginx"; }) domains;

    rpx = {
      inherit domains;
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
        ../../keys/ssh/robort
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
