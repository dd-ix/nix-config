{ lib, ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = true;

    # Keep dmesg/journalctl -k output readable by NOT logging
    # each refused connection on the open internet.
    logRefusedConnections = lib.mkDefault false;
  };

  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd = {
    services.NetworkManager-wait-online.enable = false;
    network.wait-online.enable = false;
  };
}
