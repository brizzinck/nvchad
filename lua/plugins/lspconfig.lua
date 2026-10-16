return {
  "neovim/nvim-lspconfig",
  dependencies = { "b0o/SchemaStore.nvim" },
  config = function()
    require "configs.lspconfig"
  end,
}
