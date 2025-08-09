{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "de_DE.UTF-8";
    };
  };

  services.xserver.xkb.layout = "de";

  console.keyMap = "de";
}
