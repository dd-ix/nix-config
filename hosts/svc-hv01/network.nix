{ lib, config, ... }:

let
  mkBondedInterface = name: permaddr: bond: {
    inherit name;
    link = { inherit permaddr; state = "up"; kind = "physical"; master = bond; };
  };
in
{
  networking.ifstate = {
    enable = true;
    initrd.enable = true;

    settings = {
      # TODO: probably remove with ifstate v2
      defaults = [{
        # list of defaults settings
        match = [{
          # regex matching all interfaces
          ifname = "";
        }];
        # remove any ip addresses if an interface has no `addresses:` setting
        clear_addresses = true;
        # add some implicit link settings
        link = {
          state = "down";
          # TODO: never gets the interfaces into a clean state
          #ifalias = "";
        };
      }];

      # ignore vm tap interfaces
      ignore.ifname = [ "^vm-.+$" "^vnet\\d+$" ];
      interfaces = [
        { name = "enp0s29u1u1u5"; link = { kind = "physical"; businfo = "usb-0000:00:1d.0-1.1.5"; }; }
        {
          name = "bond";
          link = {
            state = "up";
            kind = "bond";
            # 802.3ad
            bond_mode = 4;
            bond_ad_lacp_rate = 1;
            # layer3+4
            bond_xmit_hash_policy = 1;
            bond_miimon = 100;
            bond_updelay = 300;
          };
        }
        # used in ixp-as11201
        { name = "eno2"; link = { kind = "physical"; businfo = "0000:06:00.0"; }; }
        # used in prj-llb01
        { name = "eno3"; link = { kind = "physical"; businfo = "0000:06:00.1"; }; }
        { name = "eno4"; link = { kind = "physical"; businfo = "0000:06:00.2"; }; }
        { name = "eno5"; link = { kind = "physical"; businfo = "0000:06:00.3"; }; }
        (mkBondedInterface "enp144s0" "00:02:c9:23:4c:20" "bond")
        (mkBondedInterface "enp144s0d1" "00:02:c9:23:4c:21" "bond")
      ] ++
      (lib.flatten (lib.mapAttrsToList
        (name: value: [
          {
            name = value.bridge;
            addresses = lib.mkIf (name == "management") [ "2a01:7700:80b0:7000::2/64" ];
            link = { state = "up"; kind = "bridge"; };
          }
          {
            name = "bond.${builtins.toString value.vlan}";
            link = { state = "up"; kind = "vlan"; link = "bond"; vlan_id = value.vlan; master = value.bridge; };
          }
        ])
        config.dd-ix.nets
      ));
      routing.routes = [{
        to = "::/0";
        dev = "svc-management";
        via = "fe80::1";
      }];
    };
  };

  boot.initrd.network = {
    enable = true;

    ssh = {
      enable = true;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6NLB8EHnUgl2GO2uaojdf3p3YpsHH6px6CZleif8klhLN+ro5KeFK2OXC2SO3Vo4qgF/NySdsoInV9JEsssELZ2ttVbeKxI6f76V5dZgGI7qoSf4E0TXIgpS9n9K2AEmRKr65uC2jgkSJuo/T1mF+4/Nzyo706FT/GGVoiBktgq9umbYX0vIQkTMFAcw921NwFCWFQcMYRruaH01tLu6HIAdJ9FVG8MAt84hCr4D4PobD6b029bHXTzcixsguRtl+q4fQAl3WK3HAxT+txN91CDoP2eENo3gbmdTBprD2RcB/hz5iI6IaY3p1+8fTX2ehvI3loRA8Qjr/xzkzMUlpA/8NLKbJD4YxNGgFbauEmEnlC8Evq2vMrxdDr2SjnBAUwzZ63Nq+pUoBNYG/c+h+eO/s7bjnJVe0m2/2ZqPj1jWQp4hGoNzzU1cQmy6TdEWJcg2c8ints5068HN3o0gQKkp1EseNrdB8SuG+me/c/uIOX8dPASgo3Yjv9IGLhhx8GOGQxHEQN9QFC4QyZt/rrAyGmlX342PBNYmmStgVWHiYCcMVUWGlsG0XvG6bvGgmMeHNVsDf6WdMQuLj9luvxJzrd4FlKX6O0X/sIaqMVSkhIbD2+vvKNqrii7JdUTntUPs89L5h9DoDqQWkL13Plg1iQt4/VYeKTbUhYYz1lw== tassilo"
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

  # enabling and configuring firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };
}
