# see https://raw.githubusercontent.com/SuperSandro2000/nixos-modules/master/modules/nix.nix

{ config, lib, pkgs, ... }:

let
  diffBoot = /* bash */ ''
    if [[ "''${NIXOS_ACTION-}" == boot && -e /run/current-system && -e "''${1-}" ]]; then
      echo "=== nix diff ==="
      ${lib.getExe config.nix.package} --extra-experimental-features nix-command store diff-closures /run/current-system "''${1-}"
      echo "=== nix diff ==="
    fi
  '';
in
{
  boot.loader = {
    grub.extraInstallCommands = diffBoot;
    systemd-boot.extraInstallCommands = diffBoot;
  };

  system = {
    activationScripts = {
      deleteChannels = /* bash */ ''
        echo "=== nix channel cleanup"
        rm -rfv /root/{.nix-channels,.nix-defexpr} /home/*/{.nix-channels,.nix-defexpr} /nix/var/nix/profiles/per-user/*/channels* || true
      '';

      deleteUserProfiles = /* bash */ ''
        echo "=== nix user profile cleanup"
        rm -rfv /root/.nix-profile /home/*/.nix-profile /nix/var/nix/profiles/per-user/*/profile* || true
      '';

      diff-system = {
        supportsDryActivation = true;
        text = /* bash */ ''
          if [[ -e /run/current-system && -e $systemConfig ]]; then
            echo "=== nix diff"
            ${lib.getExe config.nix.package} --extra-experimental-features nix-command store diff-closures /run/current-system $systemConfig || true
            echo "==="
          fi
        '';
      };
    };

    build.installBootLoader = lib.mkMerge [
      (lib.mkIf config.boot.isContainer (pkgs.writeShellScript "diff-closures-on-nspawn" diffBoot))
      (lib.mkIf (config.boot.loader.external.enable && !config.boot.isContainer) (lib.mkForce (pkgs.writeShellScript "install-bootloader-external" ''
        ${diffBoot}
        exec ${config.boot.loader.external.installHook}
      '')))
    ];
  };
}
