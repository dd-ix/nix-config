{
  networking.nameservers = [
    # rns-01.ibh.net
    "2a01:7700:0:1035::1:53"
    # rns-02.ibh.net
    "2a01:7700:0:1036::1:53"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      LLMNR = "false";
      FallbackDNS = null;
    };
  };
}
