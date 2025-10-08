{
  hardware.enableRedistributableFirmware = true;

  # raise some awareness towards failed services
  environment.interactiveShellInit = /* sh */ ''
    systemctl --no-pager --failed --quiet || true
  '';

  boot.kernel.sysctl."vm.swappiness" = 10;
}
