require("lualine").setup({
  options = {
    component_separators = { left = " ", right = " " },
    globalstatus = true,
    section_separators = { left = "", right = "" },
    theme = "tokyonight",
  },
  sections = {
    lualine_a = { { "mode", icon = "" } },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = " ●",
          newfile = " 󰎔",
          readonly = " ",
          unnamed = "[scratch]",
        },
      },
    },
    lualine_x = { "diagnostics", "encoding", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  extensions = { "oil", "quickfix", "trouble" },
})
