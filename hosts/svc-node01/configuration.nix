{ pkgs, ... }:
{
  dd-ix = {
    hostName = "svc-node01";

    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;
    };
  };

  system.stateVersion = "23.11";
}
