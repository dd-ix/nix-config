{ lib, config, pkgs, ... }:

{
  # use LTS kernel; mkDefault is 1000 - but this conflicts with rpi
  boot.kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_6_18;

  # log autoloading kernel modules when the kernel requests a module
  # https://docs.kernel.org/admin-guide/sysctl/kernel.html#modprobe
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

  # https://gitea.c3d2.de/c3d2/nix-config/src/branch/master/modules/baremetal.nix#L163-L184
  # validate initrd kernel modules required for networking
  system.preSwitchChecks = lib.mkIf config.boot.initrd.network.enable {
    "checkForNetworkKernelModules" = /* bash */ ''
      export PATH="${pkgs.coreutils}/bin:$PATH"

      interfaces=$(ls /sys/class/net/)
      for interface in $interfaces; do
        # skip special devices like lo or virtual devices
        readlink -f "/sys/class/net/$interface/device/driver" >/dev/null || continue

        driver="$(basename "$(readlink -f "/sys/class/net/$interface/device/driver")")"

        if ! [[ "${builtins.toString config.boot.initrd.availableKernelModules}" =~ $driver ]]; then
          echo
          echo "Kernel module $driver is missing in boot.initrd.availableKernelModules!"
          echo "Unlock in initrd may fail because of this. Since we don't want to risk anything, better add it."
          echo
          exit 1
        fi
      done
    '';
  };
}
