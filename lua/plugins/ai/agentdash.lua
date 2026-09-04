-- Local plugin: lua/agentdash/ (sessions/subagents/tasks dashboard fed by agent hooks).
return {
  dir = vim.fn.stdpath "config",
  name = "agentdash",
  lazy = false, -- tiny; must be up before hooks start writing events
  config = function()
    require("agentdash").setup()
  end,
  keys = {
    { "<leader>ad", "<cmd>AgentDash<cr>", desc = "AI: agent dashboard" },
    { "<leader>aD", "<cmd>AgentDashInstallHooks<cr>", desc = "AI: install agent hooks" },
  },
}
