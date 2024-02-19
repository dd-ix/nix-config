{ fetchFromGitHub
, buildGoModule
, mkYarnPackage
, fetchYarnDeps
}:

buildGoModule rec {
  pname = "alice-lg";
  version = "6.0.0-custom";

  src = fetchFromGitHub {
    owner = "MarcelCoding";
    repo = "alice-lg";
    rev = "c2ebfc29dff908736684634121258761ddf67e34";
    hash = "sha256-5OiohC4zXlvbak/3wcDIozLnJyg6sFqGeDNuQhpVqaQ=";
  };

  vendorHash = "sha256-8N5E1CW5Z7HujwXRsZLv7y4uNOJkjj155kmX9PCjajQ=";

  passthru.ui = mkYarnPackage {
    pname = "alice-lg-ui";
    inherit version;

    src = "${src}/ui";

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/ui/yarn.lock";
      hash = "sha256-i9uIpLI76tCu1UF+G4U7j+Z3ra6ek/g7ocK33teFmXU=";
    };

    configurePhase = ''
      ln -s $node_modules node_modules
    '';

    buildPhase = ''
      yarn --offline build
    '';

    checkPhase = ''
      yarn --offline test --cache=false
    '';

    installPhase = ''
      mkdir $out
      cp -R build/* $out
    '';

    doDist = false;
    doCheck = true;
  };

  preBuild = ''
    cp -R ${passthru.ui}/ ui/build/
  '';

  subPackages = [ "cmd/alice-lg" ];
  doCheck = false;
}
