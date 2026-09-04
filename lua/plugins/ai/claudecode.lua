-- claudecode.nvim: IDE bridge for Claude Code (same WebSocket/MCP protocol as the VS Code
-- extension). Server-only: Claude itself is launched by sidekick.nvim in a tmux window,
-- then `/ide` (or auto-detect via ~/.claude/ide/*.lock) connects it here for native
-- diff review and @-mentions.
-- If nvim ever dies ungracefully (crash, `tmux kill-window`, SIGKILL, power loss),
-- VimLeavePre never runs and its ~/.claude/ide/<port>.lock file is orphaned — Claude's
-- `/ide` picker would then keep offering a dead Neovim instance forever. Since you run
-- many of these at once and expect it to "just work indefinitely", drop any lock whose
-- pid is no longer alive before this instance's own server starts.
local function clean_stale_locks()
  local dir = vim.fn.expand((vim.env.CLAUDE_CONFIG_DIR or "~/.claude")) .. "/ide"
  for _, path in ipairs(vim.fn.glob(dir .. "/*.lock", false, true)) do
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
    if ok and type(data) == "table" and data.pid then
      local alive = vim.fn.system({ "kill", "-0", tostring(data.pid) })
      if vim.v.shell_error ~= 0 then
        os.remove(path)
      end
    end
  end
end

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
  config = function(_, opts)
    clean_stale_locks()
    require("claudecode").setup(opts)
  end,
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
