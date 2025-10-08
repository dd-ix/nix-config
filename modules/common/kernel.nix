{ lib, config, pkgs, ... }:

{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12;

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
