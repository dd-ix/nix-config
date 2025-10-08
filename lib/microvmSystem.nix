{ self, nixosSystem }:

{ system, modules }:
nixosSystem {
  inherit system;

  modules = [
    self.nixosModules.dd-ix-microvm
  ] ++ modules;
}

