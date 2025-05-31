{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  dd-ix.hostName = "ext-mon01";

  networking = {
    nameservers = lib.mkForce [ "194.29.226.55" "194.29.230.55" ];
    timeServers = lib.mkForce [
      "0.de.pool.ntp.org"
    ];

    interfaces.ens18 = {
      ipv6.addresses = [{
        address = "2a02:f28:1:70::10";
        prefixLength = 64;
      }];
      ipv4.addresses = [{
        address = "91.102.12.190";
        prefixLength = 29;
      }];
    };
    defaultGateway = {
      address = "91.102.12.185";
      interface = "ens18";
    };
    defaultGateway6 = {
      address = "2a02:f28:1:70::1";
      interface = "ens18";
    };
  };
  users.users.ddadmin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
      vim
      htop
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6nI2MlJcERyDuOqCtW+2K/S5aR6wDAuyI6kSh8EgGvCSdp5TFTxSgUU8Vo78QTnL8vz0Vy1RYffwIUfNFNqRy8DX16UpQ/NYbWnpqoZHVYex4SIg5G7ZbofOIb0CPDt8ZqCk0GaRp2FprjO4QGkeKzPA3mxqAabtxn6/cGK+4FJE2NCRHhy1GR3TcDjOQrWmKeSnar7NI+oZZmhzaVl6+H3YVat/vlJLQXlyneDeQZ4dOUZanbF8lAajgl7pEu18auVW0Db99A9MAOEgvmMTyU2TFXTa+XY2ZmLIO8EWAkzQHpQu0U2i5ZD0Uj/ppYLIdY6aixXOJYylri2d1Nlil+3RUU16y2TeTwSycldDpfUtCRp+6taLfxz245x82HuU4UqHP6MsOMuk5qD1blYSXE+2gyTC4yTujxc6ykbNMwmyOxzkM+jDQ2DepboDKdBzuMnAwpQM/zjfXjultfiSM8e+ph95wpNz64yep6kUvJzgjLsD8sHAOFWByGxxJJ0yrj10jchZg8osZvQAnfnwtX8+/sT6NFW7Ikxpz1Q/PPMCmlviiUCyu7N4TNh3vuQaMlOf6Oe8+HirHg2nPeZ+pIuZG2B80CafcAlY795dPBv3tYC+gYPyJzDUe1QhTqhlS5vtY2l46Jj2ukRsE0FYSbDVyfn1HevS9/mcBxXJ8kQ== yummy@Nimuedaertya"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6NLB8EHnUgl2GO2uaojdf3p3YpsHH6px6CZleif8klhLN+ro5KeFK2OXC2SO3Vo4qgF/NySdsoInV9JEsssELZ2ttVbeKxI6f76V5dZgGI7qoSf4E0TXIgpS9n9K2AEmRKr65uC2jgkSJuo/T1mF+4/Nzyo706FT/GGVoiBktgq9umbYX0vIQkTMFAcw921NwFCWFQcMYRruaH01tLu6HIAdJ9FVG8MAt84hCr4D4PobD6b029bHXTzcixsguRtl+q4fQAl3WK3HAxT+txN91CDoP2eENo3gbmdTBprD2RcB/hz5iI6IaY3p1+8fTX2ehvI3loRA8Qjr/xzkzMUlpA/8NLKbJD4YxNGgFbauEmEnlC8Evq2vMrxdDr2SjnBAUwzZ63Nq+pUoBNYG/c+h+eO/s7bjnJVe0m2/2ZqPj1jWQp4hGoNzzU1cQmy6TdEWJcg2c8ints5068HN3o0gQKkp1EseNrdB8SuG+me/c/uIOX8dPASgo3Yjv9IGLhhx8GOGQxHEQN9QFC4QyZt/rrAyGmlX342PBNYmmStgVWHiYCcMVUWGlsG0XvG6bvGgmMeHNVsDf6WdMQuLj9luvxJzrd4FlKX6O0X/sIaqMVSkhIbD2+vvKNqrii7JdUTntUPs89L5h9DoDqQWkL13Plg1iQt4/VYeKTbUhYYz1lw== revo-xut@plank"
    ];
  };
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  system.stateVersion = "24.11"; # Did you read the comment?
}

