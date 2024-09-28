let
  addr = "2a01:7700:80b0:6001::15";
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-crm01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;

      mac = "e2:d0:2f:67:dd:1e";
      vlan = "s";

      v6Addr = "${addr}/64";
    };

    acme = [
      { name = "crm.dd-ix.net"; group = "nginx"; }
    ];

    rpx = {
      domains = [ "crm.dd-ix.net" ];
      addr = "[${addr}]:443";
    };

    postgres = [ "odoo" ];

    monitoring = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
