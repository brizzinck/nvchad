-- agentdash.statusline: compact "🤖2 💬1 ✅1" segment for the NvChad statusline.
local M = {}

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
  if c.working > 0 then
    table.insert(parts, "🤖" .. c.working)
  end
  if c.waiting > 0 then
    table.insert(parts, "💬" .. c.waiting)
  end
  if c.done > 0 then
    table.insert(parts, "✅" .. c.done)
  end
  if c.error > 0 then
    table.insert(parts, "❌" .. c.error)
  end
  local hl = c.waiting > 0 and "%#St_LspWarning#" or "%#St_LspHints#"
  return hl .. " " .. table.concat(parts, " ") .. " "
end

return M
