return {
  -- Formatter
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- Load lspconfig in lua/configs/lspconfig.lua
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc", "html", "css",
        "python", "bash", "c", "cpp",
        "csv", "json", "yaml",
  		},
  	},
  },

  -- Tree view: file explorer
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        dotfiles = false,      -- Show dotfiles
        git_ignored = false,   -- Show git-ignored files
      },
      renderer = {
        group_empty = false,   -- Do not group empty folders into one line
      },
      view = {
        adaptive_size = true,  -- Auto-resize tree width
      },
      git = {
        enable = true,
        ignore = false,        -- Do not hide git-ignored files
      },
    },
  }

}
