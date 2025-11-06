{
  services.resolved = {
    enable = true;
    dnssec = "true";
  };

  # prefer ipv6 nameservers
  networking.networkmanager.settings.connection = {
    "ipv4.dns-priority" = 100;
    "ipv6.dns-priority" = 1;
  };
}
