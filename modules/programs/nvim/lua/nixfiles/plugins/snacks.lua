local ok_trouble, trouble_snacks = pcall(require, "trouble.sources.snacks")

local picker = {}
if ok_trouble then
  picker.actions = trouble_snacks.actions
end

local indent_excluded_filetypes = {
  help = true,
  oil = true,
  snacks_picker = true,
  snacks_terminal = true,
  terminal = true,
  trouble = true,
}

require("snacks").setup({
  bigfile = {},
  image = {},
  indent = {
    enabled = true,
    animate = {
      enabled = false,
    },
    chunk = {
      enabled = false,
    },
    filter = function(buf)
      return vim.g.snacks_indent ~= false
        and vim.b[buf].snacks_indent ~= false
        and vim.bo[buf].buftype == ""
        and not indent_excluded_filetypes[vim.bo[buf].filetype]
    end,
    indent = {
      enabled = true,
      char = "│",
    },
    scope = {
      enabled = true,
      char = "│",
      underline = false,
    },
  },
  input = {},
  notifier = {
    timeout = 3000,
  },
  picker = picker,
  quickfile = {},
  scope = {},
  words = {},
})

local map = vim.keymap.set

map("n", "<leader>ff", function()
  Snacks.picker.smart()
end, { desc = "Smart find files" })
map("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "Grep" })
map("n", "<leader>b", function()
  Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "Recent files" })

map("n", "<leader>sh", function()
  Snacks.picker.help()
end, { desc = "Help pages" })
map("n", "<leader>sk", function()
  Snacks.picker.keymaps()
end, { desc = "Keymaps" })
map("n", "<leader>sm", function()
  Snacks.picker.marks()
end, { desc = "Marks" })
map("n", "<leader>st", function()
  Snacks.picker.todo_comments()
end, { desc = "Todo comments" })

map("n", "<leader>tt", function()
  Snacks.terminal(nil, { position = "right", width = 0.34 })
end, { desc = "Toggle terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>ih", function()
  Snacks.image.hover()
end, { desc = "Image hover" })

map("n", "]r", function()
  Snacks.words.jump(vim.v.count1)
end, { desc = "Next reference" })
map("n", "[r", function()
  Snacks.words.jump(-vim.v.count1)
end, { desc = "Previous reference" })

map("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss notifications" })
map("n", "<leader>nh", function()
  Snacks.notifier.show_history()
end, { desc = "Notification history" })

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.indent():map("<leader>ui")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal" }):map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.inlay_hints():map("<leader>uh")
