return {
  -- Rainbow
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup {
        -- Your configuration options here
      }
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  -- Tree view: file explorer
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    opts = {
      filters = {
        -- Show dotfiles
        dotfiles = false,
        -- Show git-ignored files
        git_ignored = false,
        custom = { "__pycache__", ".git", ".vscode", "*.egg-info" },
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

  -- Colorful scroll bar on the right like in vscode (with git status)
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("satellite").setup {
        current_only = false,
        width = 2,
        handlers = {
          cursor = {
            enable = true,
          },
          search = {
            enable = true,
          },
          diagnostic = {
            enable = true,
          },
          gitsigns = {
            enable = true,
            signs = {
              add = "█",
              change = "█",
              delete = "▄",
            },
          },
        },
      }
    end,
  },

  -- Highlight todo comments like `TODO`, `NOTE`, `WARNING` in code
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    config = function()
      require("todo-comments").setup {
        -- Highlight `TODO(author):` comments
        -- See this issue for more details: https://github.com/folke/todo-comments.nvim/issues/10
        search = { pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]] },
        highlight = { pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]] },
      }
    end,
    keys = {
      {
        "<leader>td",
        ":TodoTelescope<CR>",
        mode = "n",
        desc = "telescope project todo-comments",
        noremap = true,
        silent = true,
      },
    },
  },

  -- Notice management
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        progress = { enable = false }, -- LSP progress is handeled by fidget, disable here
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
      },
      routes = {
        -- ...
      },
    },
  },

  -- Displays the filename in the corner of each split window to prevent panel confusion
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    config = function()
      require("incline").setup {
        window = {
          margin = { horizontal = 1, vertical = 0 }, -- Flush against the window edges
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf }) and " ●" or ""

          return {
            { ft_icon, guifg = ft_color },
            { " " },
            { filename, gui = props.focused and "bold" or "none" },
            { modified, guifg = "#e06c75" },
          }
        end,
      }
    end,
  },
}
