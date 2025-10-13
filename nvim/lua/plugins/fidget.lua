return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach", -- Load fidget when LSP is attached
    opts = {
      progress = {
        display = {
          done_ttl = 5,
          done_icon = "✔",
        },
      },
    },
  },
}
