{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    theme = {
      mgr = {
        cwd = { fg = "#8be9fd"; };
        border = { fg = "#1e1e2e"; };
        preview_border = { fg = "#3a0ca3"; };
        title = { fg = "#bd93f9"; };
        highlight = { fg = "#ff79c6"; };
      };

      status = {
        separator_opened = { fg = "#50fa7b"; };
        separator_closed = { fg = "#44475a"; };
        mode_normal = { fg = "#50fa7b"; };
        mode_select = { fg = "#f1fa8c"; };
        mode_visual = { fg = "#ff79c6"; };
        mode_shell = { fg = "#8be9fd"; };
        progress_label = { fg = "#f8f8f2"; };
        progress_bar = { fg = "#bd93f9"; };
      };

      input = {
        border = { fg = "#3a0ca3"; };
        title = { fg = "#ff79c6"; };
        value = { fg = "#f8f8f2"; };
        selected = { fg = "#ffb86c"; };
      };

      select = {
        border = { fg = "#3a0ca3"; };
        active = { fg = "#50fa7b"; };
        inactive = { fg = "#6272a4"; };
      };

      filetype = {
        rules = [
          { fg = "#8be9fd"; mime = "text/*"; }
          { fg = "#ff79c6"; mime = "image/*"; }
          { fg = "#f1fa8c"; mime = "video/*"; }
          { fg = "#bd93f9"; mime = "audio/*"; }
          { fg = "#ff5555"; mime = "application/zip"; }
          { fg = "#ff6e6e"; mime = "application/gzip"; }
          { fg = "#a4ffff"; mime = "application/bzip"; }
          { fg = "#ffb86c"; mime = "application/json"; }
        ];
      };
    };
  };
}
