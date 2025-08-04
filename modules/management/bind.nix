{ self, lib, config, ... }:

let
  bindUser = "named";
  # IBH authoritative nameservers
  ibh_ans_ip = [
    # ans-01.ibh.de
    "2a01:7700:0:1035::1:50"
    # ans-02.ibh.net
    "2a01:7700:0:1036::1:50"
    # ans-03.ibh.de
    "2001:608:c00:10::1:138"
    # ans-04.ibh.services
    "2a01:4f8:c0c:74b9::1"
    # ans-05.ibh.net
    "2a01:4f9:c012:61fd::1"
  ];
  systems = lib.attrValues self.nixosConfigurations;
  acmeSystems = lib.filter (system: (lib.length system.config.dd-ix.acme) != 0) systems;
  acmeDomains = lib.flatten (map (system: system.config.dd-ix.acme) acmeSystems);
  domains = map (domain: domain.name) acmeDomains;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  sops.secrets = lib.listToAttrs (map
    (domain: {
      name = "rfc2136_${domain}";
      value = {
        sopsFile = self + "/secrets/management/rfc2136/bind.yaml";
        owner = bindUser;
      };
    })
    domains);

  systemd.services."bind-create-acme-zone" = {
    before = [ "bind.service" ];
    after = [ "network.target" ];
    wantedBy = [ "bind.service" ];
    script = ''
      set -eu
      if ! test -f /var/lib/bind/acme-dns.dd-ix.net.zone; then
        mkdir -p /var/lib/bind/
        cp ${self}/resources/acme-dns.dd-ix.net.zone /var/lib/bind/acme-dns.dd-ix.net.zone
      fi
      chown named:named /var/lib/bind/*

      mkdir -m 0775 -p /var/lib/bind/ixp-deploy
      chown ixp-deploy:named /var/lib/bind/ixp-deploy
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      RemainAfterExit = true;
    };
  };

  services.bind = {
    enable = true;

    extraConfig = lib.strings.concatStringsSep "\n" (map
      (domain:
        "include \"${config.sops.secrets."rfc2136_${domain}".path}\";"
      )
      domains);

    # cannot talk to root ns (firewall)
    forward = "only";

    zones = {
      "dd-ix.net" = {
        master = true;
        file = self + "/resources/dd-ix.net.zone";
        slaves = ibh_ans_ip;
      };

      "acme-dns.dd-ix.net" = {
        master = true;
        file = "/var/lib/bind/acme-dns.dd-ix.net.zone";
        slaves = ibh_ans_ip;

        extraConfig =
          let
            grants = lib.strings.concatStringsSep "\n" (map
              (domain:
                "grant rfc2136_${domain} name ${lib.replaceStrings ["dd-ix.net"] ["acme-dns.dd-ix.net"] domain}. TXT;"
              )
              domains);
          in
          ''
            update-policy {
              ${grants}
            };
          '';
      };

      # ipv4 pa
      "176.245.111.212.in-addr.arpa" = {
        master = true;
        file = self + "/resources/176.245.111.212.in-addr.arpa.zone";
        slaves = ibh_ans_ip;
      };

      # ipv6 pa
      "0.b.0.8.0.0.7.7.1.0.a.2.ip6.arpa" = {
        master = true;
        file = self + "/resources/0.b.0.8.0.0.7.7.1.0.a.2.ip6.arpa.zone";
        slaves = ibh_ans_ip;
      };

      # ipv6 peering
      "9.7.0.0.8.f.7.0.1.0.0.2.ip6.arpa" = {
        master = true;
        file = "/var/lib/bind/ixp-deploy/9.7.0.0.8.f.7.0.1.0.0.2.ip6.arpa.db";
        slaves = ibh_ans_ip;
      };

      # ipv4 peering
      "64-127.151.201.193.in-addr.arpa" = {
        master = true;
        file = "/var/lib/bind/ixp-deploy/64-127.151.201.193.in-addr.arpa.db";
        slaves = ibh_ans_ip;
      };

      "ixpect.net" = {
        master = true;
        file = self + "/resources/ixpect.net.zone";
        slaves = ibh_ans_ip;
      };
    };

    extraOptions = ''    
      # this is hidden primary only, no recursive lookups allowed
      recursion no;

      # obscure bind9 chaos version queries
      version "DD-IX Authoritative Name Server";

      # track stats on zones
      zone-statistics yes;
    '';
  };
}
