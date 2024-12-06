{
  dd-ix.nets = {
    internet = {
      netId = "2a01:7700:80b0:6000";
      cidr = 64;
      vlan = 100;
      #gw.hostId = "1";
    };
    services = {
      netId = "2a01:7700:80b0:6001";
      cidr = 64;
      vlan = 101;
      #gw.hostId = "1";
    };
    management = {
      netId = "2a01:7700:80b0:7000";
      cidr = 64;
      vlan = 102;
      #gw.hostId = "1";
    };
    lab = {
      netId = "2a01:7700:80b0:7001";
      cidr = 64;
      vlan = 103;
      #gw.hostId = "1";
    };
    admin = {
      netId = "2a01:7700:80b0:7002";
      cidr = 64;
      vlan = 104;
      #gw.hostId = "1";
    };
    ixp-mgmt = {
      netId = "2a01:7700:80b0:4101";
      cidr = 64;
      vlan = 301;
      #gw.hostId = "1";
    };
  };
}
