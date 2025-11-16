return {
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  config = function()
    require("osc52").setup()
  end,
}
