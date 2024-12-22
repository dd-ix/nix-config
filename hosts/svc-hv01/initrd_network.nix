let
  mkBondedInterface = name: permaddr: bond: {
    inherit name; addresses = [ ];
    link = { inherit permaddr; state = "up"; kind = "physical"; master = bond; };
  };
  mkVlan = link: id: master: {
    name = "${link}.${builtins.toString id}";
    addresses = [ ];
    link = { inherit link master; state = "up"; kind = "vlan"; vlan_id = id; };
  };
  mkBridge = name: { inherit name; addresses = [ ]; link = { state = "up"; kind = "bridge"; }; };
in
{
  networking.ifstate.initrd = {
    enable = true;
    settings = {
      interfaces = [
        { name = "enp0s29u1u1u5"; addresses = [ ]; link = { state = "down"; kind = "physical"; businfo = "usb-0000:00:1d.0-1.1.5"; }; }
        { name = "bond"; addresses = [ ]; link = { state = "up"; kind = "bond"; }; }
        { name = "eno2"; addresses = [ ]; link = { state = "up"; kind = "physical"; businfo = "0000:06:00.0"; master = "ixp-peering"; }; }
        { name = "eno3"; addresses = [ ]; link = { state = "down"; kind = "physical"; businfo = "0000:06:00.1"; }; }
        { name = "eno4"; addresses = [ ]; link = { state = "down"; kind = "physical"; businfo = "0000:06:00.2"; }; }
        { name = "eno5"; addresses = [ ]; link = { state = "down"; kind = "physical"; businfo = "0000:06:00.3"; }; }
        (mkBondedInterface "enp144s0" "00:02:c9:23:4c:20" "bond")
        (mkBondedInterface "enp144s0d1" "00:02:c9:23:4c:21" "bond")
        { name = "svc-internet"; addresses = [ ]; link = { state = "up"; kind = "bridge"; }; }
        { name = "svc-services"; addresses = [ ]; link = { state = "up"; kind = "bridge"; }; }
        (mkVlan "bond" 101 "svc-services")
        (mkVlan "bond" 100 "svc-internet")
        (mkVlan "bond" 102 "svc-management")
        (mkVlan "bond" 103 "svc-lab")
        (mkVlan "bond" 104 "svc-admin")
        (mkVlan "bond" 301 "svc-ixp-mgmt")
        ((mkBridge "svc-management") // { addresses = [ "2a01:7700:80b0:7000::2/64" ]; })
        (mkBridge "svc-lib")
        (mkBridge "svc-admin")
        (mkBridge "ixp-peering")
        (mkBridge "svc-ixp-mgmt")
      ];
      routing.routes = [{
        to = "::/0";
        dev = "svc-management";
        via = "fe80::1";
        proto = 4;
        preference = 1024;
      }];
    };
  };

  boot.initrd.network = {
    enable = true;

    ssh = {
      enable = true;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC1946eFFMcnbJvNGR460BPIELJAGNvrsKP9FhhP/5w3aDyHKXeT31haPUtH/OpLqMfZvSo7kT5BGox+DworBjCc6pXRD09d2MC9SQVR4573YYl2iA1nwEbRGnmC7anAP5+7jLdywk5ztJ67IC4rB+2Mgm+NIMo0UmvUlELlzLjDnnK/3taUJr9hEA9NrjfQlyyW1tESODZ7RNSX7PQ7LD/G/uiQthZ3nLgcWcFsxGuT8lWbXH0+3t8pZgolngfVGW0bs8byD4LWN3d2/QG2gTDogQL6zloE+M1cTszwIGHRMHwyeBohFhzuE/IntuHqokkiwIQIUZUG9z5MZJABfFs2CoIqY2oJdpEDuIv4mdysjVxFNT9x5COvYmNq7N753AOBVwyIHErTTULEzkHRREtwZRY8g5VY8u78caZUKWyKGxIfvYOkaFxM3a8czlKffMfv0lD672EKuzPteqKHu8BIZr4SC9Bt/iXYYZ+QqIUuw3iTaSmKF+eNzMaVzQhO50fD9XXBNvPrZZTR8+ubLBngrD9pz/jkk9rSHgi7ScJ2SeZP+PO19C4a8DrVqB9+N80/pc+F2qGSO3JEt1cZZB1FLXn+pYbqJeWGGssEaQQ2YTjyUZVtwpRdk//BWTY4B9hrvez4CMwoam1m36DhrHkfgOTTcJzlqcIylWBb5/4w== openpgp:0x2885416F"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkqgoqKuBqN7wl73OPg3gGedGL5x9LG57xgcFF6l1nBs14H0PVscvo2fys2uNdeRrbgtYo8kN/rrTbXkRQzx/rwXg9py6sN3yYzJj9AZdk5jNSnUSSSk58tK11BYISb3koMWKzsKa83fUwEZm0kVPJXTIYo4q9soSncpPk8IXmBbfUU4f+aeiWuRGzQ2/UZwARCNFBMn1QgqNrYlVPqElty1HYxj9sTPdp/D2thRWgdUw39X47401i8N+WtsavDlYQjte1dsrk4sq9S1F44Xm4O7EaJdwLkZCPu+cWTn1gY0L9oCxOIFPg3zrXYHBcD7AHCTnk0iwdlf6REKNRKHDWv16qlhmyRwW58bO0xW+T9MVGJ1yKhh7ex9mypBFa3O5Pl/8NwQTbai01daYzgPzW1T89GgrEJHX3y0DL8afvWg3+BAjsHiXav+0rbRY4GWZjR6i1N79gc5NDbDM1BtKKPBTk575v6BnvHpYOjXq/zTjMSRC24ESa6ir5WPccavlJ1F4I+QfH9SPMItRn3uE2Eq9sjiPEoUPiChZZJigirX1TcMXOZH0oRWC9+9MdKMCmKDArM1jmCvBc+FOKz/J7AaJOzskHBpUOiz9k40JEhANHhKPkZU582S6mwyAseKjPwXVrz1XQcLgR+WdtKctQBtxrcscKG/YRQ1pbbfbwGw== openpgp:0xDEEDEB56"
        "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMbUizElFyULDlpEE9XHWWOca4ZXepS18ljh4Fj4YnJOAs7sbYzzhfMUiD703FIgK5YObzOlheu/PBbwUOStgcmPDuRalZWLr+0kCUYERfjLHkgliFx96xEFw9dluvII6JpbzFI/uvkEkQ3ESKapRcYAuBTk2sRoit8za+HX9sLmMueqNtN4H92sFYYm1wWy3FFgz/NN+uTh7F5nmA7SrSS/fpbmugcgBdR/Zy1YwSA8Rl1pagEvgN9/qAnP7pssvXr9pTCUNxVSQ7FlTUOHmxzG16RybYRikgevQaHtFYvmS7AuRvRDlQWhHt1drREGOIwwZPXD1smfQAsvP66J85j9aeanZdoBoJcvvFNer3071QGmi+5NHDSiG+YvoWt7qgiKLF4lOfByzjdoRRSg01uuhdQLOHHt0hbfyGS6hx//1MtjiXTElXvOOiUJ6AqfCSwOTK+72W6VKhKYcO11+Ngym1dyF3TtVcoEYN3JpUdbNq+qctMzXFMGovPEEMh7s= melody"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuSECgZffKGH56xoVzITe43IdRyYbAr3sef8TJOrGGH liske"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK255EY8KUx5cMXSuoERXJSzVnkDUM+y8sMAVrRoDBnn marcel"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5BQ5JF5v+LisKXafxKQrKfwthVvWydMrr6BDJ2YyAg adb"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6nI2MlJcERyDuOqCtW+2K/S5aR6wDAuyI6kSh8EgGvCSdp5TFTxSgUU8Vo78QTnL8vz0Vy1RYffwIUfNFNqRy8DX16UpQ/NYbWnpqoZHVYex4SIg5G7ZbofOIb0CPDt8ZqCk0GaRp2FprjO4QGkeKzPA3mxqAabtxn6/cGK+4FJE2NCRHhy1GR3TcDjOQrWmKeSnar7NI+oZZmhzaVl6+H3YVat/vlJLQXlyneDeQZ4dOUZanbF8lAajgl7pEu18auVW0Db99A9MAOEgvmMTyU2TFXTa+XY2ZmLIO8EWAkzQHpQu0U2i5ZD0Uj/ppYLIdY6aixXOJYylri2d1Nlil+3RUU16y2TeTwSycldDpfUtCRp+6taLfxz245x82HuU4UqHP6MsOMuk5qD1blYSXE+2gyTC4yTujxc6ykbNMwmyOxzkM+jDQ2DepboDKdBzuMnAwpQM/zjfXjultfiSM8e+ph95wpNz64yep6kUvJzgjLsD8sHAOFWByGxxJJ0yrj10jchZg8osZvQAnfnwtX8+/sT6NFW7Ikxpz1Q/PPMCmlviiUCyu7N4TNh3vuQaMlOf6Oe8+HirHg2nPeZ+pIuZG2B80CafcAlY795dPBv3tYC+gYPyJzDUe1QhTqhlS5vtY2l46Jj2ukRsE0FYSbDVyfn1HevS9/mcBxXJ8kQ== maurice"
      ];
    };

    postCommands = ''
      zpool import -a
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };
}
