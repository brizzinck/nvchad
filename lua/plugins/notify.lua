return {
  "rcarriga/nvim-notify",
  -- defaults.lazy = true and no trigger meant this never loaded and vim.notify stayed the stock one
  event = "VeryLazy",
  opts = {
    stages = "static", -- no slide animation: snappy
    timeout = 3000,
    render = "wrapped-compact",
    max_width = 60,
    minimum_width = 30,
    top_down = false,
    background_colour = (require("palette").get() or { tokens = { bg = "#000000" } }).tokens.bg,
  },
  config = function(_, opts)
    local notify = require "notify"
    notify.setup(opts)
    vim.notify = notify
  end,
}
