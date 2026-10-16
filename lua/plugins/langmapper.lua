-- Normal/visual/operator-pending keys and every mapping (leader, <C-x>, <M-x>) while ua/ru is active.
-- Config and the generated layout strings: lua/configs/langmapper.lua
return {
  "Wansmer/langmapper.nvim",
  lazy = false,
  priority = 1, -- before the other plugins so its vim.keymap.set hook sees their mappings
  config = function()
    require("configs.langmapper").setup()
  end,
}
