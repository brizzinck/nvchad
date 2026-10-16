-- ua/ru support for normal/visual/operator-pending mode.
--   langmap      built-in commands (dd, ciw, <C-w>, g-prefixes) — set from the generated layout data
--   langmapper   every vim.keymap.set mapping (leader, <C-x>, <M-x>, plugin keys): it hooks the keymap API and
--                registers Cyrillic twins; init.lua calls automapping() once all mappings exist (built-ins too)
-- The data (langmap string and layout strings) is generated from ~/.config/layout/keymap.tsv by
-- ~/.config/layout/layout.py into lua/configs/layout_data.lua. Insert mode is never remapped, so typing works.
local M = {}

function M.setup()
  local data = require "configs.layout_data"
  vim.o.langmap = data.langmap
  require("langmapper").setup {
    map_all_ctrl = true,
    default_layout = data.default_layout,
    layouts = {
      ua = { id = "ua", layout = data.layouts.ua },
      ru = { id = "ru", layout = data.layouts.ru },
    },
    -- keep which-key / :map readable: the twins are marked "LM" and which-key filters them out (plugins/whichkey.lua)
  }
end

function M.automapping()
  require("langmapper").automapping { global = true, buffer = true }
end

return M
