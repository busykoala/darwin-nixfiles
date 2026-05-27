{
  programs.zsh = {
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
      theme = "agnoster";
    };
  };
}
