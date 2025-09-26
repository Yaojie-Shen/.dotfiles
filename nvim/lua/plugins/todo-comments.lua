-- This plugin is used to highlight todo comments like `TODO`, `NOTE`, `WARNING` in code
return {
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
    end
}
