return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-e>",
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
