{ self }:

rec {
  nixosSystem = import ./nixosSystem.nix { inherit self; };
  microvmSystem = import ./microvmSystem.nix { inherit self nixosSystem; };
}
