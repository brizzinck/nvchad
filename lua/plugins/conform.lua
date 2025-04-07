return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require "configs.conform_cfg"
  end,
}
