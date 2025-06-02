{
  home.shellAliases = {
    gd = "git diff --color";
    gdf = "git diff --color --cached";
    gp = "git pull";
    gco = "git checkout";
    gs = "git status";
    gcm = "git commit -m";

    tf = "tofu";
    k = "kubectl";
    la = "exa -hal --icons";
    fuzzy = "sk -i -c 'rg {} --color=always' --ansi";

    ".." = "cd ..";
    "..." = "cd ../..";

    # Binary replacements
    cat = "bat";
    ls = "exa";
    diff = "delta";
    find = "fd";
    du = "dust";
    df = "dua";
    grep = "rg";
    fzf = "sk --preview 'bat --color=always {}'";
    curl = "xh";
  };
}
