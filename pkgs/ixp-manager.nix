{stdenv, pkgs, lib, fetchurl}:
stdenv.mkDerivation rec {
    pname = "ipx-manager";
    version = "6.2.0";

    src = fetchurl {
      url = "https://github.com/inex/IXP-Manager/archive/refs/tags/v${version}.tar.gz";
      sha256 = "sha256-Y15J/Nagr50pOJJcVK1IqJMbLnapomDTTULHNN196gg=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -R . $out/
      runHook postInstall
    '';

    meta = with lib; {
      description = "frontend for managing your internet exchange";
      homepage = "https://github.com/inex/IXP-Manager/archive/refs/tags/v6.2.0.tar.gz";
      maintainers = with maintainers; [ revol-xut ];
      license = licenses.gpl2;
      platforms = with platforms; unix;
    };
}
