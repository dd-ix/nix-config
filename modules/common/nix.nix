{ lib, inputs, ... }:

{
  nix.settings = {
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
  };

  environment.variables = {
    # force builds to use nix deamon, also if user is root
    NIX_REMOTE = "daemon";
    # fix nixpkgs path for nix-shell -p 
    NIX_PATH = lib.mkForce "nixpkgs=${inputs.nixpkgs}";
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
}
