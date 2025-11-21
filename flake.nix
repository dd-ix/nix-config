{
  description = "dresden internet exchange nixos config";

  inputs = {
    nixpkgs.url = "github:NuschtOS/nuschtpkgs/backports-25.11";

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

  outputs = { self, ... }: {
    nixosModules = import ./modules;

    nixosConfigurations =
      let
        libD = import ./lib { inherit self; };
      in
      import ./hosts { inherit self libD; };
  };
}
