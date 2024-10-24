{ lib, ... }:

{
  services.openssh = {
    settings = {
      X11Forwarding = false;
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      UseDns = false;
      # unbind gnupg sockets if they exists
      StreamLocalBindUnlink = true;
      PermitRootLogin = "prohibit-password";
    };

    # Only allow system-level authorized_keys to avoid injections.
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  };

  # nixos-modules
  programs.ssh = { };

  services.openssh = {
    fixPermissions = true;
    regenerateWeakRSAHostKey = true;
  };

  programs.ssh = {
    addPopularKnownHosts = true;
    knownHosts = {
      "codeberg.org" = {
        hostNames = [ "codeberg.org" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
      };

      "gitea.c3d2.de" = {
        hostNames = [ "gitea.c3d2.de" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8Q7kGF3Hh6HvmlSIgZOjgoIZRpyxKvMBTcPWHlecuh";
      };
    };
  };
}
