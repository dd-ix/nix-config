{ self, ... }:

{
  services.post = {
    enable = true;
    smtp = {
      addr = "::1";
      port = 25;
    };
    templateGlob = self + "/resources/email_templates/*.html";
  };
}
