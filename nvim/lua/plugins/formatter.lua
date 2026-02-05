return {
  -- Mason: automate formatter installation
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = { "stylua", "ruff", "isort", "prettier", "pyproject-fmt", "shfmt" },
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
        python = { "ruff_fix", "ruff_format", "isort" },
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
