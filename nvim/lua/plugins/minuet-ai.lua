return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "VeryLazy",
    config = function()
      require("minuet").setup {
        provider = "openai_fim_compatible",
        n_completions = 1, -- recommend for local model for resource saving
        -- I recommend beginning with a small context window size and incrementally
        -- expanding it, depending on your local computing power. A context window
        -- of 512, serves as an good starting point to estimate your computing
        -- power. Once you have a reliable estimate of your local computing power,
        -- you should adjust the context window to a larger value.
        context_window = 512,
        provider_options = {
          -- Run the follwing command to start the server:
          --   devbox setup ollama
          --   ollama serve
          --   ollama run deepseek-coder-v2 --keepalive=999h
          openai_fim_compatible = {
            -- For Windows users, TERM may not be present in environment variables.
            -- Consider using APPDATA instead.
            api_key = "TERM",
            name = "Ollama",
            end_point = "http://localhost:11434/v1/completions",
            model = "deepseek-coder-v2",
            stream = true,
            optional = {
              max_tokens = 128,
              top_p = 0.9,
              -- stop = { '\n' } -- NOTE(yaojie): Only complete for one line.
            },
          },
        },
        -- -- Use neovim built-in completion. According to the readme of minute, this require neovim version 0.11 or higher.
        -- lsp = {
        --   enabled_ft = { "*" },
        --   -- Enables automatic completion triggering using `vim.lsp.completion.enable`
        --   enabled_auto_trigger_ft = { },
        -- },
        virtualtext = {
          auto_trigger_ft = { "*" },
          keymap = {},
        },
        request_timeout = 10,
      }
    end,
    keys = {
      -- Keymap for virtual text completion, map <Tab> to accept suggestion, fallback to insert a <Tab> if there is no suggestion
      -- Credit and more details: https://github.com/milanglacier/minuet-ai.nvim/issues/113
      -- Note: Do not set keymap for accept in minuet-ai's configuration of virtualtext keymap.
      {
        "<tab>",
        function()
          local mv = require "minuet.virtualtext"
          if mv.action.is_visible() then
            vim.defer_fn(require("minuet.virtualtext").action.accept, 30)
            return
          -- respect the default behavior of snippet jumping for tab
          elseif vim.snippet.active { direction = 1 } then
            return string.format("<Cmd>lua vim.snippet.jump(%d)<CR>", 1)
          else
            return "<tab>"
          end
        end,
        mode = "i",
        desc = "Accept minuet completion if available, jump snippet if active, otherwise insert tab.",
        expr = true,
        silent = true,
      },
      {
        "<Esc>",
        function()
          local mv = require "minuet.virtualtext"
          if mv.action.is_visible() then
            vim.defer_fn(require("minuet.virtualtext").action.dismiss, 10)
            return
          else
            return "<esc>"
          end
        end,
        mode = "i",
        desc = "Dismiss minuet completion if available, otherwise <ESC>.",
        expr = true,
        silent = true,
      },
    },
  },
  { "nvim-lua/plenary.nvim" },
  -- optional, if you are using virtual-text frontend, nvim-cmp is not required.
  -- { 'hrsh7th/nvim-cmp' },
  -- optional, if you are using virtual-text frontend, blink is not required.
  -- { 'Saghen/blink.cmp' },
}
