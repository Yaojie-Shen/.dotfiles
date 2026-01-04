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
        "<leader>go",
        ":DiffviewOpen<CR>",
        mode = "n",
        desc = "diffview open git diff",
        noremap = true,
        silent = true,
      },
      {
        "<leader>gc",
        ":DiffviewClose<CR>",
        mode = "n",
        desc = "diffview close git diff",
        noremap = true,
        silent = true,
      },
      {
        "<leader>gf",
        ":DiffviewFileHistory<CR>",
        mode = "n",
        desc = "diffview show git history",
        noremap = true,
        silent = true,
      },
    },
  },

  {
    "isakbm/gitgraph.nvim",
    opts = {
      git_cmd = "git",
      symbols = {
        commit = "●",
        commit_end = "○",
        merge_commit = "◉",
        merge_commit_end = "◎",
      },
      format = {
        timestamp = "%H:%M:%S %d-%m-%Y",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        -- Check diff of a commit
        on_select_commit = function(commit)
          vim.notify("DiffviewOpen " .. commit.hash .. "^!")
          vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
        end,
        -- Check diff from commit a -> commit b
        on_select_range_commit = function(from, to)
          vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
    },
    keys = {
      {
        "<leader>gl",
        function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end,
        desc = "GitGraph - Draw",
      },
    },
  },
}
