{ ... }:
{
  time.timeZone = "Europe/Berlin";

  networking.timeServers = [
    "ntp1.ibh.net"
    "ntp2.ibh.net"
    "ntp3.ibh.net"
  ];

  services.chrony.enable = true;
}
