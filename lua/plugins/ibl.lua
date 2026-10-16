return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = false,
  priority = 1000,
  config = function()
    -- quiet rails (the old #5f875f was as loud as comments); the current scope is one step brighter
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#141a17", nocombine = true })
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#3a4440", nocombine = true })

    require("ibl").setup {
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
      scope = { enabled = true, highlight = "IblScope", show_start = false, show_end = false },
    }
  end,
}
