local wk = require("which-key")

wk.setup({
  delay = 350,
  preset = "modern",
})

wk.add({
  { "<leader>c", group = "code/codex" },
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git" },
  { "<leader>i", group = "images" },
  { "<leader>j", desc = "Flash jump" },
  { "<leader>J", desc = "Flash treesitter" },
  { "<leader>n", group = "notifications" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "terminal" },
  { "<leader>u", group = "ui toggles" },
  { "<leader>ui", desc = "Toggle indent guides" },
  { "<leader>x", group = "diagnostics" },
})
