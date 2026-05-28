local has_blink, blink = pcall(require, "blink.cmp")
local capabilities = vim.lsp.protocol.make_client_capabilities()

if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local schemastore = require("schemastore")
local servers = {
  ansiblels = {},
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  dockerls = {},
  gopls = {},
  jinja_lsp = {},
  ltex = {
    cmd = { vim.g.nixfiles_ltex_cmd or "ltex-ls" },
    filetypes = {
      "gitcommit",
      "html",
      "markdown",
      "rst",
      "text",
    },
    settings = {
      ltex = {
        checkFrequency = "edit",
        completionEnabled = true,
        diagnosticSeverity = "warning",
        language = "en-US",
        languageToolHttpServerUri = "http://localhost:8081/",
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim", "Snacks" } },
        workspace = { checkThirdParty = false },
      },
    },
  },
  marksman = {},
  nil_ls = {},
  ruff = {},
  rust_analyzer = {},
  taplo = {},
  terraformls = {},
  ts_ls = {},
  yamlls = {
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = "",
        },
        schemas = schemastore.yaml.schemas(),
        validate = true,
      },
    },
  },
}

for server, config in pairs(servers) do
  config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
