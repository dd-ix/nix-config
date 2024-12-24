{ pkgs, ... }:
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
      ];
      keyFiles = [
        ../../keys/ssh/tassilo_1
        ../../keys/ssh/tassilo_2
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
