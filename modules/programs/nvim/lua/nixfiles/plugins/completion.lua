require("blink.cmp").setup({
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
    },
  },
  keymap = {
    preset = "default",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})
