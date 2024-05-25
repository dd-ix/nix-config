{ pkgs, ... }:
{
  dd-ix = {
    hostName = "svc-clab01";

    microvm = {
      enable = true;

      mem = 1024 * 16;
      vcpu = 4;

      mac = "22:99:63:21:e4:62";
      vlan = "l";

      v6Addr = "2a01:7700:80b0:7001::2/64";
      v4Addr = "10.112.1.2/29";
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    containerlab
  ];

  system.stateVersion = "23.11";
}
