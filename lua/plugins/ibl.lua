return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = false,
  priority = 1000,
  config = function()
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#5f875f", nocombine = true })

    require("ibl").setup {
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
    }
  end,
}
