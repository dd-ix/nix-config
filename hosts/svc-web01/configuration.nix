{ config, pkgs, ... }:

let
  domains = [
    "dd-ix.net"
    "www.dd-ix.net"
    "content.dd-ix.net"
    "talks.dd-ix.net"
    "opening.dd-ix.net"
  ];
in
{
  dd-ix = {
    useFpx = true;
    hostName = "svc-web01";

    microvm = {
      mem = 2048;
      vcpu = 2;
    };

    acme = map (name: { inherit name; group = "nginx"; }) domains;

    monitoring = {
      enable = true;
    };
  };

  users.users.ddix-deploy = {
    isNormalUser = true;
    openssh.authorizedKeys = {
      keys = [
        # arouteserver@svc-adm01
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0vuZeitSJiVxdACcwB8s1Cj2hi0wXjDMbhLelEJmIv"
      ] ++ config.users.users.root.openssh.authorizedKeys.keys;
    };
  };

  environment.systemPackages = with pkgs; [
    # ansible
    python3
  ];

  system.stateVersion = "23.11";
}
