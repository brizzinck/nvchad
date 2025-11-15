return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          workspace = {
            checkThirdParty = false,
          },
        },
      },
    })
  end,
}
