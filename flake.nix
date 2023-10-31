{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:revol-xut/nixpkgs/listmonk-patch-tassilo";

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

    keycloak-theme = {
      url = "github:dd-ix/keycloak-theme";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, foundation, presence, website-content, sops-nix, keycloak-theme}: {
    nixosConfigurations =
      let
        overlays = [
          presence.overlays.default
          foundation.overlays.default
          (final: prev: {
            website-content = website-content;
            keycloak-theme = keycloak-theme;
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
