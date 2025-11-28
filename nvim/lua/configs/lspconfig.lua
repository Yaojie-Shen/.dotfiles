require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "pyright" }

-- Note: change config before enable LSP server
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "recomrecommended",
        exclude = {
          "**/node_modules",
          "**/.venv",
          "**/venv",
          "**/__pycache__",
          "**/build",
          "**/dist",
          "**/doc",
          "**/docs",
          "**/assets",
          "**/static",
          "**/public",
        },
      },
    },
  },
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
