{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$directory$git_branch$git_status$kubernetes$nix_shell$nodejs$golang$python$terraform$cmd_duration$character";
        palette = "tokyo-night";

        palettes."tokyo-night" = {
          blue = "#7aa2f7";
          cyan = "#7dcfff";
          fg = "#c0caf5";
          green = "#9ece6a";
          orange = "#ff9e64";
          purple = "#bb9af7";
          red = "#f7768e";
          yellow = "#e0af68";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold purple)";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          min_time = 1000;
          style = "yellow";
        };

        directory = {
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only = " ";
          style = "bold blue";
          truncation_length = 4;
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
          style = "purple";
          symbol = " ";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "red";
        };

        golang = {
          format = "[$symbol($version)]($style) ";
          style = "cyan";
        };

        kubernetes = {
          disabled = false;
          format = "[$symbol$context $namespace]($style) ";
          style = "cyan";
          symbol = "⎈ ";
        };

        nix_shell = {
          format = "[$symbol$state]($style) ";
          style = "blue";
          symbol = " ";
        };

        nodejs = {
          format = "[$symbol($version)]($style) ";
          style = "green";
        };

        python = {
          format = "[$symbol$pyenv_prefix$version $virtualenv]($style) ";
          style = "yellow";
        };

        terraform = {
          format = "[$symbol$workspace]($style) ";
          style = "purple";
        };
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        export PATH="/Applications/Little Snitch.app/Contents/Components:$PATH"
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "colored-man-pages"
          "git"
          "vi-mode"
          "sudo"
          "z"
        ];
      };
    };
  };
}
