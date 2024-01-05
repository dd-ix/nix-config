# Hot to set PostgreSQL user password in NixOS: https://discourse.nixos.org/t/assign-password-to-postgres-user-declaratively/9726/3
# How to extend module: https://gist.github.com/danbst/f1e81358d5dd0ba9c763a950e91a25d0
# PostgreSQL module: https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/databases/postgresql.nix

{ lib, config, ... }:
let
  cfg = config.services.postgresql;
in
{
  options.services.postgresql.ensureUsers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        ensurePasswordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = lib.mdDoc "Password of the user to ensure.";
          default = null;
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    systemd.services.postgresql.postStart =
      lib.concatMapStrings
        (user:
          lib.optionalString
            (user.ensurePasswordFile != null)
            ''
              $PSQL -tA <<'EOF'
                DO $$
                DECLARE password TEXT;
                BEGIN
                  password := trim(both from replace(pg_read_file('${user.ensurePasswordFile}'), E'\n', '''));
                  EXECUTE format('ALTER ROLE ${user.name} WITH PASSWORD '''%s''';', password);
                END $$;
              EOF
            ''
        )
        cfg.ensureUsers;
  };
}
