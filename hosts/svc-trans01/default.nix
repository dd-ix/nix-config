{ self, ... }:

{
  imports = [
    ./weblate.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-trans01";

    microvm = {
      mem = 4 * 1024;
      vcpu = 2;

      v4Addr = "10.96.1.17/24";
    };

    acme = [
      { name = "translate.dd-ix.net"; group = "nginx"; }
    ];

    postgres = [ "weblate" ];

    monitoring = {
      enable = true;
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;

  nixpkgs.overlays = [
    (_: _: {
      weblate = self.inputs.nixpkgs-2605.legacyPackages.x86_64-linux.weblate;
    })
  ];

  system.stateVersion = "23.11";
}
