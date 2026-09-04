-- code-preview.nvim: show an agent's proposed edit as a native diff in Neovim BEFORE it
-- is written to disk (Claude Code / Codex / Copilot CLI PreToolUse hooks). Accept or reject
-- stays in the agent's own CLI; the preview just closes.
return {
  "Cannon07/code-preview.nvim",
  event = "VeryLazy",
  opts = {
    diff = {
      layout = "vsplit",
      defer_claude_permissions = true,
    },
  },
  keys = {
    { "<leader>av", "<cmd>CodePreviewStatus<cr>", desc = "AI: code-preview status" },
  },
}
