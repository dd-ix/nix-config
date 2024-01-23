{ self, ... }:
let
  domain = "mta.dd-ix.net";

  # allow relay from
  mynetworks = [
    # mno001 (temp.)
    "212.111.245.178"
    "2a01:7700:80b0:7000::1"
  ];

  # enable virtual aliases for those domains
  virtual_alias_domains = "cloud.dd-ix.net lists.dd-ix.net vault.dd-ix.net";

  # virtual alias map for $virtual_alias_domains
  virtual_alias_map = 
    ''
      noreply@cloud.dd-ix.net        noc@dd-ix.net
      bounce@lists.dd-ix.net         lists@dd-ix.net
      noreply@vault.dd-ix.net        noc@dd-ix.net
      noreply@wiki.dd-ix.net         noc@dd-ix.net
    '';
in
{
  networking.firewall.allowedTCPPorts = [ 25 ];

  services = {
    postfix = {
      enable = true;
      hostname = "${domain}";
        domain = "${domain}";
      origin = "${domain}";
      virtual = virtual_alias_map;
      networks = mynetworks;
      postmasterAlias = "noc@dd-ix.net";
      rootAlias = "noc@dd-ix.net";
      config = {
        smtp_helo_name = domain;
        smtp_use_tls = true;
        # smtp_tls_security_level = "encrypt";
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
        ];
        smtpd_relay_restrictions = [
          "permit_mynetworks"
          "reject_unauth_destination"
        ];
        "virtual_alias_domains" = virtual_alias_domains;
      };
    };
  };
}
