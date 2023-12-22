{ config, pkgs, ... }:
let
  domain = "lists.${config.deployment-dd-ix.domain}";

  # see https://www.kuketz-blog.de/e-mail-anbieter-ip-stripping-aus-datenschutzgruenden/
  header_cleanup = pkgs.writeText "header_cleanup_outgoing" ''
    /^\s*(Received: from)[^\n]*(.*)/ REPLACE $1 127.0.0.1 (localhost [127.0.0.1])$2
    /^\s*User-Agent/ IGNORE
    /^\s*X-Enigmail/ IGNORE
    /^\s*X-Mailer/ IGNORE
    /^\s*X-Originating-IP/ IGNORE
    /^\s*Mime-Version/ IGNORE
  '';
in
{
  networking.firewall.allowedTCPPorts = [
    25 # insecure SMTP
    143
    465
    587 # SMTP
  ];
  users.users.postfix.extraGroups = [ "opendkim" ];

  services = {
    postfix = {
      enable = true;
      enableSubmission = true;
      enableSubmissions = true;
      hostname = "${domain}";
      domain = "${domain}";
      origin = "${domain}";
      destination = [ "${domain}" "localhost" ];
      networksStyle = "host"; # localhost and own public IP
      sslCert = "/var/lib/acme/${domain}/fullchain.pem";
      sslKey = "/var/lib/acme/${domain}/key.pem";
      relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
      config = {
        home_mailbox = "Maildir/";
        # hostname used in helo command. It is recommended to have this match the reverse dns entry
        smtp_helo_name = config.networking.rDNS;
        smtp_use_tls = true;
        # smtp_tls_security_level = "encrypt";
        smtpd_use_tls = true;
        # smtpd_tls_security_level = lib.mkForce "encrypt";
        # smtpd_tls_auth_only = true;
        smtpd_tls_protocols = [
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "!TLSv1.1"
        ];
        # "reject_non_fqdn_hostname"
        smtpd_recipient_restrictions = [
          "permit_sasl_authenticated"
          "permit_mynetworks"
          "reject_unauth_destination"
          "reject_non_fqdn_sender"
          "reject_non_fqdn_recipient"
          "reject_unknown_sender_domain"
          "reject_unknown_recipient_domain"
          "reject_unauth_destination"
          "reject_unauth_pipelining"
          "reject_invalid_hostname"
          "check_policy_service inet:localhost:12340"
        ];
        smtpd_relay_restrictions = [
          "permit_sasl_authenticated"
          "permit_mynetworks"
          "reject_unauth_destination"
        ];
        smtp_header_checks = "pcre:${header_cleanup}";
        alias_maps = [ "hash:/etc/aliases" ];
        alias_database = [ "hash:/etc/aliases" ];
        smtpd_milters = [ "local:/run/opendkim/opendkim.sock" ];
        non_smtpd_milters = [ "local:/var/run/opendkim/opendkim.sock" ];
        smtpd_sasl_auth_enable = true;
        smtpd_sasl_path = "/var/lib/postfix/auth";
        smtpd_sasl_type = "dovecot";
        transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
        virtual_alias_maps = [ "hash:/var/lib/mailman/data/postfix_vmap" ];
      };
    };
    opendkim = {
      enable = true;
      domains = "csl:${config.networking.domain}";
      selector = config.networking.hostName;
      configFile = pkgs.writeText "opendkim-config" ''
        UMask 0117
      '';
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."${domain}" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
  security.acme.certs."${domain}" = {
    reloadServices = [
      "postfix.service"
    ];
  };
}
