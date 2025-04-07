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

    local function enable_numbers_if_neotree()
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if ft == "neo-tree" then
        vim.opt_local.number = true
        vim.opt_local.relativenumber = true
      end
    end

    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "CursorHold" }, {
      callback = enable_numbers_if_neotree,
    })

    vim.schedule(function()
      enable_numbers_if_neotree()
    end)
  end,
}
