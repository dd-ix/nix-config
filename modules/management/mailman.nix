{ config, pkgs, ... }:

{
  /*  services.postfix = {
    enable = true;
    relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
    sslCert = config.security.acme.certs."lists.example.org".directory + "/full.pem";
    sslKey = config.security.acme.certs."lists.example.org".directory + "/key.pem";
    config = {
      transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
      local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
    };
  };*/
  services.mailman = {
    enable = true;
    serve.enable = true;
    hyperkitty.enable = true;
    webHosts = [ "lists.dd-ix.net" ];
    siteOwner = "noc@dd-ix.net";
    enablePostfix = false;
    #extraPythonPackages = with pkgs.python3Packages; [ psycopg2 ];
    settings = {
      mta = {
        incoming = "mailman.mta.postfix.LMTP";
        outgoing = "mailman.mta.deliver.deliver";
        lmtp_host = "mta.dd-ix.net";
        lmtp_port = "24";
        smtp_host = "mta.dd-ix.net";
        smtp_port = "25";
        configuration = "python:mailman.config.postfix";
      };
      database = {
        class = "mailman.database.postgresql.PostgreSQLDatabase";
        url = "postgresql://mailman:mypassword@svc-pg01.dd-ix.net/mailman";
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."lists.${config.dd-ix.domain}" = {
      listen = [{
        addr = "[::]:443";
        proxyProtocol = true;
        ssl = true;
      }];

      onlySSL = true;
      useACMEHost = "lists.${config.dd-ix.domain}";
    };
  };
}
