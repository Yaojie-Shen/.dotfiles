-- Define a list of LSP servers to be installed and enabled.
local servers = { "pyright", "jsonls", "yamlls", "bashls", "html", "cssls", "lua_ls" }

return {
  -- Automate LSP installation
  {
    "mason-org/mason-lspconfig.nvim",
    -- event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    lazy = false,
    opts = {
      ensure_installed = servers,
      automatic_enable = true,
    },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig", -- configure LSP before enable
    },
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- Configure LSP
      -- read :h vim.lsp.config for changing options of lsp servers
      require("nvchad.configs.lspconfig").defaults()

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
    end,
  },

  -- Progress
  {
    "j-hui/fidget.nvim",
    event = "LspAttach", -- Load fidget when LSP is attached
    opts = {
      progress = {
        display = {
          done_ttl = 5,
          done_icon = "✔",
        },
      },
    },
  },
}
