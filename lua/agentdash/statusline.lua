-- agentdash.statusline: compact agent counters for the NvChad statusline.
-- Glyphs and colours match the tmux window badges (workmux status_icons):
--   working md-robot (yellow), waiting md-message (orange), done fa-check (green), error fa-times (red).
local M = {}

local GLYPH = {
  working = "\u{f06a9}",
  waiting = "\u{f0361}",
  done = "\u{f00c}",
  error = "\u{f00d}",
}

local HL = {
  working = "%#St_AgentWorking#",
  waiting = "%#St_AgentWaiting#",
  done = "%#St_AgentDone#",
  error = "%#St_AgentError#",
}

function M.render()
  local ok, store = pcall(require, "agentdash.store")
  if not ok then
    return ""
  end
  local c = store.counts()
  if c.working + c.waiting + c.done + c.error == 0 then
    return ""
  end
  local parts = {}
  for _, state in ipairs { "working", "waiting", "done", "error" } do
    if c[state] > 0 then
      parts[#parts + 1] = HL[state] .. GLYPH[state] .. " " .. c[state]
    end
  end
  return " " .. table.concat(parts, " ") .. " "
end

return M
