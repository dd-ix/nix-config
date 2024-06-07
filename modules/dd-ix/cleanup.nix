{ lib, ... }:
{
  documentation = {
    # html docs and info are not required, man pages are enough
    doc.enable = false;
    info.enable = false;
  };

  environment.defaultPackages = lib.mkForce [ ];

  # durring testing only 550K-650K of the tmpfs where used
  security.wrapperDirSize = "10M";

  boot.enableContainers = false;
}
