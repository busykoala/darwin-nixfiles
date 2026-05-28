require("tokyonight").setup({
  style = "storm",
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    floats = "dark",
    keywords = { italic = false },
    sidebars = "dark",
  },
})

vim.cmd.colorscheme("tokyonight-storm")

local highlights = {
  IblIndent = { fg = "#252b40", nocombine = true },
  IblScope = { fg = "#89b4fa", bold = true, nocombine = true },
  NixfilesWinbarFill = { fg = "#11131d", bg = "#11131d" },
  NixfilesWinbarIcon = { fg = "#1a1b26", bg = "#7dcfff", bold = true },
  NixfilesWinbarIconSep = { fg = "#7dcfff", bg = "#283457" },
  NixfilesWinbarPath = { fg = "#c0caf5", bg = "#283457", bold = true },
  NixfilesWinbarPathSep = { fg = "#283457", bg = "#24283b" },
  NixfilesWinbarSpacer = { bg = "#1f2335" },
  NixfilesWinbarSymbol = { fg = "#c0caf5", bg = "#24283b" },
  NixfilesWinbarSymbolSep = { fg = "#24283b", bg = "#11131d" },
  RainbowDelimiterBlue = { fg = "#7aa2f7" },
  RainbowDelimiterCyan = { fg = "#7dcfff" },
  RainbowDelimiterGreen = { fg = "#9ece6a" },
  RainbowDelimiterOrange = { fg = "#ff9e64" },
  RainbowDelimiterRed = { fg = "#f7768e" },
  RainbowDelimiterViolet = { fg = "#bb9af7" },
  RainbowDelimiterYellow = { fg = "#e0af68" },
  WinBar = { fg = "#c0caf5", bg = "#11131d" },
  WinBarNC = { fg = "#565f89", bg = "#11131d" },
}

local diagnostic_signs = {
  DiagnosticSignError = "●",
  DiagnosticSignHint = "●",
  DiagnosticSignInfo = "●",
  DiagnosticSignWarn = "●",
}

local function apply_highlights()
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end

  for group, text in pairs(diagnostic_signs) do
    vim.fn.sign_define(group, {
      text = text,
      texthl = group,
      linehl = "",
      numhl = "",
    })
  end
end

apply_highlights()

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "●",
      [vim.diagnostic.severity.WARN] = "●",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "●",
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_text = {
    prefix = "●",
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 2,
  },
})

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = apply_highlights,
})

require("nixfiles.winbar").setup()
