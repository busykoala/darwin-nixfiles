{ pkgs, pkgsUnstable, ... }:
let
  nixfilesNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nixfiles-nvim";
    version = "2026-05-28";
    src = ./nvim;
    doCheck = false;
  };

  codexNvimSrc = pkgs.fetchFromGitHub {
    owner = "ishiooon";
    repo = "codex.nvim";
    rev = "939598b8eee9efa050d0c0767c2991388b0324bd";
    sha256 = "1rqjy6l9s7wdkhcnx34297szhwdym8sjyzpy5n2l6fk9csv4jgvw";
  };

  codexNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "codex.nvim";
    version = "2026-05-13";

    src = pkgs.lib.cleanSourceWith {
      src = codexNvimSrc;
      filter = path: _:
        let
          rel = pkgs.lib.removePrefix "${codexNvimSrc}/" (toString path);
        in
          !(pkgs.lib.hasPrefix "fixtures/" rel || pkgs.lib.hasPrefix "tests/" rel);
    };
  };

  luaRequire = module: ''
    lua << EOF
    require('${module}')
    EOF
  '';
in
{
  home.packages = with pkgs; [
    terraform
    terraform-ls
    tflint
    tfsec

    ansible-language-server
    ansible-lint
    basedpyright
    dockerfile-language-server-nodejs
    gopls
    jinja-lsp
    ltex-ls
    lua-language-server
    marksman
    nil
    ruff
    rust-analyzer
    taplo
    typescript-language-server
    yaml-language-server

    hadolint
    markdownlint-cli2
    nixpkgs-fmt
    prettierd
    shellcheck
    shfmt
    stylua
    yamllint
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = [
      {
        plugin = nixfilesNvim;
        config = luaRequire "nixfiles.options";
      }

      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.plenary-nvim

      {
        plugin = pkgs.vimPlugins.snacks-nvim;
        config = luaRequire "nixfiles.plugins.snacks";
      }

      {
        plugin = pkgs.vimPlugins.tokyonight-nvim;
        config = luaRequire "nixfiles.plugins.theme";
      }

      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        config = luaRequire "nixfiles.plugins.lualine";
      }

      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter: with treesitter; [
          bash
          css
          dockerfile
          gitignore
          go
          gomod
          html
          ini
          javascript
          jinja
          json
          lua
          markdown
          markdown_inline
          nix
          python
          rust
          terraform
          toml
          tsx
          typescript
          vim
          yaml
        ]);
        config = luaRequire "nixfiles.plugins.treesitter";
      }

      {
        plugin = pkgs.vimPlugins.rainbow-delimiters-nvim;
        config = luaRequire "nixfiles.plugins.rainbow";
      }

      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        config = luaRequire "nixfiles.plugins.gitsigns";
      }

      {
        plugin = pkgs.vimPlugins.diffview-nvim;
        config = luaRequire "nixfiles.plugins.diffview";
      }

      {
        plugin = pkgs.vimPlugins.neogit;
        config = luaRequire "nixfiles.plugins.neogit";
      }

      {
        plugin = pkgs.vimPlugins.flash-nvim;
        config = luaRequire "nixfiles.plugins.flash";
      }

      {
        plugin = pkgs.vimPlugins.oil-nvim;
        config = luaRequire "nixfiles.plugins.oil";
      }

      {
        plugin = pkgs.vimPlugins.comment-nvim;
        config = luaRequire "nixfiles.plugins.comment";
      }

      {
        plugin = pkgs.vimPlugins.which-key-nvim;
        config = luaRequire "nixfiles.plugins.which-key";
      }

      {
        plugin = pkgs.vimPlugins.trouble-nvim;
        config = luaRequire "nixfiles.plugins.trouble";
      }

      {
        plugin = pkgs.vimPlugins.todo-comments-nvim;
        config = luaRequire "nixfiles.plugins.todo-comments";
      }

      {
        plugin = pkgs.vimPlugins.render-markdown-nvim;
        config = luaRequire "nixfiles.plugins.render-markdown";
      }

      {
        plugin = pkgs.vimPlugins.blink-cmp;
        config = luaRequire "nixfiles.plugins.completion";
      }

      pkgs.vimPlugins.SchemaStore-nvim

      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        config = ''
          lua << EOF
          vim.g.nixfiles_ltex_cmd = '${pkgs.ltex-ls}/bin/ltex-ls'
          require('nixfiles.plugins.lsp')
          EOF
        '';
      }

      {
        plugin = pkgs.vimPlugins.conform-nvim;
        config = luaRequire "nixfiles.plugins.format";
      }

      {
        plugin = pkgs.vimPlugins.nvim-lint;
        config = luaRequire "nixfiles.plugins.lint";
      }

      {
        plugin = codexNvim;
        config = ''
          lua << EOF
          vim.g.nixfiles_codex_cmd = '${pkgsUnstable.codex}/bin/codex'
          require('nixfiles.plugins.codex')
          EOF
        '';
      }
    ];
  };
}
