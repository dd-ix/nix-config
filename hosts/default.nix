{ self, libD }:

{
  svc-hv01 = libD.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-hv01
      self.inputs.microvm.nixosModules.host
      self.inputs.nixos-modules.nixosModule
    ];
  };
  ext-mon01 = libD.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./ext-mon01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-adm01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs.overlays = [ self.inputs.ddix-ansible-ixp.overlays.default ]; }
      ./svc-adm01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-mta01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.post.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.post.overlays.default ]; }
      ./svc-mta01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-ns01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-ns01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-portal01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.ixp-manager.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.ixp-manager.overlays.default ]; }
      ./svc-portal01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-clab01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-clab01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-fpx01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-fpx01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-rpx01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-rpx01
    ];
  };
  svc-auth01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.authentik.nixosModules.default
      self.inputs.nixos-modules.nixosModule
      ./svc-auth01
    ];
  };
  svc-pg01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-pg01
    ];
  };
  svc-mari01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-mari01
    ];
  };
  svc-cloud01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-cloud01
    ];
  };
  svc-dcim01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-dcim01
    ];
  };
  svc-lists01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-lists01
    ];
  };
  svc-vault01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-vault01
    ];
  };
  svc-lg01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs.overlays = [ self.inputs.alice-lg.overlays.default ]; }
      self.inputs.nixos-modules.nixosModule
      ./svc-lg01
    ];
  };
  ixp-as11201 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./ixp-as11201
    ];
  };
  svc-prom01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-prom01
    ];
  };
  svc-prom02 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-prom02
    ];
  };
  svc-exp01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.sflow-exporter.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.sflow-exporter.overlays.default ]; }
      ./svc-exp01
      self.inputs.nixos-modules.nixosModule
    ];
  };
  svc-obs01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-obs01
    ];
  };
  svc-web01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      {
        nixpkgs.overlays = [
          self.inputs.website.overlays.default
          self.inputs.website-content-api.overlays.default
          (_: _: { inherit (self.inputs) website-content; })
        ];
      }
      self.inputs.website.nixosModules.default
      self.inputs.website-content-api.nixosModules.default
      self.inputs.nixos-modules.nixosModule
      ./svc-web01
    ];
  };
  svc-bbe01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-bbe01
    ];
  };
  svc-crm01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-crm01
    ];
  };
  svc-tix01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-tix01
    ];
  };
  svc-trans01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-trans01
    ];
  };
  svc-nms01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-nms01
    ];
  };
  svc-log01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.nixos-modules.nixosModule
      ./svc-log01
    ];
  };
}
