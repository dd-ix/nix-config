{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:NuschtOS/nuschtpkgs/backports-25.05";
    #nixpkgs-unstable.url = "github:NuschtOS/nuschtpkgs/backports-24.11";

    flake-utils.url = "github:numtide/flake-utils";

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
      url = "github:nix-community/authentik-nix";
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

    alice-lg = {
      url = "github:MarcelCoding/alice-lg/vite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, sops-nix, microvm, website-content-api, website, website-content, ixp-manager, authentik, ddix-ansible-ixp, sflow-exporter, post, nixos-modules, alice-lg, ... }: {

    nixosModules = import ./modules;

    nixosConfigurations =
      let
        libD = import ./lib { inherit self; };
      in
      {
        svc-hv01 = libD.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/svc-hv01
            microvm.nixosModules.host
            nixos-modules.nixosModule
          ];
        };
        ext-mon01 = libD.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/ext-mon01
            nixos-modules.nixosModule
          ];
        };
        svc-adm01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.overlays = [ ddix-ansible-ixp.overlays.default ]; }
            ./hosts/svc-adm01
            nixos-modules.nixosModule
          ];
        };
        svc-mta01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            post.nixosModules.default
            { nixpkgs.overlays = [ post.overlays.default ]; }
            ./hosts/svc-mta01
            nixos-modules.nixosModule
          ];
        };
        svc-ns01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/svc-ns01
            nixos-modules.nixosModule
          ];
        };
        svc-portal01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            ixp-manager.nixosModules.default
            { nixpkgs.overlays = [ ixp-manager.overlays.default ]; }
            ./hosts/svc-portal01
            nixos-modules.nixosModule
          ];
        };
        svc-clab01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/svc-clab01
            nixos-modules.nixosModule
          ];
        };
        svc-fpx01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/svc-fpx01
            nixos-modules.nixosModule
          ];
        };
        svc-rpx01 = libD.microvmSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-rpx01
          ];
        };
        svc-auth01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            authentik.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-auth01
          ];
        };
        svc-pg01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-pg01
          ];
        };
        svc-mari01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-mari01
          ];
        };
        svc-cloud01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-cloud01
          ];
        };
        svc-dcim01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-dcim01
          ];
        };
        svc-lists01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-lists01
          ];
        };
        svc-vault01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-vault01
          ];
        };
        svc-lg01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.overlays = [ alice-lg.overlays.default ]; }
            nixos-modules.nixosModule
            ./hosts/svc-lg01
          ];
        };
        ixp-as11201 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/ixp-as11201
          ];
        };
        svc-prom01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-prom01
          ];
        };
        svc-prom02 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-prom02
          ];
        };
        svc-exp01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            sflow-exporter.nixosModules.default
            { nixpkgs.overlays = [ sflow-exporter.overlays.default ]; }
            ./hosts/svc-exp01
            nixos-modules.nixosModule
          ];
        };
        svc-obs01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-obs01
          ];
        };
        svc-web01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [
                website.overlays.default
                website-content-api.overlays.default
                (_: _: { inherit website-content; })
              ];
            }
            website.nixosModules.default
            website-content-api.nixosModules.default
            nixos-modules.nixosModule
            ./hosts/svc-web01
          ];
        };
        svc-bbe01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-bbe01
          ];
        };
        svc-crm01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-crm01
          ];
        };
        svc-tix01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-tix01
          ];
        };
        svc-trans01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-trans01
          ];
        };
        svc-nms01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-nms01
          ];
        };
        svc-log01 = libD.microvmSystem {
          system = "x86_64-linux";
          modules = [
            nixos-modules.nixosModule
            ./hosts/svc-log01
          ];
        };
      };
  };
}
