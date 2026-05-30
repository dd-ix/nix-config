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
      set -g @ukiyo-theme "kanagawa/wave"
      set -g @ukiyo-plugins " "
      # preserve terminal emulator background color
      set -g @ukiyo-ignore-window-colors true
    '';
    plugins = with pkgs.tmuxPlugins; [
      ukiyo
    ];
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
      set-window-option -g mode-keys vi
    '';
  };
}
