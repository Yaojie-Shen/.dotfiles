-- This plugin is used to highlight todo comments like `TODO`, `NOTE`, `WARNING` in code
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufReadPre",
  config = function()
    require("todo-comments").setup {
      -- Customize setup here
    }
  end
}
