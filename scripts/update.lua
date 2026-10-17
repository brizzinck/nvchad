-- Headless update, run by `sysup` (dotfiles ~/.local/bin/sysup):
--   nvim --headless -c "luafile ~/.config/nvim/scripts/update.lua"
-- Updates the lazy plugins (the lockfile lazy-lock.json moves; sysup commits it right after), the installed Mason
-- packages and the treesitter parsers. `Lazy! update` only updates and never cleans (unlike `Lazy sync`).
-- NVIM_UPDATE_DRY=1 only reports which Mason packages have a new version and changes nothing.
local function log(msg)
  io.stdout:write("[nvim-update] " .. msg .. "\n")
  io.stdout:flush()
end

local dry = vim.env.NVIM_UPDATE_DRY == "1"
local failed = false
local function step(name, fn)
  local ok, err = pcall(fn)
  if ok then
    log(name .. " ok")
  else
    failed = true
    log(name .. " FAILED " .. tostring(err))
  end
end

step("lazy plugins", function()
  if dry then
    log("  dry run: skipped")
    return
  end
  vim.cmd "Lazy! update"
end)

step("mason packages", function()
  vim.cmd "Lazy load mason.nvim"
  local reg = require "mason-registry"
  local done = false
  reg.refresh(function()
    done = true
  end)
  vim.wait(60000, function()
    return done
  end, 100)
  -- Mason 2: the registry holds the latest version; a package is outdated when the installed version differs
  for _, pkg in ipairs(reg.get_installed_packages()) do
    local installed = pkg:get_installed_version()
    local latest = pkg:get_latest_version()
    if installed and latest and installed ~= latest then
      log("  " .. pkg.name .. ": " .. installed .. " -> " .. latest)
      if not dry then
        -- wait for the handle to close (is_installed() turns true before the package is set up)
        local handle = pkg:install()
        vim.wait(600000, function()
          return handle:is_closed()
        end, 500)
        if not pkg:is_installed() then
          error("failed or timed out updating " .. pkg.name)
        end
      end
    end
  end
end)

step("treesitter parsers", function()
  if dry then
    log("  dry run: skipped")
    return
  end
  vim.cmd "Lazy load nvim-treesitter"
  local task = require("nvim-treesitter").update()
  if task and task.wait then
    task:wait(600000)
  end
end)

vim.wait(500)
log(failed and "finished with errors" or "all done")
vim.cmd(failed and "cquit 1" or "qa!")
