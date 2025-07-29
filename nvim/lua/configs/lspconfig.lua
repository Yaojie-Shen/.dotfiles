require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "pyright" }

-- Note: change config before enable LSP server
vim.lsp.config("pyright", {
  on_attach = custom_on_attach,
  settings = {
    python = {
      analysis = {
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
