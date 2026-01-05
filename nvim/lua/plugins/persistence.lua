-- Save & restore session status.
return {
  -- {
  --   "folke/persistence.nvim",
  --   event = "BufReadPre", -- only start session saving when an actual file was opened
  --   opts = {
  --     options = { "buffers", "curdir", "tabpages", "winsize" },
  --   },
  --   keys = {
  --     {
  --       "<leader>qs",
  --       function()
  --         require("persistence").load()
  --       end,
  --       desc = "restore session",
  --     },
  --     {
  --       "<leader>qS",
  --       function()
  --         require("persistence").select()
  --       end,
  --       desc = "restore selected Session",
  --     },
  --     {
  --       "<leader>ql",
  --       function()
  --         require("persistence").load { last = true }
  --       end,
  --       desc = "restore last session",
  --     },
  --     {
  --       "<leader>qd",
  --       function()
  --         require("persistence").stop()
  --       end,
  --       desc = "disable session save",
  --     },
  --   },
  -- },

  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>qr", "<cmd>AutoSession search<CR>", desc = "Session search" },
      { "<leader>qs", "<cmd>AutoSession save<CR>", desc = "Save session" },
      { "<leader>qa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
    },

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      -- The following are already the default values, no need to provide them if these are already the settings you want.
      session_lens = {
        picker = nil, -- "telescope"|"snacks"|"fzf"|"select"|nil Pickers are detected automatically but you can also manually choose one. Falls back to vim.ui.select
        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { "i", "<C-d>" },
          alternate_session = { "i", "<C-s>" },
          copy_session = { "i", "<C-y>" },
        },

        picker_opts = {
          -- For Telescope, you can set theme options here, see:
          -- https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
          -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/themes.lua
          --
          -- border = true,
          -- layout_config = {
          --   width = 0.8, -- Can set width and height as percent of window
          --   height = 0.5,
          -- },
        },

        -- Telescope only: If load_on_setup is false, make sure you use `:AutoSession search` to open the picker as it will initialize everything first
        load_on_setup = true,
      },
    },
  },
}
