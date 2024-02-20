{ ... }:
{
  services.bird2 = {
    enable = true;
    config = ''
      # log to stderr
      log stderr all;

      # timeformat for birdc scraping
      timeformat base iso long;

      # our router id
      router id 193.201.151.70;

      # enable internal watchdog
      watchdog warning 5 s;
      watchdog timeout 30 s;

      protocol device {
      }

      protocol direct any112 {
        interface "any112";
        ipv4;
        ipv6;
      }

      # bgp templates
      template bgp tpl_ddix_rs {
        local as 65077;

        disabled yes;

        graceful restart yes;

        enable extended messages yes;

        advertise hostname yes;
      }
      template bgp tpl_ddix_rs_v4 from tpl_ddix_rs {
        ipv4 {
          import all;
          export where proto = "any112";
        };
      }
      template bgp tpl_ddix_rs_v6 from tpl_ddix_rs {
        ipv6 {
          import all;
          export where proto = "any112";
        };
      }

      # DD-IX Route Servers IPv4
      protocol bgp ddix_rs01_v4 from tpl_ddix_rs_v4 {
        neighbor 193.201.151.65 as 57328;
      }
      protocol bgp ddix_rs02_v4 from tpl_ddix_rs_v4 {
        neighbor 193.201.151.66 as 57328;
      }

      # DD-IX Route Servers IPv6
      protocol bgp ddix_rs01_v6 from tpl_ddix_rs_v6 {
        neighbor 2001:7f8:79::dff0:1 as 57328;
      }
      protocol bgp ddix_rs02_v6 from tpl_ddix_rs_v6 {
        neighbor 2001:7f8:79::dff0:2 as 57328;
      }
    '';
  };
}
