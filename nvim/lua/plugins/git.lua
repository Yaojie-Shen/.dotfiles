return {
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "nvim-mini/mini.pick", -- optional
      "folke/snacks.nvim", -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "show neogit ui" },
    },
    opts = {
      integrations = { diffview = true },
    },
  },

  -- Enable side-by-side diff popup
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = {
      enhanced_diff_hl = false,
      keymaps = {
        -- Configure keymap: press 'q' to quit diffview
        view = {
          { "n", "q", ":DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", ":DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", ":DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
      },
    },
    keys = {
      {
        "<leader>do",
        ":DiffviewOpen<CR>",
        mode = "n",
        desc = "diffview open",
        noremap = true,
        silent = true,
      },
      {
        "<leader>dc",
        ":DiffviewClose<CR>",
        mode = "n",
        desc = "diffview close",
        noremap = true,
        silent = true,
      },
      {
        "<leader>df",
        ":DiffviewFileHistory<CR>",
        mode = "n",
        desc = "diffview file history",
        noremap = true,
        silent = true,
      },
    },
  },
}
