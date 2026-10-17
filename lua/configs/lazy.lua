local shared = require "shared"

return {
  -- plugin root and lockfile: per-user, or the shared read-only copy for managed users (lua/shared.lua)
  root = shared.lazy_root(),
  lockfile = shared.lockfile(),
  defaults = { lazy = true },
  -- Auto-reload on config edits pops a blocking "Press ENTER" prompt in every running nvim, which
  -- stops answering RPC and hangs RPC callers. Changes apply on next start instead.
  change_detection = { enabled = false, notify = false },
  install = { colorscheme = { "nvchad" } },

  ui = {
    border = "rounded",
    backdrop = 100,
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
