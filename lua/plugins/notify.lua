return {
  "rcarriga/nvim-notify",
  config = function()
    vim.notify = require "notify"
    vim.notify.setup {
      stages = "fade_in_slide_out",
      timeout = 3000,
      render = "compact",
      max_width = 50,
      minimum_width = 30,
      top_down = false,
    }
  end,
}
