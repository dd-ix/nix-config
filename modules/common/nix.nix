{ self, lib, config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixVersions.nix_2_30;

    settings = {
      auto-optimise-store = true;

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

      # sudo users should be able to use nix commands
      trusted-users = [ "@wheel" ];
    };

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

  # verify that the nix binary is working after rebuild
  system.preSwitchChecks.canExecuteNix = lib.mkIf config.nix.enable /* bash */ ''
    if ! ${lib.getExe config.nix.package} --version >/dev/null; then
      echo "Cannot execute nix (${lib.getExe config.nix.package}), aborting..."
      exit 1
    fi
  '';

  system = {
    activationScripts = {
      deleteChannels = /* bash */ ''
        echo "Deleting all channels..."
        rm -rfv /root/{.local/state/nix/defexpr,.nix-channels,.nix-defexpr} /home/*/{.local/state/nix/defexpr,.nix-channels,.nix-defexpr} /nix/var/nix/profiles/per-user/*/channels* || true
      '';

      deleteUserProfiles = /* bash */ ''
        echo "Deleting all user profiles..."
        rm -rfv /root/{.local/state/nix/profile,.nix-profile} /home/*/{.local/state/nix/profile,.nix-profile} /nix/var/nix/profiles/per-user/*/profile* || true
      '';

      diff-system = {
        supportsDryActivation = true;
        text = /* bash */ ''
          if [[ -e /run/current-system && -e $systemConfig ]]; then
            echo
            echo nix diff new system against /run/current-system
            (
              unset PS4
              set -x
              ${lib.getExe config.nix.package} --extra-experimental-features nix-command store diff-closures /run/current-system $systemConfig || true
            )
            echo
          fi
        '';
      };
    };
  };
}

