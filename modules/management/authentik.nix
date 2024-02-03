{ ... }:
{
  services.authentik = {
    enable = true;

    environmentFile = "/run/secrets/authentik/authentik-env";

    createDatabase = false;

    settings = {
      email = {
        host = "mta.dd-ix.net";
        port = 25;
        username = "";
        use_tls = false;
        use_ssl = false;
        from = "noreply@auth.dd-ix.net";
      };
      disable_startup_analytics = true;
      avatars = "initials";
      footer_links = "[{\"name\":\"Imprint\",\"href\":\"https://dd-ix.net/imprint\"},{\"name\":\"Privacy Policy\",\"href\":\"https://dd-ix.net/privacy-policy\"}]";
    };
  };
}
