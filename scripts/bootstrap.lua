-- Headless bootstrap, run by dotfiles/install.sh after `stow .`:
--   nvim --headless -c "luafile ~/.config/nvim/scripts/bootstrap.lua"
-- Installs plugins pinned in lazy-lock.json, Mason tools, treesitter parsers and the
-- agent hooks (agentdash + code-preview) for Claude Code / Codex. Idempotent.
local function log(msg)
  io.stdout:write("[nvim-bootstrap] " .. msg .. "\n")
  io.stdout:flush()
end

local failed = false
local function step(name, fn)
  local ok, err = pcall(fn)
  if ok then
    log(name .. " ✔")
  else
    failed = true
    log(name .. " ✖ " .. tostring(err))
  end
end

step("plugins (Lazy restore from lazy-lock.json)", function()
  vim.cmd "Lazy! restore"
end)

step("mason tools", function()
  vim.cmd "Lazy load mason.nvim"
  local reg = require "mason-registry"
  local done = false
  reg.refresh(function()
    done = true
  end)
  vim.wait(60000, function()
    return done
  end, 100)

  local want = require("plugins.mason").opts.ensure_installed
  for _, name in ipairs(want) do
    local ok, pkg = pcall(reg.get_package, name)
    if not ok then
      log("  skip unknown mason package: " .. name)
    elseif pkg:is_installed() then
      log("  " .. name .. " already installed")
    else
      log("  installing " .. name)
      pkg:install()
      vim.wait(600000, function()
        return pkg:is_installed()
      end, 500)
      if not pkg:is_installed() then
        error("timeout installing " .. name)
      end
    end
  end
end)

step("treesitter parsers", function()
  vim.cmd "Lazy load nvim-treesitter"
  local ts = require "nvim-treesitter"
  local spec = require "plugins.treesitter"
  local langs = {}
  -- our spec passes ensure_installed to setup(); collect it from the file
  local src = io.open(vim.fn.stdpath "config" .. "/lua/plugins/treesitter.lua"):read "*a"
  for lang in src:gmatch '"([%w_]+)",' do
    table.insert(langs, lang)
  end
  local task = ts.install(langs)
  if task and task.wait then
    task:wait(600000)
  end
end)

step("agent hooks (agentdash + code-preview → Claude Code / Codex)", function()
  require("agentdash.install").run()
end)

vim.wait(500)
log(failed and "finished with errors" or "all done")
vim.cmd(failed and "cquit 1" or "qa!")
