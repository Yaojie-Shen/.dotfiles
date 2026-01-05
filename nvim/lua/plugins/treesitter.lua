return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "vim", "lua", "vimdoc", "html", "css", "python", "bash", "c", "cpp", "csv", "json", "yaml" },
    },
  },
}
