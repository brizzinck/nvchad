return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  config = function()
    require "configs.lint_cfg"
  end,
}
