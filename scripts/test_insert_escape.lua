-- Isolated native mappings/input test; no plugin bootstrap or user buffers.
local root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
vim.opt.rtp:prepend(root)
package.preload["nvchad.mappings"] = function() return {} end
package.preload["which-key"] = function() return { add = function() end } end
local pair = string.rep(vim.fn.nr2char(0x043e), 2)
local counts = {}
local set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  if mode == "i" and (lhs == "jj" or lhs == pair) then counts[lhs] = (counts[lhs] or 0) + 1 end
  return set(mode, lhs, rhs, opts)
end
require "mappings"
vim.keymap.set = set
assert(counts.jj == 1 and counts[pair] == 1, "US and shared UA/RU Escape pairs must each be installed once")
for _, lhs in ipairs { "jj", pair } do
  assert(vim.fn.maparg(lhs, "i") == "<Esc>", "Escape mapping missing")
  assert(vim.fn.maparg(lhs, "n") == "" and vim.fn.maparg(lhs, "c") == "", "Escape pair leaked outside Insert")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_feedkeys("i" .. lhs, "xt", false)
  assert(vim.api.nvim_get_current_line() == "", "Escape pair was inserted literally")
  assert(vim.api.nvim_get_mode().mode == "n", "Escape pair did not leave Insert")
end
for _, text in ipairs { "j", vim.fn.nr2char(0x043e), "hello" } do
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  local keys = vim.api.nvim_replace_termcodes("i" .. text .. "<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "xt", false)
  assert(vim.api.nvim_get_current_line() == text, "Ordinary Insert text changed")
end
print("ok: native jj and generated UA/RU Escape pair, deduplicated and Insert-only; ordinary typing unchanged")
