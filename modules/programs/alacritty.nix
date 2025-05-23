{ pkgs }: {
  enable = true;
  settings = {
    general = {
      live_config_reload = true;
    };
    window = {
      # Don't activate on Gnome! Alacritty won't start if this is enabled.
      # startup_mode = "Maximized";
    };
    scrolling = {
      history = 100000;
    };
    font = {
      size = 13.0;
    };
    colors = {
      primary = {
        background = "0x1c1c1c";
        foreground = "0x808080";
      };
      cursor = {
        text = "0x1c1c1c";
        cursor = "0x808080";
      };
      normal = {
        black = "0x1c1c1c";
        red = "0xaf005f";
        green = "0x5faf00";
        yellow = "0xd7af5f";
        blue = "0x5fafd7";
        magenta = "0x808080";
        cyan = "0xd7875f";
        white = "0xd0d0d0";
      };
      bright = {
        black = "0x585858";
        red = "0x5faf5f";
        green = "0xafd700";
        yellow = "0xaf87d7";
        blue = "0xffaf00";
        magenta = "0xffaf00";
        cyan = "0x00afaf";
        white = "0x5f8787";
      };
    };
    terminal.shell = {
      program = "${pkgs.tmux}/bin/tmux";
      args = [ "new-session" "-A" "-D" "-s" "main" ];
    };
  };
}
