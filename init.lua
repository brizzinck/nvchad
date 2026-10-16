-- palette variant (black | night) decides the base46 cache directory, see lua/palette.lua
local palette = require "palette"
vim.g.base46_cache = palette.cache_dir()
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- rebuild the variant's base46 cache when tokens.json or chadrc.lua changed (plugin configs read it during setup)
palette.ensure_cache()

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")
palette.apply()

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
  -- Cyrillic twins for the mappings that exist by now (the keymap API hook already covers the later ones)
  require("configs.langmapper").automapping()
end)
