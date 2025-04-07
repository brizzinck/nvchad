return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      "s1n7ax/nvim-window-picker",
      version = "2.*",
      config = function()
        require("window-picker").setup()
      end,
    },
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle filesystem<CR>", desc = "Toggle NeoTree" },
    { "<leader>o", "<cmd>Neotree focus filesystem<CR>", desc = "Focus NeoTree" },
  },
  config = function()
    require("neo-tree").setup {
      window = {
        mappings = {
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["?"] = "show_help",
        },
      },
      filesystem = {
        hijack_netrw = true,
        use_libuv_file_watcher = true,
      },
    }
    vim.defer_fn(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "neo-tree" then
          vim.api.nvim_set_option_value("number", true, { win = win })
          vim.api.nvim_set_option_value("relativenumber", true, { win = win })
        end
      end
    end, 100)
  end,
}
