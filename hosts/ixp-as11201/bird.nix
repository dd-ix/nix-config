{ ... }:
{
  services.bird2 = {
    enable = true;
    config = ''
      router id 10.77.1.1;

      protocol device {
      }

      protocol direct {
        ipv4;
      }

      protocol static {
        ipv4 {
          import all;
          export none;
        };
      }

      protocol bgp hel1vyos {
        local 10.99.3.4 as 65077;
        neighbor 10.99.3.1 as 65099;
        hold time 180;

        ipv4 {
          import all;
          export all;
        };
      }
    '';
  };
}
