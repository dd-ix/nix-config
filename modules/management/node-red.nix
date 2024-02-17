{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.node-red = {
    enable = true;
  };
}
