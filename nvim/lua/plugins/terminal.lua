local function set_toggle_keymap(buf)
  local function floaterm_toggle()
    require("floaterm").toggle()
  end
  -- shared function for setting keymap for term and sidebar pannel
  vim.keymap.set("n", "<ESC>", floaterm_toggle, { buffer = buf })
  vim.keymap.set("n", "q", floaterm_toggle, { buffer = buf })
end

return {
  {
    "nvzone/floaterm",
    dependencies = "nvzone/volt",
    opts = {
      border = true,
      mappings = {
        term = function(buf)
          set_toggle_keymap(buf)
        end,
        sidebar = function(buf)
          set_toggle_keymap(buf)
        end,
      },
    },
    cmd = "FloatermToggle",
    keys = {
      { "<leader>tt", "<cmd>FloatermToggle<cr>", desc = "toggle floaterm terminal ui" },
    },
  },
}
