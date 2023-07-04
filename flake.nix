{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
  };

  outputs = inputs@{ self, nixpkgs }: {
    packages.x86_64-linux.rpi-manager = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/ixp-manager.nix { };

    nixosConfigurations = {
      mno001 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/mno001/configuration.nix
          ./modules/management
        ];
      };
    };
  };
}
