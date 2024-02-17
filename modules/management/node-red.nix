{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.node-red = {
    enable = true;
    withNpmAndGcc = true;
    define = { "editorTheme.projects.enabled" = "true"; };
  };
}
