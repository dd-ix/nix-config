{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:NuschtOS/nuschtpkgs/backports-24.11";
    #nixpkgs-unstable.url = "github:NuschtOS/nuschtpkgs/backports-24.11";

    flake-utils.url = "github:numtide/flake-utils";

    ifstate = {
      url = "git+https://codeberg.org/m4rc3l/ifstate.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    website = {
      url = "github:dd-ix/website";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    website-content-api = {
      url = "github:dd-ix/website-content-api";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    website-content = {
      url = "github:dd-ix/website-content";
      flake = false;
    };

    ixp-manager = {
      url = "github:dd-ix/ixp-manager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    authentik = {
      # TODO: bump to latest again, after https://tracker.nixos.c3d2.de/?pr=362304
      url = "github:fpletz/authentik-nix/24.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ddix-ansible-ixp = {
      url = "github:dd-ix/ddix-ansible-ixp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    sflow-exporter = {
      url = "github:dd-ix/sflow_exporter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    post = {
      url = "github:dd-ix/post";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixos-modules = {
      url = "github:NuschtOS/nixos-modules";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, ifstate, sops-nix, microvm, website-content-api, website, website-content, ixp-manager, authentik, ddix-ansible-ixp, sflow-exporter, post, nixos-modules, ... }: {

    nixosModules = {
      common = ./modules/common;
      data = ./modules/data;
    };

    nixosConfigurations =
      {
        svc-hv01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            ./hosts/svc-hv01/configuration.nix
            ./modules/management/bookstack.nix
            ./modules/dd-ix
            sops-nix.nixosModules.default
            microvm.nixosModules.host
            nixos-modules.nixosModule
          ];
        };
        svc-adm01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            { nixpkgs.overlays = [ ddix-ansible-ixp.overlays.default ]; }
            ./hosts/svc-adm01
            sops-nix.nixosModules.default
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
            nixos-modules.nixosModule
          ];
        };
        svc-mta01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            sops-nix.nixosModules.default
            microvm.nixosModules.microvm
            post.nixosModules.default
            { nixpkgs.overlays = [ post.overlays.default ]; }
            ./hosts/svc-mta01
            nixos-modules.nixosModule
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-node01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            ./hosts/svc-node01
            sops-nix.nixosModules.default
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
            nixos-modules.nixosModule
          ];
        };
        svc-ns01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            ./hosts/svc-ns01
            sops-nix.nixosModules.default
            ./modules/dd-ix
            nixos-modules.nixosModule
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-portal01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ixp-manager.nixosModules.default
            { nixpkgs.overlays = [ ixp-manager.overlays.default ]; }
            ./hosts/svc-portal01
            ./modules/dd-ix
            nixos-modules.nixosModule
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-clab01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-clab01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
            nixos-modules.nixosModule
          ];
        };
        svc-fpx01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            ./hosts/svc-fpx01
            ./modules/dd-ix
            nixos-modules.nixosModule
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-rpx01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-rpx01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-auth01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            authentik.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-auth01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-pg01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-pg01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-mari01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-mari01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-cloud01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-cloud01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-dcim01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-dcim01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-lists01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            nixos-modules.nixosModule
            sops-nix.nixosModules.default
            ./hosts/svc-lists01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-vault01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-vault01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-lg01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-lg01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        ixp-as11201 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/ixp-as11201
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-prom01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-prom01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-prom02 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-prom02
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-exp01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sflow-exporter.nixosModules.default
            { nixpkgs.overlays = [ sflow-exporter.overlays.default ]; }
            sops-nix.nixosModules.default
            ./hosts/svc-exp01
            nixos-modules.nixosModule
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-obs01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-obs01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-web01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            {
              nixpkgs.overlays = [
                website.overlays.default
                website-content-api.overlays.default
                (final: prev: {
                  website-content = website-content;
                })
              ];
            }
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            website.nixosModules.default
            website-content-api.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-web01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-bbe01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-bbe01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-crm01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-crm01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-tix01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-tix01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
        svc-nms01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            self.nixosModules.common
            self.nixosModules.data
            ifstate.nixosModules.default
            microvm.nixosModules.microvm
            sops-nix.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-nms01
            ./modules/dd-ix
            ./modules/dd-ix-microvm.nix
          ];
        };
      };
  };
}
