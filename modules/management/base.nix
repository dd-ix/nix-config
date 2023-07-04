{ pkgs, config, lib, ... }: {
  nix = {
    package = pkgs.nixUnstable;
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://nix-serve.hq.c3d2.de"
      ];
      trusted-public-keys = [
        "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      allow-import-from-derivation = true
    '';
  };

  environment.systemPackages = with pkgs; [
    git # versioning tool
    vim # vim editor
    htop # resource monitor
  ];


  programs.vim.defaultEditor = true;
  programs.mosh.enable = true;
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMbUizElFyULDlpEE9XHWWOca4ZXepS18ljh4Fj4YnJOAs7sbYzzhfMUiD703FIgK5YObzOlheu/PBbwUOStgcmPDuRalZWLr+0kCUYERfjLHkgliFx96xEFw9dluvII6JpbzFI/uvkEkQ3ESKapRcYAuBTk2sRoit8za+HX9sLmMueqNtN4H92sFYYm1wWy3FFgz/NN+uTh7F5nmA7SrSS/fpbmugcgBdR/Zy1YwSA8Rl1pagEvgN9/qAnP7pssvXr9pTCUNxVSQ7FlTUOHmxzG16RybYRikgevQaHtFYvmS7AuRvRDlQWhHt1drREGOIwwZPXD1smfQAsvP66J85j9aeanZdoBoJcvvFNer3071QGmi+5NHDSiG+YvoWt7qgiKLF4lOfByzjdoRRSg01uuhdQLOHHt0hbfyGS6hx//1MtjiXTElXvOOiUJ6AqfCSwOTK+72W6VKhKYcO11+Ngym1dyF3TtVcoEYN3JpUdbNq+qctMzXFMGovPEEMh7s= mel@umbreon"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6NLB8EHnUgl2GO2uaojdf3p3YpsHH6px6CZleif8klhLN+ro5KeFK2OXC2SO3Vo4qgF/NySdsoInV9JEsssELZ2ttVbeKxI6f76V5dZgGI7qoSf4E0TXIgpS9n9K2AEmRKr65uC2jgkSJuo/T1mF+4/Nzyo706FT/GGVoiBktgq9umbYX0vIQkTMFAcw921NwFCWFQcMYRruaH01tLu6HIAdJ9FVG8MAt84hCr4D4PobD6b029bHXTzcixsguRtl+q4fQAl3WK3HAxT+txN91CDoP2eENo3gbmdTBprD2RcB/hz5iI6IaY3p1+8fTX2ehvI3loRA8Qjr/xzkzMUlpA/8NLKbJD4YxNGgFbauEmEnlC8Evq2vMrxdDr2SjnBAUwzZ63Nq+pUoBNYG/c+h+eO/s7bjnJVe0m2/2ZqPj1jWQp4hGoNzzU1cQmy6TdEWJcg2c8ints5068HN3o0gQKkp1EseNrdB8SuG+me/c/uIOX8dPASgo3Yjv9IGLhhx8GOGQxHEQN9QFC4QyZt/rrAyGmlX342PBNYmmStgVWHiYCcMVUWGlsG0XvG6bvGgmMeHNVsDf6WdMQuLj9luvxJzrd4FlKX6O0X/sIaqMVSkhIbD2+vvKNqrii7JdUTntUPs89L5h9DoDqQWkL13Plg1iQt4/VYeKTbUhYYz1lw== revo-xut@plank"
  ];

}
