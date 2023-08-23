{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:revol-xut/nixpkgs/nixos-23.05";

    dd-ix-website = {
      url = "github:dd-ix/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    presence = {
      url = "github:dd-ix/presence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    foundation = {
      url = "github:dd-ix/foundation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    website-content = {
      url = "github:dd-ix/website-content";
      flake = false;
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, dd-ix-website, foundation, presence, website-content, sops-nix }: {
    nixosConfigurations =
      let
        overlays = [
          dd-ix-website.overlays.default
          presence.overlays.default
          foundation.overlays.default
          (final: prev: {
            website-content = website-content;
          })
        ];

        nixos-modules = [
          sops-nix.nixosModules.default
          presence.nixosModules.default
          foundation.nixosModules.default
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
