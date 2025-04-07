return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  {
    "dreamsofcode-io/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)

      vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Continue Debugging" })
    end,
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle" },
    config = function()
      vim.g.db_ui_save_location = "~/.config/nvim/db_connections"
    end,
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "kristijanhusak/vim-dadbod-ui", "tpope/vim-dadbod", "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require "cmp"
      cmp.setup {
        sources = {
          { name = "vim-dadbod-completion" },
        },
      }
    end,
    ft = { "sql" },
  },
}
