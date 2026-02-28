{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;
    vimAlias = true;
    viAlias = true;

    configure = {
      customRC = /* vim */ ''
        colorscheme kanagawa
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ kanagawa-nvim ];
      };
    };

  };
}
