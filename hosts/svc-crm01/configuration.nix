{ lib, ... }:

{
  dd-ix = {
    useFpx = true;
    hostName = "svc-crm01";

    microvm = {
      enable = true;

      mem = 2048;
      vcpu = 2;
    };

    acme = [
      { name = "crm.dd-ix.net"; group = "nginx"; }
    ];

    postgres = [ "odoo" ];

    monitoring = {
      enable = true;
    };
  };

  # https://github.com/odoo/odoo/issues/50354
  time.timeZone = lib.mkForce "UTC";

  system.stateVersion = "23.11";
}
