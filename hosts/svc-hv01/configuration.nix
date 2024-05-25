{ self, pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./initrd_network.nix
  ];

  dd-ix =
    let
      domains = [
        "wiki.dd-ix.net"
      ];
    in
    {
      useFpx = true;

      rpx = {
        inherit domains;
        addr = "[2a01:7700:80b0:7000::2]";
      };

      acme = map
        (domain: {
          name = domain;
          group = "nginx";
        })
        domains;

      restic = {
        enable = true;
        name = "svc-hv01";
      };
      monitoring.enable = true;
      monitoring.smart = {
        enable = true;
        host = config.dd-ix.rpx.addr;
        port = 9101;
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
          "/dev/sdd"
        ];
      };
    };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.requestEncryptionCredentials = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostId = "eeb0e9de";
  networking.hostName = "svc-hv01";

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  sops.defaultSopsFile = self + /secrets/management/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

