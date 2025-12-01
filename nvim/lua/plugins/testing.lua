return {
  {
    "nvim-neotest/neotest",
    event = { "VeryLazy", "BufReadPost" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- adapter for test runner
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-python" {
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG", "-s" },
          },
        },
      }
    end,
  },
}
