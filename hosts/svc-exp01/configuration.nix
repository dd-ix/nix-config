{ pkgs, ... }:
{
  dd-ix = {
    hostName = "svc-exp01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      mac = "d2:7b:c0:b2:42:0f";
      vlan = "im";

      v6Addr = "2a01:7700:80b0:4101::3/64";
    };

    monitoring = {
      enable = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 6343 ];
  networking.firewall.allowedTCPPorts = [ 9144 ];

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

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
