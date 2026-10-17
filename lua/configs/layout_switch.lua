-- Automatic keyboard layout switching (Hyprland): NORMAL mode and the `:` line always get layout 0 (us), text entry
-- gets back the layout the buffer was last typed in. langmap + langmapper (configs/langmapper.lua) stay as the
-- fallback, they make NORMAL commands work on Cyrillic, this module makes `:cmd`, f/t/r targets and `/` usable.
--
--   InsertLeave           remember the active layout for the buffer, switch to us
--   InsertEnter           (insert, replace, c/s/o commands) restore the buffer's layout if the keyboard is on us
--   CmdlineEnter ':'      us (covers Caps pressed in NORMAL)
--   CmdlineEnter '/' '?'  the buffer's insert layout, so Cyrillic text can be searched; CmdlineLeave: back to us
--   terminal buffers      no switching at all (the program inside owns the keyboard); only a `:` line gets us for its
--                         duration and the old layout back afterwards
--   FocusLost             Hyprland keeps ONE layout for every window: when the terminal window really loses focus
--                         (another app, not a tmux pane/window of the same terminal) and nvim had forced us in NORMAL,
--                         the layout it displaced is put back, so the next app is not left on us
--   FocusGained           NORMAL mode on another layout (coming back from an app) -> us again, the layout is kept for
--                         the next FocusLost
--   VimLeave              nothing: the shell prompt after :q wants us anyway
-- A buffer that was never typed in keeps whatever layout is active (code buffers stay us). A keyboard that is already
-- on a non-us layout when text entry starts is left alone: the owner picked it with Caps.
--
-- hyprctl runs asynchronously through one queue (never blocks typing, calls happen in event order). The Hyprland
-- instance is not taken on trust: tmux outlives Hyprland restarts, so $HYPRLAND_INSTANCE_SIGNATURE can be stale. The
-- cached signature is tried first, on failure the live instances (`hyprctl instances -j`, then the directories in
-- $XDG_RUNTIME_DIR/hypr, newest first) are probed with a real `devices` call and the first that answers is cached.
-- Without a reachable instance nothing is run, silently (retry after a cooldown). Off: SSH, TTY, no hyprctl, a hypr
-- runtime dir of another user, vim.g.layout_autoswitch = false (:LayoutAutoswitch on|off|toggle, <leader>uk).
local M = {}

local COOLDOWN_MS = 30000 -- after a failed resolve: no hyprctl at all for this long
local TIMEOUT_MS = 1500

local uv = vim.uv
local sig -- cached instance signature
local dead_until = 0
local queue, running = {}, false
local forced_from -- layout (index) nvim displaced with us in NORMAL, nil = nothing to give back
local term_class -- Hyprland class of the window nvim's terminal lives in (set on focus events)

local function now()
  return uv.now()
end

-- Local graphical session of the owner with a usable hyprctl (checked once in setup).
local function env_ok()
  if vim.env.SSH_CONNECTION or vim.env.SSH_TTY or vim.fn.has "linux" == 0 or vim.fn.executable "hyprctl" == 0 then
    return false
  end
  local run = vim.env.XDG_RUNTIME_DIR
  if not run or run == "" then
    return false
  end
  local st = uv.fs_stat(run .. "/hypr")
  return st ~= nil and st.type == "directory" and st.uid == uv.getuid()
end

local available = false

-- the dynamic switch: vim.g.layout_autoswitch = false / :LayoutAutoswitch off
local function capable()
  return available and vim.g.layout_autoswitch ~= false
end

local function json(s)
  local ok, v = pcall(vim.json.decode, s or "")
  return ok and v or nil
end

-- hyprctl against one instance; cb(ok, stdout)
local function hypr(instance, args, cb)
  local cmd = { "hyprctl", "-i", instance }
  vim.list_extend(cmd, args)
  local ok = pcall(vim.system, cmd, { text = true, timeout = TIMEOUT_MS }, function(r)
    vim.schedule(function()
      cb(r.code == 0, r.stdout)
    end)
  end)
  if not ok then
    vim.schedule(function()
      cb(false, "")
    end)
  end
end

local function main_keyboard(devices)
  local kbs = devices and devices.keyboards
  if type(kbs) ~= "table" or #kbs == 0 then
    return nil
  end
  for _, k in ipairs(kbs) do
    if k.main then
      return k
    end
  end
  return kbs[1]
end

local function candidates(cb)
  local list = {}
  local function add(s)
    if s and s ~= "" and not vim.tbl_contains(list, s) then
      table.insert(list, s)
    end
  end
  add(vim.env.HYPRLAND_INSTANCE_SIGNATURE)
  local function from_dirs()
    local dir = vim.env.XDG_RUNTIME_DIR .. "/hypr"
    local found = {}
    local h = uv.fs_scandir(dir)
    while h do
      local name, t = uv.fs_scandir_next(h)
      if not name then
        break
      end
      local st = (t == "directory" or t == nil) and uv.fs_stat(dir .. "/" .. name .. "/.socket.sock")
      if st then
        table.insert(found, { name = name, mtime = st.mtime.sec })
      end
    end
    table.sort(found, function(a, b)
      return a.mtime > b.mtime
    end)
    for _, f in ipairs(found) do
      add(f.name)
    end
  end
  -- hyprctl itself knows the live instances (newest first by start time); the directory scan is the fallback
  local ok = pcall(vim.system, { "hyprctl", "instances", "-j" }, { text = true, timeout = TIMEOUT_MS }, function(r)
    vim.schedule(function()
      local inst = r.code == 0 and json(r.stdout) or nil
      if type(inst) == "table" then
        table.sort(inst, function(a, b)
          return (a.time or 0) > (b.time or 0)
        end)
        for _, i in ipairs(inst) do
          add(i.instance)
        end
      end
      from_dirs()
      cb(list)
    end)
  end)
  if not ok then
    vim.schedule(function()
      from_dirs()
      cb(list)
    end)
  end
end

-- First instance that answers a real `devices` call becomes the cached one; cb(devices | nil).
local function resolve(cb)
  candidates(function(list)
    local i = 0
    local function try()
      i = i + 1
      if i > #list then
        sig = nil
        dead_until = now() + COOLDOWN_MS
        return cb(nil)
      end
      hypr(list[i], { "-j", "devices" }, function(ok, out)
        local dev = ok and json(out) or nil
        if main_keyboard(dev) then
          sig = list[i]
          return cb(dev)
        end
        try()
      end)
    end
    try()
  end)
end

-- devices -j through the cached signature, re-resolving once when it does not answer; cb(devices | nil)
local function devices(cb)
  if now() < dead_until then
    return cb(nil)
  end
  local function fresh()
    resolve(cb)
  end
  if not sig then
    return fresh()
  end
  hypr(sig, { "-j", "devices" }, function(ok, out)
    local dev = ok and json(out) or nil
    if main_keyboard(dev) then
      return cb(dev)
    end
    fresh()
  end)
end

local function switch(idx, cb)
  hypr(sig, { "switchxkblayout", "all", tostring(idx) }, function(ok)
    if not ok then
      sig = nil -- stale: next request re-resolves
    end
    cb()
  end)
end

-- The queue keeps hyprctl calls strictly in event order; a job is function(done).
local function pump()
  if running then
    return
  end
  local job = table.remove(queue, 1)
  if not job then
    return
  end
  running = true
  local ok = pcall(job, function()
    running = false
    pump()
  end)
  if not ok then
    running = false
    pump()
  end
end

-- Query the active layout of the main keyboard, then decide: decide(cur, nlayouts) returns the layout to switch to
-- (nil = leave it). Nothing is switched when the keyboard is already there.
local function request(decide)
  if not capable() then
    return
  end
  table.insert(queue, function(done)
    devices(function(dev)
      local kb = main_keyboard(dev)
      if not kb or type(kb.active_layout_index) ~= "number" then
        return done()
      end
      local n = #vim.split(kb.layout or "", ",", { plain = true })
      local cur = kb.active_layout_index
      local target = decide(cur, n)
      if target and target ~= cur and target >= 0 and target < n then
        switch(target, done)
      else
        done()
      end
    end)
  end)
  pump()
end

local function normal_like()
  local m = vim.api.nvim_get_mode().mode
  return m:sub(1, 1) == "n" or m == "v" or m == "V" or m == "\22" or m:sub(1, 1) == "s" or m == "S"
end

local function is_term(buf)
  return vim.bo[buf].buftype == "terminal"
end

-- Switch to us; `after(cur)` sees the layout that was active.
local function to_us(after)
  request(function(cur)
    if after then
      after(cur)
    end
    return 0
  end)
end

-- Switch to the buffer's remembered layout, but only from us (a layout picked by hand is respected).
local function to_buffer_layout(buf, after)
  request(function(cur)
    local r = vim.b[buf].layout_insert
    if after then
      after(cur)
    end
    if cur == 0 and type(r) == "number" and r ~= 0 then
      return r
    end
  end)
end

function M.setup()
  available = env_ok()
  local g = vim.api.nvim_create_augroup("layout_switch", { clear = true })
  local function au(ev, cb, opts)
    vim.api.nvim_create_autocmd(ev, vim.tbl_extend("force", { group = g, callback = cb }, opts or {}))
  end

  au("InsertLeave", function(a)
    if is_term(a.buf) then
      return
    end
    to_us(function(cur)
      if vim.api.nvim_buf_is_valid(a.buf) then
        vim.b[a.buf].layout_insert = cur
      end
      forced_from = cur ~= 0 and cur or nil
    end)
  end)

  au("InsertEnter", function(a)
    if is_term(a.buf) then
      return
    end
    to_buffer_layout(a.buf, function()
      forced_from = nil
    end)
  end)

  local term_restore -- layout to give back after a `:` line typed in a terminal buffer
  au("CmdlineEnter", function(a)
    local t = a.match
    local buf = a.buf
    if t == ":" then
      to_us(function(cur)
        if is_term(buf) then
          term_restore = cur ~= 0 and cur or nil
        elseif cur ~= 0 then
          forced_from = cur
        end
      end)
    elseif (t == "/" or t == "?") and not is_term(buf) then
      to_buffer_layout(buf)
    end
  end)

  au("CmdlineLeave", function(a)
    local t = a.match
    if t == ":" and term_restore then
      local r = term_restore
      term_restore = nil
      request(function(cur)
        if cur == 0 then
          return r
        end
      end)
    elseif (t == "/" or t == "?") and not is_term(a.buf) then
      to_us(function(cur)
        if cur ~= 0 then
          forced_from = cur
        end
      end)
    end
  end)

  -- Window of this terminal: remembered on focus events so FocusLost can tell "another app" from "another tmux pane".
  local function active_class(cb)
    if not capable() then
      return
    end
    table.insert(queue, function(done)
      local function ask()
        hypr(sig, { "-j", "activewindow" }, function(ok, out)
          local w = ok and json(out) or nil
          cb(type(w) == "table" and w.class or "")
          done()
        end)
      end
      if sig and now() >= dead_until then
        return ask()
      end
      devices(function(dev)
        if dev then
          ask()
        else
          done()
        end
      end)
    end)
    pump()
  end

  au("FocusGained", function()
    if not capable() then
      return
    end
    active_class(function(c)
      if c and c ~= "" then
        term_class = c
      end
    end)
    if normal_like() and not is_term(vim.api.nvim_get_current_buf()) then
      request(function(cur)
        forced_from = cur ~= 0 and cur or nil
        return 0
      end)
    end
  end)

  au("FocusLost", function()
    if not forced_from or not normal_like() or is_term(vim.api.nvim_get_current_buf()) or not term_class then
      return
    end
    local back = forced_from
    -- the class check runs in the queue, after the compositor moved focus
    active_class(function(c)
      if c == term_class then
        return -- same terminal app: a tmux pane/window or another terminal window, stay on us
      end
      request(function(cur)
        if cur == 0 then
          return back
        end
      end)
    end)
  end)

  -- window class of the starting terminal, for a FocusLost before any FocusGained
  vim.schedule(function()
    active_class(function(c)
      if c and c ~= "" and not term_class then
        term_class = c
      end
    end)
  end)

  vim.api.nvim_create_user_command("LayoutAutoswitch", function(o)
    if not available then
      return vim.notify("Layout autoswitch: no local Hyprland session", vim.log.levels.WARN)
    end
    local arg = o.args == "" and "toggle" or o.args
    local on
    if arg == "toggle" then
      on = vim.g.layout_autoswitch == false
    elseif arg == "on" then
      on = true
    elseif arg == "off" then
      on = false
    else
      return vim.notify("LayoutAutoswitch: on | off | toggle", vim.log.levels.WARN)
    end
    vim.g.layout_autoswitch = on
    forced_from = nil
    vim.notify("Layout autoswitch: " .. (on and "on" or "off"))
  end, {
    nargs = "?",
    complete = function()
      return { "on", "off", "toggle" }
    end,
    desc = "Automatic keyboard layout switching (on|off|toggle)",
  })
end

return M
