-- claudecode.nvim: IDE bridge for Claude Code (same WebSocket/MCP protocol as the VS Code
-- extension). Server-only: Claude itself is launched by sidekick.nvim in a tmux window,
-- then `/ide` (or auto-detect via ~/.claude/ide/*.lock) connects it here for native
-- diff review and @-mentions.
return {
  "coder/claudecode.nvim",
  event = "VeryLazy",
  opts = {
    auto_start = true,
    log_level = "warn",
    track_selection = true,
    terminal = {
      provider = "none",
    },
    diff_opts = {
      layout = "vertical",
      open_in_new_tab = true,
      keep_terminal_focus = false,
    },
  },
  keys = {
    { "<leader>aS", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: @-mention selection" },
    { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current file" },
    { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
    { "<leader>aN", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
    { "<leader>aC", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude: IDE bridge status" },
    {
      "<leader>aS",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Claude: add file from tree",
      ft = { "neo-tree", "oil", "NvimTree" },
    },
  },
}
