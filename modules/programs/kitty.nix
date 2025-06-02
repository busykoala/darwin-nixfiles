{ config, pkgs, ... }: {
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraCode Nerd Font Mono";
      size = 13;
    };

    settings = {
      scrollback_lines = 100000;
      update_check_interval = 0;
      disable_ligatures = "never";

      background_image = "${config.home.homeDirectory}/nixfiles/assets/cyberpunk.png";
      background_image_layout = "scaled";
      background_image_opacity = "0.12";

      background = "#0f111a";
      foreground = "#c3bfbf";
      cursor = "#f38ba8";

      color0 = "#0f111a";
      color1 = "#ff5555";
      color2 = "#50fa7b";
      color3 = "#f1fa8c";
      color4 = "#bd93f9";
      color5 = "#ff79c6";
      color6 = "#8be9fd";
      color7 = "#f8f8f2";

      color8 = "#6272a4";
      color9 = "#ff6e6e";
      color10 = "#69ff94";
      color11 = "#ffffa5";
      color12 = "#d6acff";
      color13 = "#ff92df";
      color14 = "#a4ffff";
      color15 = "#ffffff";
    };

    # Advanced config goes here
    extraConfig = ''
      modify_font cell_height 83%
      modify_font baseline 2
      startup_session full
      confirm_os_window_close 0
      shell ${pkgs.tmux}/bin/tmux new-session -A -D -s main
    '';
  };
}
