{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./ssh.nix
    ./sudo.nix
    ./upgrade-diff.nix
    ./zfs.nix
    ./keymap.nix
    ./tools.nix
    ./cleanup.nix
    ./time.nix

    ./old.nix
  ];
}