require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })
map("i", "<C-s>", "<Esc>:w<CR>a", { noremap = true, silent = true })

map('n', '<leader>td', ':TodoTelescope<CR>', { noremap = true, silent = true, desc = "telescope project todo-comments" })

-- minuet-ai virtual text completion, map <Tab> to accept suggestion, fallback to insert a <Tab> if there is no suggestion
-- Credit and more details: https://github.com/milanglacier/minuet-ai.nvim/issues/113
-- Note: Do not set keymap for accept in minuet-ai's configuration of virtualtext keymap.
vim.keymap.set({ 'i' }, '<tab>', function()
    local mv = require 'minuet.virtualtext'
    if mv.action.is_visible() then
        vim.defer_fn(require('minuet.virtualtext').action.accept, 30)
        return
        -- respect the default behavior of snippet jumping for tab
    elseif vim.snippet.active { direction = 1 } then
        return string.format('<Cmd>lua vim.snippet.jump(%d)<CR>', 1)
    else
        return '<tab>'
    end
end, {
    desc = 'Accept minuet completion if available, jump snippet if active, otherwise insert tab.',
    expr = true,
    silent = true,
})
-- Similar to above, but dismiss the suggestion if available, otherwise perform like normal <ESC>.
vim.keymap.set({ 'i' }, '<Esc>', function()
    local mv = require 'minuet.virtualtext'
    if mv.action.is_visible() then
        vim.defer_fn(require('minuet.virtualtext').action.dismiss, 10)
        return
    else
        return '<esc>'
    end
end, {
    desc = 'Dismiss minuet completion if available, otherwise <ESC>.',
    expr = true,
    silent = true,
})

