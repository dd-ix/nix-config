{ self, pkgs, lib, ... }:

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
    ./nix-remote-builder.nix
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
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    zfs.requestEncryptionCredentials = true;
  };

  boot.kernelParams = [
    # allows passing pci devices into microvm's
    "intel_iommu=on"
    "zfs.zfs_arc_max=${toString (32 /* GB */ * 1024 * 1024 * 1024)}"
  ];

  boot.supportedFilesystems = [ "zfs" ];

  networking = {
    hostId = "eeb0e9de";
    hostName = "svc-hv01";
  };

  # zfs emails
  nixpkgs.config.packageOverrides = pkgs: {
    zfsStable = pkgs.zfsStable.override { enableMail = true; };
  };

  services.zfs = {
    autoSnapshot.enable = true;
    autoScrub.enable = true;
    zed = {
      enableMail = true;
      settings = {
        ZED_EMAIL_ADDR = [ "marcel.koch@dd-ix.net" ];
        ZED_NOTIFY_VERBOSE = true;
      };
    };
  };

  sops = {
    defaultSopsFile = self + /secrets/management/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  # required by libvirtd
  security.polkit.enable = true;

  system.stateVersion = "23.05";
}

