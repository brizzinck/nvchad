-- agentdash: live view of Claude Code / Codex sessions, subagents, tasks and touched
-- files inside Neovim, fed by agent lifecycle hooks (see install.lua / hook.sh).
local M = {}

function M.setup(opts)
  opts = opts or {}
  local tail = require "agentdash.tail"
  local ui = require "agentdash.ui"

  tail.on_change(function()
    if ui.is_open() then
      ui.redraw()
    end
    vim.cmd "redrawstatus"
  end)
  tail.start { interval = opts.poll_ms or 500 }

  -- elapsed-time ticker while the sidebar is visible
  local timer = vim.uv.new_timer()
  timer:start(5000, 5000, vim.schedule_wrap(function()
    if ui.is_open() then
      ui.redraw()
    end
  end))

  vim.api.nvim_create_user_command("AgentDash", function(a)
    ui.toggle { float = a.args == "float" }
  end, { nargs = "?", complete = function() return { "float" } end, desc = "Toggle agent dashboard" })
  vim.api.nvim_create_user_command("AgentDashInstallHooks", function()
    require("agentdash.install").run()
  end, { desc = "Install Claude Code / Codex hooks for agentdash + code-preview" })
  vim.api.nvim_create_user_command("AgentDashClear", function()
    require("agentdash.store").reset()
    ui.redraw()
  end, { desc = "Forget all sessions" })
end

return M
