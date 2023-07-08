{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.deployment-dd-ix.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "=/robots.txt" = {
            return = "200 \"User-agent: *\\nDisallow: /\\n\"";
          };
          "/" = {
            root = "${pkgs.dd-ix-website}/bin/";
            tryFiles = "$uri /$1/index.html =404";
          };
        };
      };
    };
  };
}
