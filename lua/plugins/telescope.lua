return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-file-browser.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require "telescope"
    telescope.setup {
      extensions = {
        file_browser = {
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              ["m"] = require("telescope").extensions.file_browser.actions.move,
            },
          },
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    }
    telescope.load_extension "file_browser"
    telescope.load_extension "fzf"

    vim.keymap.set("n", "<leader>fB", "<cmd>Telescope file_browser<CR>", { desc = "Open File Browser" })
  end,
}
