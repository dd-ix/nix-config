{ ... }:
{
  dd-ix = {
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-exp01";
      mac = "d2:7b:c0:b2:42:0f";
      vlan = "im";

      v6Addr = "2a01:7700:80b0:4101::3/64";
    };
  };

  networking.firewall.allowedUDPPorts = [ 6343 ];
  networking.firewall.allowedTCPPorts = [ 9144 ];

  users.users.ixp-deploy = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
    ];
  };

  system.stateVersion = "23.11";
}
