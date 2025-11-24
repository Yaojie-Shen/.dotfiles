return {
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
      },
      -- format_on_save = {
      --   -- These options will be passed to conform.format()
      --   timeout_ms = 500,
      --   lsp_fallback = true,
      -- },
    },
  },

  -- Load lspconfig in lua/configs/lspconfig.lua
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Automate LSP installation
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "pyright", "jsonls", "yamlls", "bashls", "html", "cssls", "lua_ls" },
      automatic_enable = true,
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },

  -- Automate formatter install
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = { "stylua", "autopep8", "isort", "prettier" },
    },
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vim", "lua", "vimdoc", "html", "css", "python", "bash", "c", "cpp", "csv", "json", "yaml" },
    },
  },

  -- Tree view: file explorer
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    opts = {
      filters = {
        -- Show dotfiles
        dotfiles = false,
        -- Show git-ignored files
        git_ignored = false,
      },
      renderer = {
        -- Do not group empty folders into one line
        group_empty = false,
      },
      view = {
        -- Auto-resize tree width
        adaptive_size = true,
      },
      git = {
        enable = true,
        -- Do not hide git-ignored files
        ignore = false,
      },
    },
  },

  -- Rainbow
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = "BufReadPost",
    config = function()
        require('rainbow-delimiters.setup').setup {
            -- Your configuration options here
        }
    end,
  },
}
