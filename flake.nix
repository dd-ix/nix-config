{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    dd-ix-website = {
      url = "github:dd-ix/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, dd-ix-website, sops-nix }: {
    nixosConfigurations =
      let
        overlays = [
          dd-ix-website.overlays.default
        ];

        nixos-modules = [
          sops-nix.nixosModules.default
        ];

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
