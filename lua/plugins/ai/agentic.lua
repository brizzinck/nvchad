-- agentic.nvim: Agent Client Protocol chat inside a buffer. Used for quick questions,
-- explain/refactor-this-selection, second opinions — heavy work stays in the tmux CLIs.
-- Providers: claude-agent-acp (npm @agentclientprotocol/claude-agent-acp),
--            codex-acp (npm @zed-industries/codex-acp), gemini (gemini-cli --acp).
return {
  "carlos-algms/agentic.nvim",
  cmd = { "Agentic" },
  keys = {
    { "<leader>aq", function() require("agentic").toggle() end, mode = { "n", "x" }, desc = "AI: quick chat (ACP)" },
    { "<leader>an", function() require("agentic").new_session() end, desc = "AI: new ACP session" },
    {
      "<leader>a@",
      function() require("agentic").add_selection_or_file_to_context() end,
      mode = { "n", "x" },
      desc = "AI: add selection/file to ACP context",
    },
  },
  opts = {
    provider = "claude-agent-acp",
    windows = {
      position = "right",
      width = "42%",
    },
  },
}
