vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.o.shell = "zsh"
-- use relative line number by default
vim.opt.relativenumber = true

vim.opt.fillchars:append { diff = "╱" }

-- Use vertical bar cursor in terminal-insert mode
vim.opt.guicursor:append "t:ver25"

vim.opt.termguicolors = true

-- Global table to track active file watchers (prevents resource leaks)
local active_watchers = {}
-- Real-time file watcher to fix "File has been changed since reading it"
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function(ev)
    local bufnr = ev.buf
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    -- Skip empty, special buffers, or already watched files
    if filepath == "" or vim.bo[bufnr].buftype ~= "" or active_watchers[bufnr] then
      return
    end

    -- Create OS-level file system event listener
    local w = vim.uv.new_fs_event()
    if not w then
      return
    end

    -- Store the watcher reference tied to this specific buffer
    active_watchers[bufnr] = w

    w:start(
      filepath,
      {},
      vim.schedule_wrap(function(err)
        if err then
          if active_watchers[bufnr] then
            active_watchers[bufnr]:stop()
            active_watchers[bufnr] = nil
          end
          return
        end

        -- SAFE GUARD: Sync ONLY if you have NO unsaved changes inside Neovim
        if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified then
          vim.cmd "silent! checktime"
        end
      end)
    )
  end,
})
-- CLEANUP MECHANISM: Automatically stop and destroy the watcher when buffer is closed
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  pattern = "*",
  callback = function(ev)
    local bufnr = ev.buf
    if active_watchers[bufnr] then
      active_watchers[bufnr]:stop() -- Stop the OS listener
      active_watchers[bufnr] = nil -- Free memory
    end
  end,
})
