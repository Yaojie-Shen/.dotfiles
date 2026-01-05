return {
  {
    "mfussenegger/nvim-dap",
    lazy = { "VeryLazy" },
    config = function()
      -- Customize icons for breakpoints
      -- See issue: https://github.com/mfussenegger/nvim-dap/issues/1341
      vim.cmd "hi DapBreakpointColor guifg=#fa4848"
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpointColor", linehl = "", numhl = "" })
    end,
    -- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and modified.
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dT",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
    },
  },

  -- Integrate with Mason, to install and manage DAP adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = { "VeryLazy" },
    opts = {
      -- This line is essential to making automatic installation work
      handlers = {},
      -- automatic_installation = {
      --   -- These will be configured by separate plugins.
      --   exclude = {
      --     "python",
      --   },
      -- },
      -- DAP servers: Mason will be invoked to install these if necessary.
      ensure_installed = {
        "python",
      },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "williamboman/mason.nvim",
    },
  },

  -- Following plugins are about UI setups for DAP
  {
    "theHamsta/nvim-dap-virtual-text",
    config = true,
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle {}
        end,
        desc = "Dap UI",
      },
    },
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
  },

  -- Configure DAP for specific language
  {
    "mfussenegger/nvim-dap-python",
    lazy = { "VeryLazy" },
    config = function()
      local python = vim.fn.expand "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(python)
    end,
    -- Consider the mappings at
    -- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#mappings
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
}
