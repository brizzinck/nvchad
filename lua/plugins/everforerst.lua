return {
  "neanias/everforest-nvim",
  version = false,
  lazy = true,
  priority = 1000,
  config = function()
    require("everforest").setup {
      background = "hard",
      transparent_background_level = 2,
      italics = false,
      disable_italic_comments = false,
      sign_column_background = "none",
      ui_contrast = "low",
    }
    require("everforest").load()
  end,
}
