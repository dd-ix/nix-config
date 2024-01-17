{ ... }:
{
  networking.nameservers = [
    # rns-01.ibh.net
    "2a01:7700:0:1035::1:53"
    "212.111.228.53"
    # rns-02.ibh.net
    "2a01:7700:0:1036::1:53"
    "193.36.123.53"
  ];

  services.resolved = {
    dnssec = "true";
    extraConfig = ''
      FallbackDNS=
    '';
  };
}
