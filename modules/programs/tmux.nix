{
  programs.tmux = {
    enable = true;
    escapeTime = 10;
    terminal = "tmux-256color";
    extraConfig = ''
      # remap prefix from 'C-b' to 'C-a'
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

      # split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

      # Enable mouse mode (tmux 2.1 and above)
        set -g mouse on

      # don't rename windows automatically
        set-option -g allow-rename off

      # set vi mode
        setw -g mode-keys vi

      # reload config with `r`
      # bind r source-file ~/.tmux.conf

      # Start window and pane indices at 1.
        set -g base-index 1
        set -g pane-base-index 0

      # Set the history limit so we get lots of scrollback.
        setw -g history-limit 4000000
    '';
  };
}
