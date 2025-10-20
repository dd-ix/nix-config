{ config, lib, pkgs, ... }:

let
  cfg = config.services.anubis;
in
{
  options = {
    services.anubis = {
      autoConfigure = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to configure anubis with the domain automatically with nginx.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain which should be protected.";
      };

      paths = lib.mkOption {
        type = with lib.types; listOf str;
        description = "Paths which should be protected.";
      };
    };
  };

  config = lib.mkIf cfg.autoConfigure {
    services = {
      anubis = {
        defaultOptions.settings = {
          # seems to only work with one anubis instance
          # probably requires https://anubis.techaro.lol/docs/admin/policies/#valkey
          # COOKIE_DYNAMIC_DOMAIN = true;
          DIFFICULTY = 4;
          OG_PASSTHROUGH = true;
          ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."anubis/ed25519_priv_key".path;
          WEBMASTER_EMAIL = "noc@dd-ix.net";
        };
        instances.default = {
          extraFlags = [
            "-cookie-prefix dd-ix.anubis"
          ];
          settings = {
            REDIRECT_DOMAINS = cfg.domain;
            TARGET = " ";
          };
        };
        package = pkgs.anubis.overrideAttrs ({ patches ? [ ], ... }: {
          patches = patches ++ [
            ./anubis-sane-default-http-codes.diff
          ];
        });

        paths = lib.mkDefault [ "/" ];
      };

      nginx.virtualHosts.${cfg.domain}.locations = {
        "/.within.website/" = {
          proxyPass = "http://unix:" + config.services.anubis.instances.default.settings.BIND + ":";
          extraConfig = /* nginx */ ''
            auth_request off;
            # nginx auth_request includes headers but not body
            proxy_set_header Content-Length   "";
            proxy_pass_request_body           off;
          '';
        };
        "@redirectToAnubis" = {
          # https://github.com/TecharoHQ/anubis/issues/390#issuecomment-2850148701
          # return = "307 /.within.website/?redir=$scheme://$host$request_uri";
          return = "307 /.within.website/?redir=$request_uri";
          extraConfig = /* nginx */ ''
            auth_request off;
          '';
        };
      } // (
        let
          anubisExtraConfig = /* nginx */ ''
            auth_request /.within.website/x/cmd/anubis/api/check;
            error_page 401 = @redirectToAnubis;
          '';
        in
        lib.genAttrs cfg.paths (name:
          if (name == "/") then {
            extraConfig = anubisExtraConfig;
          } else
            let
              rootLocation = config.services.nginx.virtualHosts."${cfg.domain}".locations."/";
            in
            {
              inherit (rootLocation) proxyPass uwsgiPass;
              extraConfig = anubisExtraConfig;
            })
      );
    };

    sops.secrets."anubis/ed25519_priv_key".owner = "anubis";

    systemd.services.anubis-default.serviceConfig.Group = lib.mkForce "nginx";
  };
}
