{ pkgs, ... }:
{
  dd-ix = {
    microvm = {
      enable = true;

      mem = 1024 * 2;
      vcpu = 2;

      hostName = "svc-adm01";
      mac = "22:99:63:77:e4:42";
      vlan = "l";

      v6Addr = "2a01:7700:80b0:7002::2/64";
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    git
    fping 
    inetutils
    mc
    vim
  ];

  system.stateVersion = "23.11";
}
