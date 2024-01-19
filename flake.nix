{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
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

    keycloak-theme = {
      url = "github:dd-ix/keycloak-theme";
      flake = false;
    };

    ixp-manager = {
      url = "github:dd-ix/ixp-manager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, sops-nix, microvm, foundation, presence, website-content, keycloak-theme, ixp-manager }: {
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
          microvm.nixosModules.host
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
            ./modules/postgresql.nix
            {
              nixpkgs.overlays = overlays;
              deployment-dd-ix = {
                domain = "dd-ix.net";
              };
            }
          ] ++ nixos-modules;
        };
        ns-mno001 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            microvm.nixosModules.microvm
            ./hosts/ns-mno001/default.nix
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        portal-mno001 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            microvm.nixosModules.microvm
            ixp-manager.nixosModules.default
            { nixpkgs.overlays = [ ixp-manager.overlays.default ]; }
            ./hosts/portal-mno001/default.nix
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
      };
  };
}
