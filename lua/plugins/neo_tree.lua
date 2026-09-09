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
    local is_media = require("utils.media").is_media
    local function open_or_play(state)
      local node = state.tree:get_node()
      if node.type == "file" and is_media(node.path) then
        require("utils.mpv").open(node.path)
      else
        state.commands.open(state)
      end
    end

    require("neo-tree").setup {
      window = {
        mappings = {
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["?"] = "show_help",
          -- recursively open every directory under the node ("z" already
          -- collapses everything back down, via neo-tree's own default)
          ["Z"] = "expand_all_subnodes",
          -- mp4/mp3/etc play in mpv instead of opening as an nvim buffer.
          ["<cr>"] = open_or_play,
          ["<2-LeftMouse>"] = open_or_play,
          -- uppercase: lowercase "m" is already neo-tree's own "move" mapping,
          -- and <leader>m* (utils/mpv.lua) never reaches here anyway since
          -- <space> is neo-tree's own toggle_node, eating the leader keypress.
          ["M"] = function(state)
            local node = state.tree:get_node()
            if node.type == "file" then require("utils.mpv").open(node.path) end
          end,
          -- neo-tree's own quick-preview ("P") pipes the previewed buffer
          -- through image.nvim/snacks.image for real images; when you move
          -- from an actual image to a video (which those can't render), the
          -- previous image is never cleared and stays stuck on screen. Media
          -- files play in mpv anyway (above), so there's nothing worth
          -- rendering here -- keep the plain text/float preview only.
          ["P"] = {
            "toggle_preview",
            config = { use_float = true, use_snacks_image = false, use_image_nvim = false },
          },
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
