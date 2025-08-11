{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    historyLimit = 200000;
    baseIndex = 1;
    terminal = "tmux-256color";
    # fix vim like editors fix
    escapeTime = 100;
    extraConfigBeforePlugins = ''
      set -g @kanagawa-plugins " "
    '';
    plugins = with pkgs.tmuxPlugins ;[
      kanagawa
    ];
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
