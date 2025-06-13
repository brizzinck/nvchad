return {
  "NvChad/nvterm",
  config = function()
    require("nvterm").setup {
      terminals = {
        type_opts = {
          float = {
            relative = "editor",
            row = 0.20,
            col = 0.20,
            width = 0.6,
            height = 0.65,
            border = "single",
          },
          horizontal = { location = "rightbelow", split_ratio = 0.3 },
          vertical = { location = "rightbelow", split_ratio = 0.5 },
        },
      },
      behavior = {
        autoclose_on_quit = {
          enabled = true,
          confirm = false,
        },
        close_on_exit = true,
        auto_insert = true,
      },
    }
  end,
}
