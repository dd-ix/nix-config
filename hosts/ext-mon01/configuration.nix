{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  dd-ix.hostName = "ext-mon01";

  services = {
    openssh.enable = true;
    qemuGuest.enable = true;

    # is deployed on external ifra
    prometheus.exporters.nginxlog.enable = lib.mkForce false;
  };

  system.stateVersion = "24.11";
}

