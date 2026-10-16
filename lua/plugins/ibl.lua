return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = false,
  priority = 1000,
  config = function()
    -- quiet rails (`line`); the current scope is one step brighter (`border`). Re-applied on every variant switch.
    require("palette").apply()

    require("ibl").setup {
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
      scope = { enabled = true, highlight = "IblScope", show_start = false, show_end = false },
    }
  end,
}
