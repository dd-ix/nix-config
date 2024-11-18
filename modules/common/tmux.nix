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
      set -g @tmux_power_theme '#a7c080'
    '';
    plugins = with pkgs.tmuxPlugins; [ power-theme ];
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
