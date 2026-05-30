{ lib, ... }:

{
  hardware.enableAllFirmware = true;

  # raise some awareness towards failed services
  environment.interactiveShellInit = /* sh */ ''
    systemctl --no-pager --failed --quiet || true
  '';

  boot.kernel.sysctl."vm.swappiness" = 10;

  # https://github.com/nix-community/srvos/blob/main/nixos/server/default.nix
  # For more detail, see:
  #   https://0pointer.de/blog/projects/watchdog.html
  systemd.settings.Manager = {
    # systemd will send a signal to the hardware watchdog at half
    # the interval defined here, so every 7.5s.
    # If the hardware watchdog does not get a signal for 15s,
    # it will forcefully reboot the system.
    RuntimeWatchdogSec = lib.mkDefault "15s";
    # Forcefully reboot if the final stage of the reboot
    # hangs without progress for more than 30s.
    # For more info, see:
    #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
    RebootWatchdogSec = lib.mkDefault "30s";
    # Forcefully reboot when a host hangs after kexec.
    # This may be the case when the firmware does not support kexec.
    KExecWatchdogSec = lib.mkDefault "1m";
  };
}
