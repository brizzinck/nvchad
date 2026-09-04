-- agentdash.tail: follow events.jsonl with fs_poll and feed store.
local store = require "agentdash.store"
local M = {}

local uv = vim.uv
local offset = 0
local partial = ""
local poll
local listeners = {}
local pending = false

function M.path()
  local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
  return state .. "/agentdash/events.jsonl"
end

function M.on_change(fn)
  table.insert(listeners, fn)
end

local function notify()
  if pending then
    return
  end
  pending = true
  vim.defer_fn(function()
    pending = false
    for _, fn in ipairs(listeners) do
      pcall(fn)
    end
  end, 200)
end

local function read_new(from_start)
  local path = M.path()
  local st = uv.fs_stat(path)
  if not st then
    return
  end
  if from_start then
    offset, partial = 0, ""
  end
  if st.size < offset then -- truncated/rotated
    offset, partial = 0, ""
  end
  if st.size == offset then
    return
  end
  local fd = uv.fs_open(path, "r", 438)
  if not fd then
    return
  end
  local data = uv.fs_read(fd, st.size - offset, offset)
  uv.fs_close(fd)
  if not data then
    return
  end
  offset = st.size
  data = partial .. data
  local changed = false
  local last_nl = data:match ".*()\n"
  if not last_nl then
    partial = data
    return
  end
  partial = data:sub(last_nl + 1)
  for line in data:sub(1, last_nl):gmatch "([^\n]*)\n" do
    if line ~= "" then
      local ok, ev = pcall(vim.json.decode, line)
      if ok and store.apply(ev) then
        changed = true
      end
    end
  end
  if changed then
    notify()
  end
end

--- Read existing history (bounded), then start polling.
function M.start(opts)
  opts = opts or {}
  if poll then
    return
  end
  local path = M.path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  -- replay only the tail of the log so restarts don't rebuild months of history
  local st = uv.fs_stat(path)
  local replay = opts.replay_bytes or 512 * 1024
  offset = (st and st.size > replay) and (st.size - replay) or 0
  if offset > 0 then
    -- skip the (probably partial) first line
    local fd = uv.fs_open(path, "r", 438)
    if fd then
      local chunk = uv.fs_read(fd, 4096, offset) or ""
      uv.fs_close(fd)
      local nl = chunk:find "\n"
      if nl then
        offset = offset + nl
      end
    end
  end
  read_new(false)
  poll = uv.new_fs_poll()
  poll:start(path, opts.interval or 500, function()
    vim.schedule(function()
      read_new(false)
    end)
  end)
end

function M.stop()
  if poll then
    poll:stop()
    poll:close()
    poll = nil
  end
end

function M.reread()
  store.reset()
  read_new(true)
  notify()
end

return M
