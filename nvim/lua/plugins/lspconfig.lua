return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").pyright.setup({
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })
    end,
  },
}
