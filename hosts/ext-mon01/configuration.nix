{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  dd-ix.hostName = "ext-mon01";

networking = {
  nameservers = lib.mkForce[
    "194.29.226.55"
    "194.29.230.55"
    "2a02:f28:2:0:194:29:226:55"
    "2a02:f28:2:0:194:29:230:55"
  ];
  timeServers = lib.mkForce[
    "0.de.pool.ntp.org"
    "1.de.pool.ntp.org"
    "2.de.pool.ntp.org"
  ];

  interfaces.ens18 = {
    ipv6.addresses = [{
      address = "2a02:f28:1:70::10";
      prefixLength = 64;
    }];
    ipv4.addresses = [{
      address = "91.102.12.190";
      prefixLength = 29;
    }];
  };
  defaultGateway = {
    address = "91.102.12.185";
    interface = "ens18";
  };
  defaultGateway6 = {
    address = "2a02:f28:1:70::1";
    interface = "ens18";
  };
};
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  system.stateVersion = "24.11"; # Did you read the comment?
}
