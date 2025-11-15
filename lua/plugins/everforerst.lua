-- in your plugins/init.lua or a dedicated theme file
return {
  "neanias/everforest-nvim",
  version = false, -- or specify a version like 'v2.0'
  lazy = true,
  priority = 1000, -- Ensures it loads early
  config = function()
    require("everforest").setup {
      -- Your configuration options here
      background = "hard", -- Options: 'soft', 'medium', 'hard'
      transparent_background_level = 0, -- 0-2, higher means more transparent UI
      italics = false, -- Whether to use italics for keywords
      disable_italic_comments = false, -- Set to true to disable italics for comments
      sign_column_background = "none", -- Options: 'none', 'grey'
      ui_contrast = "low", -- Options: 'high', 'low'
    }
    require("everforest").load() -- Load the color scheme
  end,
}
