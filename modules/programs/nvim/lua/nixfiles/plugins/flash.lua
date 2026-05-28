local flash = require("flash")

flash.setup()

vim.keymap.set({ "n", "x", "o" }, "<leader>j", function()
  flash.jump()
end, { desc = "Flash jump" })

vim.keymap.set({ "n", "x", "o" }, "<leader>J", function()
  flash.treesitter()
end, { desc = "Flash treesitter" })
