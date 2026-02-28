{ config, lib, ... }:

let
  cfg = config.services.postgresql;
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
    systemd.services."postgresql-setup".postStart =
      lib.concatMapStrings
        (user: lib.optionalString (user.ensurePasswordFile != null) /* bash */ ''
          psql -tA <<'EOF'
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
}
