{ self, config, pkgs, lib, ... }:
{
  sops.secrets."dcim_secret_key" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  sops.secrets."dcim_db_pw" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  sops.secrets."dcim_oidc_secret" = {
    sopsFile = self + "/secrets/management/dcim.yaml";
    owner = config.systemd.services.netbox.serviceConfig.User;
  };

  users.users. nginx.extraGroups = [ "netbox" ];

  services = {
    postgresql.enable = lib.mkForce false;
    netbox = {
      enable = true;
      package = pkgs.netbox_4_2.overrideAttrs (old: {
        installPhase = old.installPhase + ''
          ln -s ${self + "/resources/netbox/pipeline.py"} $out/opt/netbox/netbox/netbox/ddix_pipeline.py
        '';
      });
      secretKeyFile = "${config.sops.secrets.dcim_secret_key.path}";
      plugins = python3Packages: with python3Packages; [ python-jose ];
      settings = {
        ALLOWED_HOSTS = [ "dcim.${config.dd-ix.domain}" ];

        DATABASE = {
          NAME = "netbox";
          USER = "netbox";
          HOST = lib.mkForce "svc-pg01.dd-ix.net";
          PORT = 5432;
          PASSWORD = "";
        };

        REMOTE_AUTH_ENABLED = true;
        REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
        SOCIAL_AUTH_OIDC_ENDPOINT = "https://auth.dd-ix.net/application/o/dcim/";
        SOCIAL_AUTH_OIDC_KEY = "ooCkcwLzdXcCMVJFGzZY0g0H2Y1gLmXHI2ZcPbva";
        LOGOUT_REDIRECT_URL = "https://auth.dd-ix.net/application/o/dcim/end-session/";
      };
      extraConfig = ''
        with open('${config.sops.secrets."dcim_db_pw".path}', 'r') as file:
          DATABASE['PASSWORD'] = file.read()

        with open('${config.sops.secrets."dcim_oidc_secret".path}', 'r') as file:
          SOCIAL_AUTH_OIDC_SECRET = file.read()

      
        SOCIAL_AUTH_PIPELINE = (
          ###################
          # Default pipelines
          ###################

          # Get the information we can about the user and return it in a simple
          # format to create the user instance later. In some cases the details are
          # already part of the auth response from the provider, but sometimes this
          # could hit a provider API.
          'social_core.pipeline.social_auth.social_details',

          # Get the social uid from whichever service we're authing thru. The uid is
          # the unique identifier of the given user in the provider.
          'social_core.pipeline.social_auth.social_uid',

          # Verifies that the current auth process is valid within the current
          # project, this is where emails and domains whitelists are applied (if
          # defined).
          'social_core.pipeline.social_auth.auth_allowed',

          # Checks if the current social-account is already associated in the site.
          'social_core.pipeline.social_auth.social_user',

          # Make up a username for this person, appends a random string at the end if
          # there's any collision.
          'social_core.pipeline.user.get_username',

          # Send a validation email to the user to verify its email address.
          # Disabled by default.
          # 'social_core.pipeline.mail.mail_validation',

          # Associates the current social details with another user account with
          # a similar email address. Disabled by default.
          # 'social_core.pipeline.social_auth.associate_by_email',

          # Create a user account if we haven't found one yet.
          'social_core.pipeline.user.create_user',

          # Create the record that associates the social account with the user.
          'social_core.pipeline.social_auth.associate_user',

          # Populate the extra_data field in the social record with the values
          # specified by settings (and the default ones like access_token, etc).
          'social_core.pipeline.social_auth.load_extra_data',

          # Update the user record with any changed info from the auth service.
          'social_core.pipeline.user.user_details',

          ###################
          # Custom pipelines
          ###################
          # Set authentik Groups
          'netbox.ddix_pipeline.add_groups',
          'netbox.ddix_pipeline.remove_groups',
          # Set Roles
          'netbox.ddix_pipeline.set_roles'
        )
      '';
    };

    nginx = {
      enable = true;
      virtualHosts."dcim.${config.dd-ix.domain}" = {
        listen = [{
          addr = "[::]:443";
          proxyProtocol = true;
          ssl = true;
        }];

        onlySSL = true;
        useACMEHost = "dcim.${config.dd-ix.domain}";

        locations = {
          "/static/".alias = "${config.services.netbox.dataDir}/static/";
          "/".proxyPass = "http://${config.services.netbox.listenAddress}:${toString config.services.netbox.port}";
        };
      };
    };
  };
}
