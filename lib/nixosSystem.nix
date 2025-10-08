{ self }:

{ system, modules }:
self.inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self; };

  modules = [
    self.nixosModules.common
    self.nixosModules.data
    self.nixosModules.dd-ix
    self.inputs.sops-nix.nixosModules.default
  ] ++ modules;
}
