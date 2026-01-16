return {
  -- Automate formatter installation
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = { "stylua", "autopep8", "isort", "prettier", "pyproject-fmt", "shfmt" },
    },
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        python = { "isort", "autopep8" },
        toml = { "pyproject-fmt" },
        shell = { "shfmt" },
      },
      -- format_on_save = {
      --   -- These options will be passed to conform.format()
      --   timeout_ms = 500,
      --   lsp_fallback = true,
      -- },
    },
  },
}
