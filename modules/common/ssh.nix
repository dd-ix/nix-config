{ lib, config, ... }:

{
  # add authorizedKeys from root user to initrd
  boot.initrd.network.ssh.authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;

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

  programs.ssh.knownHosts = {
    "github.com" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    "gitlab.com" = {
      hostNames = [ "gitlab.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    };

    "codeberg.org" = {
      hostNames = [ "codeberg.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
    };

    "gitea.c3d2.de" = {
      hostNames = [ "gitea.c3d2.de" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8Q7kGF3Hh6HvmlSIgZOjgoIZRpyxKvMBTcPWHlecuh";
    };
  };
}
