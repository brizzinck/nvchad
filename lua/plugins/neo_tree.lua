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
      filesystem = {
        follow_current_file = true,
        hijack_netrw = true,
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["s"] = "open_split",
            ["S"] = "open_vsplit",
            ["?"] = "show_help",
          },
        },
      },
    }
  end,
}
