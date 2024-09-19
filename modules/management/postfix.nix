{ config, ... }:
let
  domain = "svc-mta01.${config.dd-ix.domain}";

  # allow relay from
  mynetworks = [
    # post
    "[::1]/128"
    # svc-hv01
    "[2a01:7700:80b0:7000::2]/128"
    # svc-cloud01
    "[2a01:7700:80b0:6001::6]/128"
    # svc-auth01
    "[2a01:7700:80b0:6001::4]/128"
    # svc-lists01
    "[2a01:7700:80b0:6001::8]/128"
    # svc-obs01
    "[2a01:7700:80b0:6001::11]/128"
    # svc-vault01
    "[2a01:7700:80b0:6001::9]/128"
    # svc-adm01
    "[2a01:7700:80b0:7002::2]/128"
    # svc-portal01
    "[2a01:7700:80b0:6001::2]/128"
    # svc-tix01
    "[2a01:7700:80b0:6001::16]/128"

  ];

  # enable virtual aliases for those domains
  virtual_alias_domains = "cloud.dd-ix.net vault.dd-ix.net wiki.dd-ix.net auth.dd-ix.net svc-hv01.dd-ix.net svc-adm01.dd-ix.net portal.dd-ix.net obs.dd-ix.net tickets.dd-ix.net";

  # virtual alias map for $virtual_alias_domains
  virtual_alias_map =
    ''
      noreply@cloud.dd-ix.net        noc@dd-ix.net
      noreply@vault.dd-ix.net        noc@dd-ix.net
      noreply@wiki.dd-ix.net         noc@dd-ix.net
      noreply@auth.dd-ix.net         noc@dd-ix.net
      noreply@svc-hv01.dd-ix.net     noc@dd-ix.net
      noreply@svc-adm01.dd-ix.net    noc@dd-ix.net
      noreply@portal.dd-ix.net       noc@dd-ix.net
      noreply@obs.dd-ix.net          noc@dd-ix.net
      noreply@tickets.dd-ix.net      noc@dd-ix.net
    '';
in
{
  networking.firewall.allowedTCPPorts = [ 25 ];

  security.acme.certs.${domain}.postRun = ''
    systemctl reload postfix.service 
  '';

  services.postfix = {
    enable = true;
    hostname = domain;
    sslCert = "${config.security.acme.certs.${domain}.directory}/fullchain.pem";
    sslKey = "${config.security.acme.certs.${domain}.directory}/key.pem";
    domain = domain;
    origin = domain;
    virtual = virtual_alias_map;
    networks = mynetworks;
    postmasterAlias = "noc@dd-ix.net";
    rootAlias = "noc@dd-ix.net";
    destination = [
      "lists.dd-ix.net"
    ];
    config = {
      smtp_helo_name = domain;
      smtp_tls_security_level = "encrypt";
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
        "reject_rbl_client zen.spamhaus.org=127.0.0.[2..11]"
        "reject_rhsbl_sender dbl.spamhaus.org=127.0.1.[2..99]"
        "reject_rhsbl_helo dbl.spamhaus.org=127.0.1.[2..99]"
        "reject_rhsbl_reverse_client dbl.spamhaus.org=127.0.1.[2..99]"
        "warn_if_reject reject_rbl_client zen.spamhaus.org=127.255.255.[1..255]"
        "reject_rbl_client dnsbl-1.uceprotect.net"
        "reject_rbl_client bl.0spam.org=127.0.0.[7..9]"
      ];
      smtpd_relay_restrictions = [
        "permit_mynetworks"
        "reject_unauth_destination"
      ];
      inherit virtual_alias_domains;
      # mailman config
      # https://docs.mailman3.org/projects/mailman/en/latest/src/mailman/docs/mta.html#basic-postfix-connections
      recipient_delimiter = "+";
      unknown_local_recipient_reject_code = "550";
      owner_request_special = false;
      transport_maps = [ "regexp:/var/lib/mailman/data/postfix_lmtp" ];
      local_recipient_maps = [ "regexp:/var/lib/mailman/data/postfix_lmtp" ];
      relay_domains = [ "regexp:/var/lib/mailman/data/postfix_domains" ];
    };
  };
}
