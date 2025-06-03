{
  programs.tmux = {
    enable = true;
    escapeTime = 10;
    terminal = "tmux-256color";
    extraConfig = ''
      # Theme: Tokyo Night
      set-option -g status-style "bg=#1a1b26 fg=#a9b1d6"
      set-option -g message-style "bg=#1a1b26 fg=#7aa2f7"
      set-option -g message-command-style "bg=#1a1b26 fg=#7aa2f7"
      set-option -g pane-border-style "fg=#3b4261"
      set-option -g pane-active-border-style "fg=#7aa2f7"
      set-option -g status-left ""
      set-option -g status-right ""
      set-option -g window-status-current-style "bg=#7aa2f7 fg=#1a1b26"
      set-option -g window-status-current-format " #I:#W "
      set-option -g window-status-style "bg=#1a1b26 fg=#a9b1d6"
      set-option -g window-status-format " #I:#W "
      set-option -g status-justify "left"
      set-option -g status-left-length 100
      set-option -g status-right-length 100
      set-option -g status "on"

      # Other settings
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      set -g mouse on
      set-option -g allow-rename off
      setw -g mode-keys vi
      set -g base-index 1
      set -g pane-base-index 0
      setw -g history-limit 4000000
    '';
  };
}
