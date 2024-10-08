{ self, pkgs, config, lib, ... }:
let
  cfg = config.dd-ix.monitoring;
in
{
  options.dd-ix.monitoring = {
    enable = lib.mkEnableOption (lib.mdDoc "dd-ix monitoring");
    #name = lib.mkOption {
    #  type = lib.types.str;
    #};
    smart = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 21953;
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "[::]";
        openFirewall = true;
        disabledCollectors = [ ];
        enabledCollectors = [ "systemd" ];
      };
      smartctl = lib.mkIf cfg.smart.enable {
        enable = true;
        maxInterval = "10m";
        listenAddress = cfg.smart.host;
        inherit (cfg.smart) port devices;
      };
    };

    # 6556: checkmk librenms agent
    networking.firewall.allowedTCPPorts = [ 9100 6556 ] ++ (if cfg.smart.enable then [ 9101 ] else [ ]);

    # checkmk monitoring
    users.users.root.openssh.authorizedKeys.keys =
      let
        checkMkAgent = pkgs.writeShellScriptBin "check_mk_agent.linux" (builtins.readFile (self + /resources/check_mk_agent.linux));
      in
      [
        "restrict,pty,command=\"${lib.getExe checkMkAgent}\",from=\"2a01:7700:80b0:7002::6\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1qKvfDAIuNbMrQ37HHs8Dfo7nn/WKw1zcxv71o55w4 DD-IX Monitoring"
      ];

    services.xinetd = {
      enable = true;
      services = [{
        name = "check_mk_agent.librenms";
        unlisted = true;
        port = 6556;
        protocol = "tcp";
        user = "root";
        server = lib.getExe (pkgs.writeShellScriptBin "check_mk_agent.linux" (builtins.readFile (self + /resources/check_mk_agent.librenms)));
        extraConfig = ''
          socket_type = stream
          bind = ::
          wait = no
          log_on_success =
        '';
      }];
    };
  };
}
