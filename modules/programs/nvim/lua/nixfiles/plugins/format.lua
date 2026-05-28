require("conform").setup({
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 1200,
  },
  formatters_by_ft = {
    css = { "prettierd" },
    html = { "prettierd" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    jinja = { "prettierd" },
    json = { "prettierd" },
    lua = { "stylua" },
    markdown = { "prettierd" },
    nix = { "nixpkgs_fmt" },
    python = { "ruff_format" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    toml = { "taplo" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    yaml = { "prettierd" },
    ["yaml.ansible"] = { "prettierd" },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
