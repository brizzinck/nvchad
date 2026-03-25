return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      render_modes = { "n", "c" },
      anti_conceal = { enabled = true },
      heading = {
        enabled = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        enabled = true,
        width = "full",
        style = "full",
        border = "hide",
        disable_background = true,
      },
      bullet = { enabled = true },
      checkbox = { enabled = true },
      quote = { enabled = true },
      table = { enabled = true },
      link = { enabled = true },
    },
  },

  {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {
      features = {
        list_management = true,
        text_formatting = true,
        thematic_break = true,
        links = true,
        headers_toc = true,
        quotes = true,
        callouts = true,
        code_block = true,
        table = true,
        footnotes = true,
      },
      keymaps = { enabled = true },
      table = {
        enabled = true,
        auto_format = true,
        keymaps = {
          enabled = true,
          prefix = "<localleader>t",
          insert_mode_navigation = true,
        },
      },
    },
  },

  {
    "folke/zen-mode.nvim",
    ft = "markdown",
    opts = {
      window = {
        width = 100,
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },
}
