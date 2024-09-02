{ self, pkgs, lib, config, ... }:
let
  addr = "[2a01:7700:80b0:7000::2]";

  toList = attrs: (builtins.map (key: lib.getAttr key attrs) (lib.attrNames attrs));

  # list of all nixos systems in this flake
  allSystems = toList self.nixosConfigurations;

  allMicroVMS = builtins.filter (x: ((builtins.hasAttr "microvm" x.config.dd-ix) && (x.config.dd-ix.microvm.enable == true))) allSystems;

  # turns the hostname into an address
  extractName = host: "${host.config.dd-ix.hostName}";

  # list of addresses
  listOfNames = builtins.map extractName allMicroVMS;
in
{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    #./initrd_network.nix
  ];

  dd-ix =
    let
      domains = [
        "wiki.dd-ix.net"
      ];
    in
    {
      useFpx = true;
      hostName = "svc-hv01";

      rpx = {
        inherit domains;
        addr = "${addr}:443";
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
        host = addr;
        port = 9101;
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
          "/dev/sdd"
        ];
      };
    };

  microvm = {
    autostart = listOfNames;
    stateDir = "/var/lib/microvms";
    virtiofsd.threadPoolSize = 16;
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
    ethtool
  ];

  sops.defaultSopsFile = self + /secrets/management/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  # required by libvirtd
  security.polkit.enable = true;

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

