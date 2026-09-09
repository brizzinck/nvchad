-- mcphub.nvim: one MCP hub for every agent. Servers live in /srv/mcphub/servers.json;
-- Claude Code / Codex / agentic.nvim all connect to the unified endpoint
-- http://localhost:37373/mcp instead of each keeping its own server list.
-- This machine runs several Linux users (skalse/td/yc) sharing one hub process, so the
-- config path must be a location all of them can read/write — not ~/.config, which only
-- the user who happens to launch the hub first could access (permission denied for others).
return {
  "ravitemer/mcphub.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  build = "npm install -g mcp-hub@latest",
  -- eager: Claude/Codex point at localhost:37373, so the hub must be up whenever nvim is
  event = "VeryLazy",
  keys = {
    { "<leader>am", "<cmd>MCPHub<cr>", desc = "AI: MCP hub" },
  },
  opts = {
    port = 37373,
    config = "/srv/mcphub/servers.json",
    auto_approve = false,
    native_servers = {},
  },
}
