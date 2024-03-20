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
    rev = "cb5d089071a942ba6a8063ca4cdd694adcff8914";
    hash = "sha256-s4eg433CwIdzWbFdlBdXjut5qCN96ZvIHvvA7oNbsyA=";
  };

  vendorHash = "sha256-8N5E1CW5Z7HujwXRsZLv7y4uNOJkjj155kmX9PCjajQ=";

  passthru.ui = mkYarnPackage {
    pname = "alice-lg-ui";
    inherit version;

    src = "${src}/ui";

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/ui/yarn.lock";
      hash = "sha256-PyLYIYDb7p+gMlA+z5Eu+y3eMjKhzSJ1BqfN8B8S4Lk=";
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
