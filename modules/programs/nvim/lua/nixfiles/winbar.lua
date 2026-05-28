local M = {}

local excluded_filetypes = {
  help = true,
  oil = true,
  terminal = true,
  trouble = true,
}

local symbol_node_types = {
  class_declaration = true,
  class_definition = true,
  constructor_declaration = true,
  function_declaration = true,
  function_definition = true,
  impl_item = true,
  method_declaration = true,
  method_definition = true,
  struct_item = true,
  trait_item = true,
}

local last_by_buffer = {}
local padding_namespace = vim.api.nvim_create_namespace("nixfiles-winbar-padding")

local function status_escape(value)
  return tostring(value):gsub("%%", "%%%%")
end

local function node_name(node, bufnr)
  local name_nodes = node:field("name")
  if name_nodes and name_nodes[1] then
    return vim.treesitter.get_node_text(name_nodes[1], bufnr)
  end
end

local function current_symbols(bufnr)
  if not vim.treesitter.get_node then
    return {}
  end

  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  if not ok or not node then
    return {}
  end

  local symbols = {}
  while node do
    if symbol_node_types[node:type()] then
      local name = node_name(node, bufnr)
      if name and name ~= "" then
        symbols[#symbols + 1] = name
      end
    end
    node = node:parent()
  end

  local ordered = {}
  for index = #symbols, 1, -1 do
    ordered[#ordered + 1] = symbols[index]
  end
  return ordered
end

local function should_skip(bufnr)
  return vim.bo[bufnr].buftype ~= "" or excluded_filetypes[vim.bo[bufnr].filetype]
end

local function render()
  local bufnr = vim.api.nvim_get_current_buf()
  if should_skip(bufnr) then
    return ""
  end

  local file = vim.api.nvim_buf_get_name(bufnr)
  local path = file ~= "" and vim.fn.fnamemodify(file, ":.") or "[scratch]"
  local symbols = current_symbols(bufnr)
  local parts = {
    "%#NixfilesWinbarIcon# 󰉋 ",
    "%#NixfilesWinbarIconSep#",
    "%#NixfilesWinbarPath# " .. status_escape(path) .. " ",
  }

  if #symbols > 0 then
    parts[#parts + 1] = "%#NixfilesWinbarPathSep#"
    for index, symbol in ipairs(symbols) do
      parts[#parts + 1] = index > 1 and "%#NixfilesWinbarSymbol# › " or "%#NixfilesWinbarSymbol# "
      parts[#parts + 1] = status_escape(symbol)
    end
    parts[#parts + 1] = " "
    parts[#parts + 1] = "%#NixfilesWinbarSymbolSep#"
  else
    parts[#parts + 1] = "%#NixfilesWinbarPathSep#"
  end

  parts[#parts + 1] = "%#NixfilesWinbarFill#%="
  local value = table.concat(parts)
  last_by_buffer[bufnr] = value
  return value
end

local function update_padding()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, padding_namespace, 0, -1)
  if should_skip(bufnr) then
    return
  end

  local topline = math.max(vim.fn.line("w0") - 1, 0)
  vim.api.nvim_buf_set_extmark(bufnr, padding_namespace, topline, 0, {
    virt_lines = { { { " ", "NixfilesWinbarSpacer" } } },
    virt_lines_above = true,
  })
end

function _G.NixfilesWinbar()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, value = pcall(render)
  if ok and type(value) == "string" then
    return value
  end
  return last_by_buffer[bufnr] or "%#NixfilesWinbarFill#%="
end

function M.setup()
  vim.o.winbar = "%!v:lua.NixfilesWinbar()"
  vim.api.nvim_create_autocmd({ "BufWinEnter", "CursorMoved", "CursorMovedI", "WinEnter", "WinScrolled" }, {
    callback = update_padding,
  })
end

return M
