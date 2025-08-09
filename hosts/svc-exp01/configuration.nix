{ config, pkgs, ... }:

{
  dd-ix = {
    hostName = "svc-exp01";
    useFpx = true;

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;
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
        # arouteserver@svc-adm01
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
      ] ++ config.users.users.root.openssh.authorizedKeys.keys;
    };
  };

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
