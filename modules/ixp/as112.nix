{ ... }:

{
  services.knot = {
    enable = true;
    settings = {
      server = {
        listen = [
          "0.0.0.0@53"
          "::@53"
        ];
        automatic-acl = true;
      };

      zone = {
        "example.com".file = "example.com.zone";
        "sub.example.com".file = "sub.example.com.zone";
      };
    };
  };
}
