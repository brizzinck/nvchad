-- agentdash.store: reducer turning hook events into a sessions model.
local M = {}

M.sessions = {} -- session_id -> session
M.order = {} -- session ids in first-seen order
M.version = 0 -- bumped on every change (UI redraw trigger)

local TOOL_RING = 50
local EDIT_TOOLS = { Edit = true, Write = true, MultiEdit = true, NotebookEdit = true, apply_patch = true }

local function now()
  return os.time()
end

local function project_of(cwd)
  if not cwd or cwd == "" then
    return "?"
  end
  return cwd:match "([^/]+)/?$" or cwd
end

local function get_session(ev)
  local id = ev.session_id or "unknown"
  local s = M.sessions[id]
  if not s then
    s = {
      id = id,
      agent = ev.agent or "unknown",
      cwd = ev.cwd or "",
      project = project_of(ev.cwd),
      tmux_pane = (ev.tmux_pane ~= "" and ev.tmux_pane) or nil,
      status = "working",
      started = ev.ts or now(),
      last_event = ev.ts or now(),
      last_msg = nil,
      prompt = nil,
      waiting_on = nil,
      files = {},
      files_order = {},
      tools = {},
      subagents = {},
      subagents_order = {},
      tasks = {},
      tasks_order = {},
      expanded = true,
    }
    M.sessions[id] = s
    table.insert(M.order, id)
  end
  if ev.cwd and ev.cwd ~= "" and s.cwd == "" then
    s.cwd, s.project = ev.cwd, project_of(ev.cwd)
  end
  if ev.tmux_pane and ev.tmux_pane ~= "" then
    s.tmux_pane = ev.tmux_pane
  end
  s.last_event = ev.ts or now()
  return s
end

local function touch_file(s, path)
  if not path or path == "" then
    return
  end
  if not s.files[path] then
    s.files[path] = true
    table.insert(s.files_order, path)
  end
end

local function push_tool(s, t)
  table.insert(s.tools, t)
  if #s.tools > TOOL_RING then
    table.remove(s.tools, 1)
  end
end

local function short_tool(ev)
  local name = ev.tool_name or "?"
  local inp = ev.tool_input or {}
  local detail = inp.command or inp.file_path or inp.pattern or inp.description or ""
  if type(detail) ~= "string" then
    detail = ""
  end
  detail = detail:gsub("\n.*", "")
  if #detail > 60 then
    detail = detail:sub(1, 57) .. "..."
  end
  return name, detail
end

local handlers = {}

handlers.SessionStart = function(s, ev)
  s.status = "idle"
  s.model = ev.model
end

handlers.UserPromptSubmit = function(s, ev)
  s.status = "working"
  s.waiting_on = nil
  s.prompt = ev.prompt or ev.user_input
  s.turn_started = ev.ts or now()
end

handlers.PreToolUse = function(s, ev)
  s.status = "working"
  s.waiting_on = nil
  local name, detail = short_tool(ev)
  push_tool(s, { id = ev.tool_use_id, name = name, detail = detail, started = ev.ts or now(), agent_id = ev.agent_id })
end

handlers.PostToolUse = function(s, ev)
  local name, detail = short_tool(ev)
  for i = #s.tools, 1, -1 do
    local t = s.tools[i]
    if ev.tool_use_id and t.id == ev.tool_use_id then
      t.ended, t.ok = ev.ts or now(), true
      break
    end
  end
  if EDIT_TOOLS[name] then
    local inp = ev.tool_input or {}
    touch_file(s, inp.file_path or inp.path)
  end
  s.status = "working"
end

handlers.PostToolUseFailure = function(s, ev)
  for i = #s.tools, 1, -1 do
    local t = s.tools[i]
    if ev.tool_use_id and t.id == ev.tool_use_id then
      t.ended, t.ok, t.error = ev.ts or now(), false, ev.error
      break
    end
  end
end

handlers.PermissionRequest = function(s, ev)
  s.status = "waiting"
  local name, detail = short_tool(ev)
  s.waiting_on = name .. (detail ~= "" and (" " .. detail) or "")
end

handlers.Notification = function(s, ev)
  local kind = ev.notification_type or ""
  if kind:match "permission" then
    s.status = "waiting"
    s.waiting_on = s.waiting_on or (ev.message or "permission")
  elseif kind:match "idle" then
    s.status = "waiting"
    s.waiting_on = "idle — waiting for input"
  end
end

handlers.SubagentStart = function(s, ev)
  local id = ev.agent_id or tostring(ev.ts)
  if not s.subagents[id] then
    table.insert(s.subagents_order, id)
  end
  s.subagents[id] = {
    id = id,
    type = ev.agent_type or "agent",
    status = "working",
    started = ev.ts or now(),
  }
end

handlers.SubagentStop = function(s, ev)
  local id = ev.agent_id
  local a = id and s.subagents[id]
  if a then
    a.status, a.ended, a.last_msg = "done", ev.ts or now(), ev.last_assistant_message
  end
end

handlers.TaskCreated = function(s, ev)
  local id = ev.task_id or tostring(ev.ts)
  if not s.tasks[id] then
    table.insert(s.tasks_order, id)
  end
  s.tasks[id] = {
    id = id,
    description = ev.task_description or ev.task_subject or ev.description or "task",
    status = "pending",
    created = ev.ts or now(),
  }
end

handlers.TaskCompleted = function(s, ev)
  local t = ev.task_id and s.tasks[ev.task_id]
  if t then
    t.status, t.completed = ev.status or "completed", ev.ts or now()
  end
end

handlers.Stop = function(s, ev)
  s.status = "done"
  s.waiting_on = nil
  s.last_msg = ev.last_assistant_message
  s.turn_ended = ev.ts or now()
end

handlers.StopFailure = function(s, ev)
  s.status = "error"
  s.waiting_on = (ev.error_type or "error") .. ": " .. (ev.error_message or "")
end

handlers.SessionEnd = function(s, ev)
  s.status = "ended"
  s.ended = ev.ts or now()
end

--- Apply one decoded event. Returns true when state changed.
function M.apply(ev)
  if type(ev) ~= "table" or not ev.hook_event_name then
    return false
  end
  local s = get_session(ev)
  local h = handlers[ev.hook_event_name]
  if h then
    h(s, ev)
  end
  M.version = M.version + 1
  return true
end

--- Drop ended sessions older than `ttl` seconds and (optionally) all done ones.
function M.prune(ttl, drop_done)
  local t = now()
  local keep = {}
  for _, id in ipairs(M.order) do
    local s = M.sessions[id]
    local dead = (s.status == "ended" and (t - (s.ended or t)) > ttl) or (drop_done and s.status == "done")
    if dead then
      M.sessions[id] = nil
    else
      table.insert(keep, id)
    end
  end
  M.order = keep
  M.version = M.version + 1
end

function M.reset()
  M.sessions, M.order = {}, {}
  M.version = M.version + 1
end

function M.counts()
  local c = { working = 0, waiting = 0, done = 0, error = 0 }
  for _, s in pairs(M.sessions) do
    if c[s.status] then
      c[s.status] = c[s.status] + 1
    end
  end
  return c
end

return M
