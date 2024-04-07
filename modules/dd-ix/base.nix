{ pkgs, config, lib, ... }:
let
  regMotd = ''
    DD-IX Staging System
  '';
  prodMotd = ''
    DD-IX Production System
  '';
in
{
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };

  # networking.useNetworkd = true;
  networking.resolvconf.useLocalResolver = false;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_US/ISO-8859-1"
    "C.UTF-8/UTF-8"
  ];

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    screen
    neovim
    wget
    git-crypt
    iftop
    tcpdump
    dig
    mtr
    traceroute
  ];

  programs.vim.defaultEditor = true;
  networking.firewall.enable = lib.mkDefault true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh/tassilo
      ../../keys/ssh/melody
      ../../keys/ssh/fiasko
      ../../keys/ssh/marcel
      ../../keys/ssh/adb
      ../../keys/ssh/maurice
    ];
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  users.motd = prodMotd;

  programs.screen.screenrc = ''
    defscrollback 10000

    startup_message off

    hardstatus on
    hardstatus alwayslastline
    hardstatus string "%w"
  '';
}
