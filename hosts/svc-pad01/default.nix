{
  imports = [
    ./hedgedoc.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-pad01";

    microvm = {
      mem = 2048;
      vcpu = 2;
    };

    acme = [
      { name = "pad.dd-ix.net"; group = "nginx"; }
    ];

    postgres = [ "hedgedoc" ];

    monitoring = {
      enable = true;
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
