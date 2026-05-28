local lint = require("lint")

lint.linters_by_ft = {
  dockerfile = { "hadolint" },
  markdown = { "markdownlint-cli2" },
  python = { "ruff" },
  sh = { "shellcheck" },
  terraform = { "tflint", "tfsec" },
  yaml = { "yamllint" },
  ["yaml.ansible"] = { "ansible_lint", "yamllint" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set("n", "<leader>cl", function()
  lint.try_lint()
end, { desc = "Lint current buffer" })
