{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";

    theme = {
      mgr = {
        cwd = { fg = "#7dcfff"; };
        border = { fg = "#3b4261"; };
        preview_border = { fg = "#7aa2f7"; };
        title = { fg = "#bb9af7"; };
        highlight = { fg = "#f7768e"; };
      };

      status = {
        separator_opened = { fg = "#7aa2f7"; };
        separator_closed = { fg = "#414868"; };
        mode_normal = { fg = "#9ece6a"; };
        mode_select = { fg = "#e0af68"; };
        mode_visual = { fg = "#bb9af7"; };
        mode_shell = { fg = "#7dcfff"; };
        progress_label = { fg = "#c0caf5"; };
        progress_bar = { fg = "#7aa2f7"; };
      };

      input = {
        border = { fg = "#7aa2f7"; };
        title = { fg = "#bb9af7"; };
        value = { fg = "#c0caf5"; };
        selected = { fg = "#ff9e64"; };
      };

      select = {
        border = { fg = "#7aa2f7"; };
        active = { fg = "#9ece6a"; };
        inactive = { fg = "#565f89"; };
      };

      filetype = {
        rules = [
          { fg = "#7dcfff"; mime = "text/*"; }
          { fg = "#f7768e"; mime = "image/*"; }
          { fg = "#e0af68"; mime = "video/*"; }
          { fg = "#bb9af7"; mime = "audio/*"; }
          { fg = "#f7768e"; mime = "application/zip"; }
          { fg = "#ff9e64"; mime = "application/gzip"; }
          { fg = "#7dcfff"; mime = "application/bzip"; }
          { fg = "#9ece6a"; mime = "application/json"; }
        ];
      };
    };
  };
}
