{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    dd-ix-website = {
      url = "github:dd-ix/website";
    };
  };

  outputs = inputs@{ self, nixpkgs, dd-ix-website }: {
    packages.x86_64-linux.rpi-manager = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/ixp-manager.nix { };

    nixosConfigurations =
      let
        overlays = [
          dd-ix-website.overlays.default
        ];

        nixos-modules = [ ];

      in
      {
        mno001 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/mno001/configuration.nix
            ./modules/management
            ./modules/dd-ix
            {
              nixpkgs.overlays = overlays;
              deployment-dd-ix = {
                domain = "dd-ix.net";
              };
            }
          ] ++ nixos-modules;
        };
      };
  };
}
