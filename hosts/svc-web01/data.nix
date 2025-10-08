{
  dd-ix.hosts.svc-web01 = {
    networking = {
      net = "services";
      interfaceId = "13";
    };
    rpx.domains = [
      "dd-ix.net"
      "www.dd-ix.net"
      "content.dd-ix.net"
      "talks.dd-ix.net"
      "opening.dd-ix.net"
    ];
  };
}
