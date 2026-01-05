return {
  -- Rainbow
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      require("rainbow-delimiters.setup").setup {
        -- Your configuration options here
      }
    end,
  },
}
