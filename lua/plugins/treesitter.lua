return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "typescript",
        "javascript",
        "go",
        "rust",
      },
      sync_install = false,
      auto_install = true,
      ignore_install = {},
      highlight = { enable = true },
      modules = {},
    }
  end,
}
