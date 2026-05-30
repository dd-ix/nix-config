{ lib, ... }:
{
  # html docs, info and man pages are not required
  documentation = {
    nixos.enable = false;
    man.mandoc.enable = false;
    man.man-db.enable = false;
    man.enable = false;
    info.enable = false;
    enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  environment.defaultPackages = lib.mkForce [ ];

  # during testing only 550K-650K of the tmpfs where used
  security.wrapperDirSize = "10M";

  boot.enableContainers = false;
}
