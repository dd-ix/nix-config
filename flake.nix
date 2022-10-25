{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.rpi-manager = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/ixp-manager.nix {};
  };
}
