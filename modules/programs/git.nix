{ config, ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      ".idea"
      ".DS_Store"
      "*.swp"
      "*.swo"
      "nohup.out"
      "tags"
      "tags.lock"
      "tags.temp"
      ".direnv"
    ];
    settings = {
      user.email = "matthias@busykoala.io";
      user.name = "Matthias Osswald";
      core = {
        pager = "delta --features tokyo-night";
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      };
      delta = {
        features = "tokyo-night";
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
      "delta \"tokyo-night\"" = {
        dark = true;
        file-style = "bold #7aa2f7";
        hunk-header-style = "omit";
        line-numbers-left-style = "#565f89";
        line-numbers-minus-style = "#f7768e";
        line-numbers-plus-style = "#9ece6a";
        line-numbers-right-style = "#565f89";
        minus-emph-style = "syntax #3b1f2b";
        minus-style = "syntax #2d202f";
        plus-emph-style = "syntax #233b2b";
        plus-style = "syntax #1f2d2b";
        side-by-side = true;
        zero-style = "syntax";
      };
      format.pretty = "%C(blue)%h%Creset %s %C(green)%d%Creset [%C(red)%an%Creset, %C(cyan)%cr%Creset] %C(bold reverse)%N%Creset";
      branch.autosetuprebase = "always";
      gpg.program = "${config.home.profileDirectory}/bin/gpg";
      commit.gpgSign = true;
    };
    lfs.enable = true;
  };
}
