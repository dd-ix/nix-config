{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd # find alternative
    knot-dns # kdig
    ripgrep # better recursive grep
    mtr # ping tool
    ipcalc # ipcalc
    tcpdump # packet sniffer
    iperf3 # speedtest
    bmon # network monitor
    pciutils # pci debugger
    ethtool
    _7zz
    file
    zip
    unzip
    gnutar
    jq
    whois
    killall
    wireguard-tools
    rsync
    sops
    strace #strace-with-colors
  ];

  programs = {
    git.enable = true;
    htop.enable = true;
  };
}
