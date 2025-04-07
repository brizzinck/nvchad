return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-file-browser.nvim" },
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
      },
    }
    telescope.load_extension "file_browser"

    vim.keymap.set("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "Open File Browser" })
  end,
}
