{
  networking.ifstate.settings.options.sysctl =
    let
      options = {
        ipv6 = {
          # this machine should not participate in SLAAC
          autoconf = 0;
          # nor accept router advertisements
          accept_ra = 0;
          # no redirects nor evil RH0
          accept_redirects = 0;
          accept_source_route = 0;
          # no forwarding
          forwarding = 0;
          # unsolicited neighbour advertisements
          ndisc_notify = 1;
        };
        ipv4 = {
          # no redirects
          accept_redirects = 0;
          send_redirects = 0;
          accept_source_route = 0;
          # handle arp requests strict
          arp_ignore = 1;
          arp_notify = 1;
          # do strict rp filtering
          rp_filter = 1;
          # no forwarding
          forwarding = 0;
        };
      };
    in
    {
      all = options;
      default = options;
      net.core = {
        # Bufferbloat: fair queuing controlled delay
        default_qdisc = "cake";
        # tune SoftIRQ packet handling (5x)
        netdev_budget_usecs = 10000;
        netdev_budget = 1500;
        dev_weight = 320;
        netdev_max_backlog = 5000;
      };
    };
}
