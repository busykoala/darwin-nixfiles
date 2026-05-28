{ pkgs, ... }:
let
  statusRight = ../../assets/tmux-status-right.sh;
in
{
  programs.tmux = {
    enable = true;
    escapeTime = 10;
    terminal = "tmux-256color";

    extraConfig = ''
      ##### Theme: Tokyo Night #####
      set-option -g status-style "bg=#1a1b26,fg=#a9b1d6"
      set-option -g status-left-style "bg=#1a1b26,fg=#a9b1d6"
      set-option -g status-right-style "bg=#1a1b26,fg=#a9b1d6"
      set-option -g message-style "bg=#24283b,fg=#7aa2f7"
      set-option -g message-command-style "bg=#24283b,fg=#7aa2f7"
      set-option -g pane-border-style "fg=#3b4261"
      set-option -g pane-active-border-style "fg=#7aa2f7"
      set-option -g mode-style "bg=#7aa2f7,fg=#1a1b26"
      set-option -g window-status-separator ""
      set-option -g window-status-style "bg=#1a1b26,fg=#565f89"
      set-option -g window-status-current-style "bg=#7aa2f7,fg=#1a1b26,bold"
      set-option -g window-status-format "#[fg=#565f89,bg=#1a1b26]  #I:#W  "
      set-option -g window-status-current-format "#[fg=#1a1b26,bg=#7aa2f7,bold] #I:#W #[fg=#7aa2f7,bg=#1a1b26,nobold]"

      ##### Status Bar Layout #####
      set-option -g status "on"
      set-option -g status-position "bottom"
      set-option -g status-justify "left"
      set-option -g status-left-length 160
      set-option -g status-right-length 220
      set -g status-interval 5

      # Left: session, window:pane and active tmux states.
      set-option -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold]  #S #[fg=#7aa2f7,bg=#24283b,nobold]#[fg=#c0caf5,bg=#24283b,bold] #I:#P #[fg=#24283b,bg=#1a1b26,nobold]#{?window_zoomed_flag,#[fg=#1a1b26]#[bg=#bb9af7]#[bold] ZOOM #[fg=#bb9af7]#[bg=#1a1b26]#[nobold],}#{?pane_synchronized,#[fg=#1a1b26]#[bg=#e0af68]#[bold] SYNC #[fg=#e0af68]#[bg=#1a1b26]#[nobold],}#{?client_prefix,#[fg=#1a1b26]#[bg=#f7768e]#[bold] PREFIX #[fg=#f7768e]#[bg=#1a1b26]#[nobold],} "

      # Right: local/remote identity, VPN, Kubernetes, battery and time.
      set-option -g status-right "#(${pkgs.bash}/bin/bash ${statusRight} #{pane_pid})"

      ##### Key Bindings #####
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      ##### Behavior #####
      set -g mouse on
      set-option -g allow-rename off
      setw -g mode-keys vi
      set -g base-index 1
      set -g pane-base-index 1
      setw -g history-limit 4000000
      set-option -g renumber-windows on
      set-window-option -g pane-base-index 1
    '';
  };
}
