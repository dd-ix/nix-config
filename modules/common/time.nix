{
  time.timeZone = "Europe/Berlin";

  services = {
    timesyncd.enable = false;
    chrony.enable = false;
    ntpd-rs = {
      enable = true;
      settings = {
        observability.log-level = "warn";
        synchronization.warn-on-jump = false;
      };
    };
  };
}
