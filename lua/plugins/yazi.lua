return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  version = "*",
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Yazi at current file" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi in cwd" },
    -- <C-Up> is already bound to window resize, use <leader>y instead
    { "<leader>y", "<cmd>Yazi toggle<cr>", desc = "Toggle last Yazi session" },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
}
