{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./ssh.nix
    ./sudo.nix
    ./zfs.nix
    ./tools.nix
    ./cleanup.nix
    ./time.nix
    ./i18n.nix
    ./kernel.nix
    ./tmux.nix
    ./neovim.nix

    ./old.nix
  ];
}
