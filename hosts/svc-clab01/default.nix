{ pkgs, ... }:

{
  dd-ix = {
    hostName = "svc-clab01";

    microvm = {
      mem = 1024 * 16;
      vcpu = 4;

      v4Addr = "10.112.1.2/29";
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    containerlab
  ];

  system.stateVersion = "23.11";
}
