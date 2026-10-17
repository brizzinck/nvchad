-- Everforest palette tokens for nvim (variants "black" and "night", see ~/dotfiles/themes/palette).
--
-- Tokens come from the generated tokens.json of the active variant, first hit wins:
--   $EF_THEME_DIR/tokens.json                     (override, used by headless checks)
--   ~/.local/state/theme/current/tokens.json      (symlink flipped by the `theme` command)
--   <dotfiles>/themes/generated/black/tokens.json (this config lives in <dotfiles>/.config/nvim)
-- When none exists, get() returns nil and chadrc.lua falls back to stock base46 everforest.
--
-- base46 compiles highlights into a cache. Each variant has its own cache directory, so switching variants
-- never leaves a stale cache behind; the cache is rebuilt when tokens.json or chadrc.lua change (fingerprint).
local M = {}

local uv = vim.uv or vim.loop
local state = { loaded = false, data = nil, path = nil, raw = nil }

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read "*a"
  f:close()
  return s
end

local function candidates()
  local list = {}
  local override = vim.env.EF_THEME_DIR
  if override and override ~= "" then
    list[#list + 1] = override .. "/tokens.json"
  end
  local state_home = vim.env.XDG_STATE_HOME
  if not state_home or state_home == "" then
    state_home = (vim.env.HOME or "") .. "/.local/state"
  end
  list[#list + 1] = state_home .. "/theme/current/tokens.json"
  local real = uv.fs_realpath(vim.fn.stdpath "config")
  if real then
    list[#list + 1] = vim.fs.dirname(vim.fs.dirname(real)) .. "/themes/generated/black/tokens.json"
  end
  return list
end

local function load()
  if state.loaded then
    return
  end
  state.loaded = true
  for _, path in ipairs(candidates()) do
    local raw = read(path)
    if raw then
      local ok, data = pcall(vim.json.decode, raw)
      if ok and type(data) == "table" and data.tokens and data.ansi then
        state.data, state.path, state.raw = data, path, raw
        return
      end
    end
  end
end

--- Tokens table ({ variant, title, tokens = { bg = "#..", ... }, ansi = { 16 hex } }) or nil.
function M.get()
  load()
  return state.data
end

--- Forget the cached tokens so the next get() re-reads the active variant.
function M.reset()
  state = { loaded = false, data = nil, path = nil, raw = nil }
end

--- base46 cache directory prefix for the active variant (trailing slash: base46 appends file names).
function M.cache_dir()
  local data = M.get()
  local name = data and data.variant or "default"
  return vim.fn.stdpath "data" .. "/base46_" .. name .. "/"
end

local function fingerprint()
  local chadrc = read(vim.fn.stdpath "config" .. "/lua/chadrc.lua") or ""
  return vim.fn.sha256((state.raw or "") .. chadrc)
end

--- Rebuild the base46 cache when tokens.json or chadrc.lua changed since it was compiled.
--- Called from init.lua before lazy.setup: plugin configs dofile() cache files while lazy loads them, so the
--- cache must be complete by then. base46 and ui are plain lazy.nvim plugin directories; they are put on the
--- runtimepath only for the compile and removed again afterwards.
function M.ensure_cache()
  load()
  local dir = M.cache_dir()
  local stamp = dir .. ".stamp"
  local want = fingerprint()
  if read(stamp) == want and uv.fs_stat(dir .. "defaults") then
    return
  end
  local lazy_dir = require("shared").lazy_root() .. "/"
  if not (uv.fs_stat(lazy_dir .. "base46") and uv.fs_stat(lazy_dir .. "ui")) then
    return -- fresh machine: the NvChad build hook compiles the cache once the plugins are installed
  end
  local added = {}
  for _, name in ipairs { "base46", "ui" } do
    vim.opt.rtp:prepend(lazy_dir .. name)
    added[#added + 1] = lazy_dir .. name
  end
  local ok, err = pcall(function()
    require("base46").compile()
    local f = assert(io.open(stamp, "w"))
    f:write(want)
    f:close()
  end)
  for _, path in ipairs(added) do
    vim.opt.rtp:remove(path)
  end
  for name in pairs(package.loaded) do
    if name:match "^base46" or name == "nvconfig" or name == "chadrc" then
      package.loaded[name] = nil
    end
  end
  if not ok then
    vim.schedule(function()
      vim.notify("palette: base46 cache rebuild failed: " .. tostring(err), vim.log.levels.WARN)
    end)
  end
end

--- Things base46 does not own: :terminal ANSI colours, indent rails.
function M.apply()
  local data = M.get()
  if not data then
    return
  end
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = data.ansi[i + 1]
  end
  -- IblIndent / IblScope: quiet rails (line is >= 1.5:1 against bg, so ghostty never rewrites them)
  local t = data.tokens
  vim.api.nvim_set_hl(0, "IblIndent", { fg = t.line, nocombine = true })
  vim.api.nvim_set_hl(0, "IblScope", { fg = t.border, nocombine = true })
end

--- Follow the active variant at runtime (sent by `theme` through the nvim server socket). Never quits or
--- touches buffers: it only recompiles and re-applies highlights.
function M.reload()
  M.reset()
  -- base46 captures its cache path and the merged chadrc options when the module loads, and load_all_highlights
  -- compiles with the module it was called on: drop all of it so the fresh require sees the new variant
  package.loaded.chadrc = nil
  package.loaded.nvconfig = nil
  for name in pairs(package.loaded) do
    if name:match "^base46" then
      package.loaded[name] = nil
    end
  end
  vim.g.base46_cache = M.cache_dir()
  local ok, err = pcall(function()
    require("lazy").load { plugins = { "base46" } }
    require("base46").load_all_highlights()
  end)
  if not ok then
    return "base46 reload failed: " .. tostring(err)
  end
  M.apply()
  local f = io.open(M.cache_dir() .. ".stamp", "w")
  if f then
    f:write(fingerprint())
    f:close()
  end
  local data = M.get()
  return data and data.variant or "none"
end

return M
