{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    ifstate = {
      url = "git+https://codeberg.org/m4rc3l/ifstate.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    ixp-manager = {
      url = "github:dd-ix/ixp-manager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    authentik = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-23-05.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ifstate, sops-nix, microvm, foundation, presence, website-content, ixp-manager, authentik }: {
    nixosConfigurations =
      let
        overlays = [
          presence.overlays.default
          foundation.overlays.default
          (final: prev: {
            website-content = website-content;
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
        svc-ns01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            ./hosts/svc-ns01
            sops-nix.nixosModules.default
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-mta01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            sops-nix.nixosModules.default
            microvm.nixosModules.microvm
            ./hosts/svc-mta01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-portal01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ixp-manager.nixosModules.default
            { nixpkgs.overlays = [ ixp-manager.overlays.default ]; }
            ./hosts/svc-portal01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-clab01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-clab01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-fpx01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-fpx01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-rpx01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-rpx01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-auth01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            authentik.nixosModules.default
            ./hosts/svc-auth01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-pg01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-pg01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-cloud01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-cloud01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-dcim01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-dcim01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-lists01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ifstate.nixosModules.default
            { nixpkgs.overlays = [ ifstate.overlays.default ]; }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-lists01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
      };
  };
}
