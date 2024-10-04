let
  prodMotd = ''
    DD-IX Production System
  '';
in
{
  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh/tassilo
      ../../keys/ssh/melody
      ../../keys/ssh/fiasko
      ../../keys/ssh/marcel
      ../../keys/ssh/adb
      ../../keys/ssh/maurice
      ../../keys/ssh/checkmk
    ];
  };
  users.motd = prodMotd;
  services.openssh.enable = true;
}
