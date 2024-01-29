{ ... }:
{
  services.privoxy = {
    enable = true;
    settings.listen-address = "[::]:8080";
  };
}
