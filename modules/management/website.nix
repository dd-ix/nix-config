{ pkgs, config, ... }: {

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.deployment-dd-ix.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            root = "${pkgs.dd-ix-website}/bin/";
            tryFiles = "$uri /$1/index.html =404";
          };
          "robot.txt" = {
            root = ../../resources/;
          };
        };
      };
    };
  };
}
