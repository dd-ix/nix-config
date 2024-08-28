{ ... }:
{
  dd-ix = {
    hostName = "svc-ns01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "a2:18:9f:dc:4d:16";
      vlan = "i";

      v6Addr = "2a01:7700:80b0:6000::53/64";
    };

    monitoring = {
      enable = true;
    };
  };

  users.users.ixp-deploy = {
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

  system.stateVersion = "23.11";
}
