vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.editorconfig = true

local opt = vim.opt

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

opt.background = "dark"
opt.clipboard:append("unnamedplus")
opt.cursorline = true
opt.encoding = "utf-8"
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldclose = "",
  foldopen = "",
  foldsep = " ",
}
opt.iskeyword:append("-")
opt.laststatus = 3
opt.list = true
opt.listchars = {
  eol = "↵",
  nbsp = "␣",
  tab = ">-",
  trail = "·",
}
opt.number = true
opt.numberwidth = 5
opt.signcolumn = "yes:1"
opt.termguicolors = true

vim.filetype.add({
  extension = {
    j2 = "jinja",
    jinja = "jinja",
    jinja2 = "jinja",
    mjs = "javascript",
    tf = "terraform",
    tfvars = "terraform",
  },
  pattern = {
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/.*%.ya?ml"] = "yaml.ansible",
  },
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.w.matchnonascii = vim.fn.matchadd("ErrorMsg", "[\\x7f-\\xff]", -1)
  end,
})
