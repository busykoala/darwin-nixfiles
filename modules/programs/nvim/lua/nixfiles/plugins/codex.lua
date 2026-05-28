local notify_dir = vim.fn.stdpath("state") .. "/codex.nvim"
local notify_path = notify_dir .. "/notify.jsonl"

vim.fn.mkdir(notify_dir, "p")

require("codex").setup({
  auto_start = true,
  diff_opts = {
    keep_terminal_focus = false,
    layout = "vertical",
    open_in_new_tab = false,
  },
  env = {
    CODEX_NVIM_NOTIFY_PATH = notify_path,
  },
  fallback_to_terminal_send = true,
  focus_after_send = false,
  git_repo_cwd = true,
  keymaps = false,
  log_level = "warn",
  models = {
    { name = "Default (Codex CLI config)", value = "" },
  },
  status_indicator = {
    cli_notify_path = notify_path,
    colors = {
      busy = "DiagnosticInfo",
      disconnected = "DiagnosticError",
      wait = "DiagnosticWarn",
    },
    enabled = true,
    icons = {
      busy = "●",
      disconnected = "×",
      idle = "○",
      wait = "◐",
    },
    offset_col = 2,
    offset_row = 1,
  },
  terminal = {
    auto_close = true,
    provider = "snacks",
    snacks_win_opts = {
      border = "none",
      wo = {
        signcolumn = "no",
        winbar = " 󰚩  Codex",
        winhighlight = table.concat({
          "Normal:Normal",
          "NormalNC:Normal",
          "WinBar:NixfilesWinbarPath",
          "WinBarNC:NixfilesWinbarPath",
          "SignColumn:Normal",
        }, ","),
      },
    },
    split_side = "right",
    unfocus_key = "<C-]>",
    split_width_percentage = 0.34,
  },
  terminal_cmd = vim.g.nixfiles_codex_cmd or "codex",
})

vim.keymap.set("n", "<leader>cc", "<cmd>Codex<CR>", { desc = "Toggle Codex" })
