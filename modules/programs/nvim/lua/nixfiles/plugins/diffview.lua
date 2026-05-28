require("diffview").setup()

vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<CR>", { desc = "Diff view" })
vim.keymap.set("n", "<leader>gV", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "Repo history" })
