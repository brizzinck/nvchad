-- Extra CLI sessions for sidekick.nvim.
-- sidekick identifies a session by tool name + cwd, so a second `claude` in the same
-- project is impossible by default. We register runtime clones ("claude_2", "claude_3", …)
-- that share the base tool's command; each gets its own tmux window.
local M = {}

local BASE_TOOLS = { "claude", "codex", "gemini", "copilot" }

local function base_cmd(tool)
  local ok, Tool = pcall(require, "sidekick.cli.tool")
  if ok then
    local t = Tool.get(tool)
    if t and t.config and t.config.cmd then
      return vim.deepcopy(t.config.cmd)
    end
  end
  return { tool }
end

--- Register `<tool>_<n>` (first free n ≥ 2) and return its name.
function M.new_slot(tool)
  local tools = require("sidekick.config").cli.tools
  local n = 2
  while tools[tool .. "_" .. n] do
    n = n + 1
  end
  local name = tool .. "_" .. n
  tools[name] = {
    cmd = base_cmd(tool),
    -- no is_proc: keeps tmux process discovery from mixing clones with the base tool
  }
  return name
end

--- Open a new session of `tool` (asks which tool when nil).
function M.open_new(tool)
  local function go(t)
    local name = M.new_slot(t)
    require("sidekick.cli").show { name = name, focus = true }
    vim.notify("sidekick: new session " .. name, vim.log.levels.INFO)
  end
  if tool then
    return go(tool)
  end
  vim.ui.select(BASE_TOOLS, { prompt = "New AI session:" }, function(choice)
    if choice then
      go(choice)
    end
  end)
end

--- Names of all registered clones (for pickers / cleanup).
function M.slots()
  local out = {}
  for name in pairs(require("sidekick.config").cli.tools) do
    if name:match "_%d+$" then
      table.insert(out, name)
    end
  end
  table.sort(out)
  return out
end

return M
