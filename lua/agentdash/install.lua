-- agentdash.install: wire agent hooks (Claude Code + Codex) globally, without clobbering
-- anything else in the settings files. code-preview.nvim hooks are NOT installed for
-- Claude Code here (use :CodePreviewInstallClaudeCodeHooks per project); Codex still gets them.
local M = {}

local HOOK_BIN = vim.fn.expand "~/.local/bin/agentdash-hook"
local HOOK_SRC = debug.getinfo(1, "S").source:sub(2):gsub("install%.lua$", "hook.sh")

local EVENTS = {
  "SessionStart",
  "UserPromptSubmit",
  "PreToolUse",
  "PostToolUse",
  "PostToolUseFailure",
  "PermissionRequest",
  "Notification",
  "SubagentStart",
  "SubagentStop",
  "TaskCreated",
  "TaskCompleted",
  "Stop",
  "StopFailure",
  "SessionEnd",
}
-- Codex 0.153 supports a subset (no Task*/Notification/PostToolUseFailure/StopFailure)
local CODEX_EVENTS = {
  "SessionStart",
  "UserPromptSubmit",
  "PreToolUse",
  "PostToolUse",
  "PermissionRequest",
  "SubagentStart",
  "SubagentStop",
  "Stop",
  "SessionEnd",
}

local function read_json(path)
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local s = f:read "*a"
  f:close()
  if s == "" then
    return {}
  end
  local ok, data = pcall(vim.json.decode, s, { luanil = { object = true, array = true } })
  if not ok or type(data) ~= "table" then
    error("agentdash: cannot parse " .. path .. " — refusing to touch it")
  end
  return data
end

local function backup(path)
  if vim.fn.filereadable(path) ~= 1 then
    return
  end
  local dir = vim.fn.fnamemodify(path, ":h") .. "/backups"
  vim.fn.mkdir(dir, "p")
  local dst = string.format("%s/%s.%s.bak", dir, vim.fn.fnamemodify(path, ":t"), os.date "%Y%m%d-%H%M%S")
  vim.fn.writefile(vim.fn.readfile(path), dst)
  return dst
end

local function write_json(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  -- pretty print via jq if available (keeps the file human-diffable), else compact
  local encoded = vim.json.encode(data)
  if vim.fn.executable "jq" == 1 then
    local pretty = vim.fn.system({ "jq", "." }, encoded)
    if vim.v.shell_error == 0 then
      encoded = pretty
    end
  end
  local f = assert(io.open(path, "w"))
  f:write(encoded)
  f:close()
end

local function has_command(entries, needle)
  for _, entry in ipairs(entries or {}) do
    for _, h in ipairs(entry.hooks or {}) do
      if type(h.command) == "string" and h.command:find(needle, 1, true) then
        return true
      end
    end
  end
  return false
end

--- Add {matcher, hooks={command}} to data.hooks[event] unless a hook whose command
--- contains `marker` is already present. Returns true if added.
local function add_hook(data, event, matcher, command, marker)
  data.hooks = data.hooks or {}
  data.hooks[event] = data.hooks[event] or {}
  if has_command(data.hooks[event], marker) then
    return false
  end
  table.insert(data.hooks[event], {
    matcher = matcher,
    hooks = { { type = "command", command = command } },
  })
  return true
end

local function install_hook_bin()
  vim.fn.mkdir(vim.fn.fnamemodify(HOOK_BIN, ":h"), "p")
  vim.fn.writefile(vim.fn.readfile(HOOK_SRC), HOOK_BIN)
  vim.fn.setfperm(HOOK_BIN, "rwxr-xr-x")
end

local function code_preview_entry()
  local ok, lazy = pcall(require, "lazy.core.config")
  local plugin = ok and lazy.plugins["code-preview.nvim"]
  if not plugin then
    return nil
  end
  return plugin.dir .. "/bin/hook-entry.sh"
end

function M.install_claude()
  local path = vim.fn.expand "~/.claude/settings.json"
  local data = read_json(path)
  local added = 0
  local cmd = "AGENTDASH_AGENT=claude " .. HOOK_BIN
  for _, ev in ipairs(EVENTS) do
    if add_hook(data, ev, "*", cmd, "agentdash-hook") then
      added = added + 1
    end
  end
  if added > 0 then
    local bak = backup(path)
    write_json(path, data)
    return string.format("claude: %d hook entries added (backup: %s)", added, bak or "none")
  end
  return "claude: hooks already installed"
end

function M.install_codex()
  local path = vim.fn.expand "~/.codex/hooks.json"
  local data = read_json(path)
  local added = 0
  local cmd = "AGENTDASH_AGENT=codex " .. HOOK_BIN
  for _, ev in ipairs(CODEX_EVENTS) do
    if add_hook(data, ev, "", cmd, "agentdash-hook") then
      added = added + 1
    end
  end
  local cp = code_preview_entry()
  if cp then
    if add_hook(data, "PreToolUse", "", cp .. " codex pre", "hook-entry") then
      added = added + 1
    end
    if add_hook(data, "PostToolUse", "", cp .. " codex post", "hook-entry") then
      added = added + 1
    end
  end
  if added > 0 then
    local bak = backup(path)
    write_json(path, data)
    return string.format("codex: %d hook entries added (backup: %s)", added, bak or "none")
  end
  return "codex: hooks already installed"
end

function M.run()
  install_hook_bin()
  local msgs = { "agentdash-hook → " .. HOOK_BIN }
  for _, fn in ipairs { M.install_claude, M.install_codex } do
    local ok, res = pcall(fn)
    table.insert(msgs, ok and res or ("ERROR " .. tostring(res)))
  end
  vim.notify(table.concat(msgs, "\n"), vim.log.levels.INFO, { title = "agentdash" })
end

return M
