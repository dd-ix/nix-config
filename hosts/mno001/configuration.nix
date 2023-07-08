{ self, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.requestEncryptionCredentials = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostId = "eeb0e9de";
  networking.hostName = "mno001";

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  sops.defaultSopsFile = self + /secrets/management/secrets.yaml;

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

