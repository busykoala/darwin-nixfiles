require("gitsigns").setup({
  current_line_blame = true,
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    changedelete = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    untracked = { text = "┆" },
  },
})

vim.keymap.set("n", "<leader>gf", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff current file" })
