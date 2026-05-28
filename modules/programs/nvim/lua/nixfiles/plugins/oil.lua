require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  float = {
    border = "none",
    max_height = 0.85,
    max_width = 0.9,
    padding = 2,
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "<C-n>", "<cmd>Oil<CR>", { desc = "Open Oil" })
