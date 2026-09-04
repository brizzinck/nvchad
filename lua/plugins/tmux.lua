return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Window/pane left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Window/pane down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Window/pane up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Window/pane right" },
  },
}
