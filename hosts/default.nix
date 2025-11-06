{ self, libD }:

{
  svc-hv01 = libD.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-hv01
      self.inputs.microvm.nixosModules.host
    ];
  };
  ext-mon01 = libD.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./ext-mon01
    ];
  };
  svc-adm01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs.overlays = [ self.inputs.ddix-ansible-ixp.overlays.default ]; }
      ./svc-adm01
    ];
  };
  svc-mta01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.post.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.post.overlays.default ]; }
      ./svc-mta01
    ];
  };
  svc-ns01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-ns01
    ];
  };
  svc-portal01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.ixp-manager.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.ixp-manager.overlays.default ]; }
      ./svc-portal01
    ];
  };
  svc-clab01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-clab01
    ];
  };
  svc-fpx01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-fpx01
    ];
  };
  svc-rpx01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-rpx01
    ];
  };
  svc-auth01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.authentik.nixosModules.default
      ./svc-auth01
    ];
  };
  svc-pg01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-pg01
    ];
  };
  svc-mari01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-mari01
    ];
  };
  svc-cloud01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-cloud01
    ];
  };
  svc-dcim01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-dcim01
    ];
  };
  svc-lists01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-lists01
    ];
  };
  svc-vault01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-vault01
    ];
  };
  svc-lg01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      { nixpkgs.overlays = [ self.inputs.alice-lg.overlays.default ]; }
      ./svc-lg01
    ];
  };
  ixp-as11201 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./ixp-as11201
    ];
  };
  svc-prom01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-prom01
    ];
  };
  svc-prom02 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-prom02
    ];
  };
  svc-exp01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      self.inputs.sflow-exporter.nixosModules.default
      { nixpkgs.overlays = [ self.inputs.sflow-exporter.overlays.default ]; }
      ./svc-exp01
    ];
  };
  svc-obs01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
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
      ./svc-web01
    ];
  };
  svc-bbe01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-bbe01
    ];
  };
  svc-crm01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-crm01
    ];
  };
  svc-tix01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-tix01
    ];
  };
  svc-trans01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-trans01
    ];
  };
  svc-nms01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-nms01
    ];
  };
  svc-log01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-log01
    ];
  };
  svc-pad01 = libD.microvmSystem {
    system = "x86_64-linux";
    modules = [
      ./svc-pad01
    ];
  };
}
