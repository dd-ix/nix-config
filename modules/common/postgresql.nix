{ config, lib, ... }:

let
  cfg = config.services.postgresql;
  hasPostgresqlSetup = lib.versionAtLeast lib.version "25.11pre";
in
{
  options.services.postgresql.ensureUsers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options.ensurePasswordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file containing the password of the user.";
      };
    });
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      # TODO: drop the mkMerge when support for 25.05 is removed and we always have postgresql and postgresql-setup
      services = {
        "postgresql${lib.optionalString hasPostgresqlSetup "-setup"}".postStart =
          lib.concatMapStrings
            (user: lib.optionalString (user.ensurePasswordFile != null) ''
              $PSQL -tA <<'EOF'
                DO $$
                DECLARE password TEXT;
                BEGIN
                  password := trim(both from replace(pg_read_file('${user.ensurePasswordFile}'), E'\n', '''));
                  EXECUTE format('ALTER ROLE ${user.name} WITH PASSWORD '''%s''';', password);
                END $$;
              EOF
            '')
            cfg.ensureUsers;
      };
    };
  };
}
