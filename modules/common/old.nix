{ lib, inputs, pkgs, ... }:

{
  hardware = {
    enableRedistributableFirmware = true;
  };

  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    trusted-users = [ "@wheel" ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "de_DE.UTF-8";
    };
  };

  environment.systemPackages = with pkgs; [
    screen
  ];

  programs = {
    git.enable = true;
    htop.enable = true;
  };

  environment.interactiveShellInit = /* sh */ ''
    # raise some awareness torwards failed services
    systemctl --no-pager --failed || true
  '';

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
}
