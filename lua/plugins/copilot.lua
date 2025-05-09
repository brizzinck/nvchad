return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = false,
          auto_trigger = false,
          keymap = {
            accept = "<C-enter>",
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-d>",
          },
        },
        panel = {
          enabled = true,
          keymap = {
            accept = "<CR>",
            refresh = "gr",
            open = "<C-o>",
          },
        },
      }
    end,
  },
  {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "github/copilot.vim" },
        { "nvim-lua/plenary.nvim", branch = "master" },
      },
      build = "make tiktoken",
      cmd = { "CopilotChat" },
      opts = {},
    },
  },
}
