return {
  "sainnhe/everforest",
  lazy = false,
  priority = 10000,
  config = function()
    vim.o.termguicolors = true

    vim.g.everforest_background = "medium"

    vim.cmd [[colorscheme everforest]]
  end,
}
