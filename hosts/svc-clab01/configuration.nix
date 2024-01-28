{ pkgs, ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 1024 * 16;
      vcpu = 4;

      hostName = "svc-clab01";
      mac = "22:99:63:21:e4:62";
      vlan = "s";

      v6Addr = "2a01:7700:80b0:6001::2/64";
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    containerlab
  ];

  system.stateVersion = "23.11";
}
