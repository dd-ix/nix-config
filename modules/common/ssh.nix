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
  programs.ssh = {
    addPopularKnownHosts = true;
  };

  services.openssh = {
    fixPermissions = true;
    regenerateWeakRSAHostKey = true;
  };
}
