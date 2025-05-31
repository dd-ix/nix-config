{ lib, ... }:

{
  networking = {
    # force: override IBH default nameservers
    nameservers = lib.mkForce [
      # rns0.ipberlin.com
      "2a02:f28:2:0:194:29:226:55"
      "194.29.226.55"
      # rns1.ipberlin.com
      "2a02:f28:2:1:194:29:230:55"
      "194.29.230.55"
    ];

    # force: override IBH default timeServers
    timeServers = lib.mkForce [
      "0.de.pool.ntp.org"
      "1.de.pool.ntp.org"
      "2.de.pool.ntp.org"
      "3.de.pool.ntp.org"
    ];

    ifstate = {
      enable = true;
      settings = {
        interfaces = [{
          name = "eth0";
          addresses = [
            "2a02:f28:1:70::10/64"
            "91.102.12.190/29"
          ];
          link = {
            state = "up";
            kind = "physical";
            address = "bc:24:11:23:9f:fc";
            #businfo = "0000:00:12.0";
          };
        }];
        routing.routes = [
          { to = "::/0"; via = "2a02:f28:1:70::1"; }
          { to = "0.0.0.0/0"; via = "91.102.12.185"; }
        ];
      };
    };
  };
}
