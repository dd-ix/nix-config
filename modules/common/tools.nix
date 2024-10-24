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
    p7zip
    file
    zip
    unzip
    gnutar
    jq
    nix-tree
    whois
    screen
  ];

  programs = {
    git.enable = true;
    htop.enable = true;
    strace.withColors = true;
  };
}
