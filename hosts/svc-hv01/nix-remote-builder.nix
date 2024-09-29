{ lib, config, pkgs, ... }:

let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyUpSzFa+XCoxH8lZajmIOtCRpvq+riw1cX+N5LHpvI marcel_nixbuild"
  ];
in

{
  nix.settings.trusted-users = [ "nix-remote-builder" ];

  users.users."nix-remote-builder" = {
    group = "nogroup";
    isNormalUser = true;
    openssh.authorizedKeys.keys = map
      (key:
        let
          wrapper-dispatch-ssh-nix = pkgs.writeShellScriptBin "wrapper-dispatch-ssh-nix" /* bash */ ''
            case $SSH_ORIGINAL_COMMAND in
              "nix-daemon --stdio")
                exec ${config.nix.package}/bin/nix-daemon --stdio
                ;;
              "nix-store --serve --write")
                exec ${config.nix.package}/bin/nix-store --serve --write
                ;;
              *)
                echo "Access is only allowed for nix remote building, not running command \"$SSH_ORIGINAL_COMMAND\"" 1>&2
                exit 1
            esac
          '';

        in
        "restrict,pty,command=\"${lib.getExe wrapper-dispatch-ssh-nix}\" ${key}"
      )
      keys;
  };
}
