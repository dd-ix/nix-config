{ lib, ... }:
{
  # html docs, info and man pages are not required
  documentation.enable = false;

  environment.defaultPackages = lib.mkForce [ ];

  # during testing only 550K-650K of the tmpfs where used
  security.wrapperDirSize = "10M";

  boot.enableContainers = false;
}
