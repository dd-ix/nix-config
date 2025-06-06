{ self, lib, config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixVersions.nix_2_28;

    settings = {
      auto-optimise-store = true;

      # Fallback quickly if substituters are not available.
      connect-timeout = 5;

      # Enable flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # The default at 10 is rarely enough.
      log-lines = lib.mkDefault 25;

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      # If one connection to a remote builder failed, don't cancel already running builds!
      keep-going = true;

      substituters = [ "https://nix-community.cachix.org/?priority=45" "https://hydra.hq.c3d2.de/?priority=50" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "hydra.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps=" ];
      trusted-users = [ "@wheel" ];
    };

    # nixos-modules
    deleteChannels = true;
    deleteUserProfiles = true;
    diffSystem = true;

    # lower nix-daemon system resources priority
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
  };

  environment.variables = {
    # force builds to use nix daemon, also if user is root
    NIX_REMOTE = "daemon";
    # fix nixpkgs path for nix-shell -p 
    NIX_PATH = lib.mkForce "nixpkgs=${self.inputs.nixpkgs}";
  };

  systemd.services.nix-daemon.serviceConfig = {
    KillMode = "control-group"; # reset to default to kill child processes
    OOMScoreAdjust = 250; # be more likely killed than other services
    Restart = "on-failure"; # restart if killed eg oom killed
  };

  programs.command-not-found.enable = false;
}

