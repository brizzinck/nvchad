-- agentdash.ui: sidebar rendering the sessions tree + buffer-local actions.
local store = require "agentdash.store"
local M = {}

M.buf = nil
M.win = nil
M.filter_cwd = false
M.line_map = {} -- line number -> { kind=, session=, file=, subagent=, task= }

local ICON = { working = "🤖", waiting = "💬", done = "✅", error = "❌", idle = "💤", ended = "⏹" }

local function fmt_dur(secs)
  if not secs or secs < 0 then
    return ""
  end
  if secs < 60 then
    return string.format("%ds", secs)
  end
  if secs < 3600 then
    return string.format("%dm%02ds", math.floor(secs / 60), secs % 60)
  end
  return string.format("%dh%02dm", math.floor(secs / 3600), math.floor(secs % 3600 / 60))
end

local function shorten(path)
  if not path then
    return ""
  end
  return (path:gsub("^" .. vim.pesc(vim.env.HOME), "~"))
end

local function rel(path, cwd)
  if cwd and cwd ~= "" and path:sub(1, #cwd) == cwd then
    return path:sub(#cwd + 2)
  end
  return shorten(path)
end

local function pane_label(s)
  if not s.tmux_pane then
    return ""
  end
  return "  [" .. s.tmux_pane .. "]"
end

function M.render_lines()
  local lines, map = {}, {}
  local cwd = vim.fn.getcwd()
  local now = os.time()
  local function add(text, meta)
    table.insert(lines, text)
    map[#lines] = meta
  end

  local c = store.counts()
  add(string.format(" agentdash  🤖%d 💬%d ✅%d %s", c.working, c.waiting, c.done, M.filter_cwd and "[cwd]" or ""), { kind = "header" })
  add("", {})

  local shown = 0
  for _, id in ipairs(store.order) do
    local s = store.sessions[id]
    if s and (not M.filter_cwd or s.cwd == cwd or cwd:sub(1, #s.cwd) == s.cwd) then
      shown = shown + 1
      local elapsed = (s.status == "working" or s.status == "waiting") and (now - (s.turn_started or s.started)) or ((s.turn_ended or s.last_event) - (s.turn_started or s.started))
      add(
        string.format("%s %s %-7s %s  %s%s", s.expanded and "▾" or "▸", ICON[s.status] or "•", s.agent, shorten(s.cwd), fmt_dur(elapsed), pane_label(s)),
        { kind = "session", session = s }
      )
      if s.expanded then
        if s.status == "waiting" and s.waiting_on then
          add("    ⏳ " .. s.waiting_on, { kind = "session", session = s })
        end
        if s.prompt then
          local p = s.prompt:gsub("\n.*", "")
          add("    ❯ " .. (#p > 70 and (p:sub(1, 67) .. "...") or p), { kind = "session", session = s })
        end
        if #s.tasks_order > 0 then
          local done = 0
          for _, tid in ipairs(s.tasks_order) do
            if s.tasks[tid].status ~= "pending" then
              done = done + 1
            end
          end
          add(string.format("    ├ tasks %d/%d", done, #s.tasks_order), { kind = "session", session = s })
          for _, tid in ipairs(s.tasks_order) do
            local t = s.tasks[tid]
            add(string.format("    │   %s %s", t.status == "pending" and "○" or "✔", t.description), { kind = "task", session = s, task = t })
          end
        end
        if #s.subagents_order > 0 then
          add(string.format("    ├ agents %d", #s.subagents_order), { kind = "session", session = s })
          for _, aid in ipairs(s.subagents_order) do
            local a = s.subagents[aid]
            local dur = fmt_dur((a.ended or now) - a.started)
            add(string.format("    │   %s %-18s %s", a.status == "done" and "✔" or "●", a.type, dur), { kind = "subagent", session = s, subagent = a })
          end
        end
        if #s.files_order > 0 then
          add(string.format("    ├ files %d", #s.files_order), { kind = "session", session = s })
          for _, f in ipairs(s.files_order) do
            add("    │   " .. rel(f, s.cwd), { kind = "file", session = s, file = f })
          end
        end
        local last = s.tools[#s.tools]
        if last then
          local mark = last.ended and (last.ok and "✔" or "✖") or "…"
          add(string.format("    └ %s %s %s", mark, last.name, last.detail or ""), { kind = "session", session = s })
        end
      end
      add("", {})
    end
  end
  if shown == 0 then
    add("  no agent sessions yet", {})
    add("  run :AgentDashInstallHooks once, then start claude/codex in tmux", {})
  end
  add(" g:jump  d:diff  m:message  <CR>:fold  p:cwd filter  x:clear done  R:reread  q:close", { kind = "help" })
  return lines, map
end

function M.redraw()
  if not (M.buf and vim.api.nvim_buf_is_valid(M.buf)) then
    return
  end
  local lines, map = M.render_lines()
  M.line_map = map
  vim.bo[M.buf].modifiable = true
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.bo[M.buf].modifiable = false
end

local function meta_at_cursor()
  local l = vim.api.nvim_win_get_cursor(0)[1]
  return M.line_map[l] or {}
end

local function tmux(args)
  if vim.fn.executable "tmux" ~= 1 then
    return false
  end
  local out = vim.fn.system({ "tmux", unpack(args) })
  return vim.v.shell_error == 0, out
end

function M.jump()
  local m = meta_at_cursor()
  local s = m.session
  if not s then
    return
  end
  if s.tmux_pane then
    local ok = tmux { "select-window", "-t", s.tmux_pane }
    if ok then
      tmux { "select-pane", "-t", s.tmux_pane }
      return
    end
  end
  if vim.fn.executable "workmux" == 1 and s.cwd ~= "" then
    vim.fn.jobstart({ "workmux", "open", s.cwd }, { detach = true })
    return
  end
  vim.notify("agentdash: no tmux pane recorded for this session", vim.log.levels.WARN)
end

function M.diff()
  local m = meta_at_cursor()
  local s = m.session
  if not s then
    return
  end
  if vim.fn.exists ":CodeDiff" ~= 2 then
    pcall(vim.cmd, "Lazy load codediff.nvim")
  end
  if m.kind == "file" and m.file then
    vim.cmd("edit " .. vim.fn.fnameescape(m.file))
    vim.cmd "CodeDiff file HEAD"
  elseif s.cwd ~= "" then
    vim.cmd("CodeDiff --repo " .. vim.fn.fnameescape(s.cwd))
  else
    vim.cmd "CodeDiff"
  end
end

function M.message()
  local m = meta_at_cursor()
  local text = (m.subagent and m.subagent.last_msg) or (m.session and m.session.last_msg)
  if not text or text == "" then
    vim.notify("agentdash: no message recorded yet", vim.log.levels.INFO)
    return
  end
  local lines = vim.split(text, "\n", { plain = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  local w = math.min(100, vim.o.columns - 4)
  local h = math.min(#lines + 2, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " last assistant message ",
  })
  vim.keymap.set("n", "q", function()
    pcall(vim.api.nvim_win_close, win, true)
  end, { buffer = buf, nowait = true })
end

function M.toggle_fold()
  local m = meta_at_cursor()
  if m.session then
    m.session.expanded = not m.session.expanded
    M.redraw()
  end
end

function M.toggle_filter()
  M.filter_cwd = not M.filter_cwd
  M.redraw()
end

function M.clear_done()
  store.prune(0, true)
  M.redraw()
end

function M.reread()
  require("agentdash.tail").reread()
end

local function set_keymaps(buf)
  local function k(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true, desc = "agentdash: " .. desc })
  end
  k("g", M.jump, "jump to tmux pane")
  k("d", M.diff, "open codediff")
  k("m", M.message, "show last message")
  k("<CR>", M.toggle_fold, "fold/unfold session")
  k("p", M.toggle_filter, "filter by cwd")
  k("x", M.clear_done, "clear done sessions")
  k("R", M.reread, "reread event log")
  k("q", M.close, "close")
end

function M.open(opts)
  opts = opts or {}
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_set_current_win(M.win)
    return
  end
  if not (M.buf and vim.api.nvim_buf_is_valid(M.buf)) then
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[M.buf].buftype = "nofile"
    vim.bo[M.buf].bufhidden = "hide"
    vim.bo[M.buf].swapfile = false
    vim.bo[M.buf].filetype = "agentdash"
    vim.api.nvim_buf_set_name(M.buf, "agentdash://sessions")
    set_keymaps(M.buf)
  end
  if opts.float then
    local w = math.min(90, vim.o.columns - 4)
    local h = math.min(30, vim.o.lines - 4)
    M.win = vim.api.nvim_open_win(M.buf, true, {
      relative = "editor",
      width = w,
      height = h,
      row = math.floor((vim.o.lines - h) / 2),
      col = math.floor((vim.o.columns - w) / 2),
      style = "minimal",
      border = "rounded",
      title = " agents ",
    })
  else
    vim.cmd("botright vsplit")
    M.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(M.win, M.buf)
    vim.api.nvim_win_set_width(M.win, opts.width or 48)
    vim.wo[M.win].winfixwidth = true
  end
  vim.wo[M.win].number = false
  vim.wo[M.win].relativenumber = false
  vim.wo[M.win].signcolumn = "no"
  vim.wo[M.win].wrap = false
  vim.wo[M.win].cursorline = true
  M.redraw()
end

function M.close()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
  end
  M.win = nil
end

function M.toggle(opts)
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    M.close()
  else
    M.open(opts)
  end
end

function M.is_open()
  return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

return M
