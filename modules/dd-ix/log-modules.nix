{ lib, pkgs, ... }:

{
  boot.kernel.sysctl =
    let
      modprobe-wrapper = pkgs.writeShellApplication {
        name = "modprobe-wrapper";
        text = ''
          # redirect logging
          exec 1> /dev/kmsg 2> /dev/kmsg

          # strip the '-q' parameter
          if [ "$1" = "-q" ]; then
              shift
          fi

          # call modprobe
          exec ${lib.getExe' pkgs.kmod "modprobe"} -v "$@"
        '';
      };
    in
    {
      "kernel.modprobe" = lib.getExe modprobe-wrapper;
    };
}
