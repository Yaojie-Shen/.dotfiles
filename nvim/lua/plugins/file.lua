return {
  -- Tree view: file explorer
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    opts = {
      filters = {
        -- Show dotfiles
        dotfiles = false,
        -- Show git-ignored files
        git_ignored = false,
      },
      renderer = {
        -- Do not group empty folders into one line
        group_empty = false,
      },
      view = {
        -- Auto-resize tree width
        adaptive_size = true,
      },
      git = {
        enable = true,
        -- Do not hide git-ignored files
        ignore = false,
      },
    },
  },
}
