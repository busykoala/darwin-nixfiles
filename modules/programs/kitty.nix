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
      window_padding_width = 8;
      background_opacity = "1.0";
      dynamic_background_opacity = false;
      macos_option_as_alt = "both";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_background = "#7aa2f7";
      active_tab_foreground = "#1a1b26";
      inactive_tab_background = "#24283b";
      inactive_tab_foreground = "#a9b1d6";

      background_image = "${config.home.homeDirectory}/nixfiles/assets/tokyo-night-cyberpunk.png";
      background_image_layout = "scaled";
      background_image_opacity = "0.14";

      background = "#1a1b26";
      foreground = "#c0caf5";
      cursor = "#c0caf5";
      selection_background = "#33467c";
      selection_foreground = "#c0caf5";

      color0 = "#15161e";
      color1 = "#f7768e";
      color2 = "#9ece6a";
      color3 = "#e0af68";
      color4 = "#7aa2f7";
      color5 = "#bb9af7";
      color6 = "#7dcfff";
      color7 = "#a9b1d6";

      color8 = "#414868";
      color9 = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
      color15 = "#c0caf5";
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
