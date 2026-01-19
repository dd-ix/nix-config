{
  imports = [
    ./postfix.nix
    ./post.nix
  ];

  dd-ix = {
    hostName = "svc-mta01";
    useFpx = true;

    microvm = {
      mem = 1 * 1024;
      vcpu = 2;

      v4Addr = "212.111.245.180/29";
    };

    acme = [{
      name = "svc-mta01.dd-ix.net";
      group = "nginx";
    }];

    monitoring = {
      enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  system.stateVersion = "23.11";
}
