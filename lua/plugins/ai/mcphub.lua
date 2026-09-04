-- mcphub.nvim: one MCP hub for every agent. Servers live in ~/.config/mcphub/servers.json;
-- Claude Code / Codex / agentic.nvim all connect to the unified endpoint
-- http://localhost:37373/mcp instead of each keeping its own server list.
return {
  "ravitemer/mcphub.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  build = "npm install -g mcp-hub@latest",
  cmd = { "MCPHub" },
  keys = {
    { "<leader>am", "<cmd>MCPHub<cr>", desc = "AI: MCP hub" },
  },
  opts = {
    port = 37373,
    config = vim.fn.expand "~/.config/mcphub/servers.json",
    auto_approve = false,
    native_servers = {},
  },
}
