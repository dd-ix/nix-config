{
  imports = [
    ./bookstack.nix
  ];

  dd-ix = {
    useFpx = true;
    hostName = "svc-wiki01";

    microvm = {
      mem = 1 * 1024;
      vcpu = 2;
    };

    acme = [
      { name = "wiki.dd-ix.net"; group = "nginx"; }
    ];

    mariadb = [ "bookstack" ];

    monitoring = {
      enable = true;
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "23.11";
}
