return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach", -- 当 LSP 启动时加载
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
