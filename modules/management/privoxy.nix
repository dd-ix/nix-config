{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.privoxy = {
    enable = true;
    settings.listen-address = "[::]:8080";
  };
}
