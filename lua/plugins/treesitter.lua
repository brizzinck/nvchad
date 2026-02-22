return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "VeryLazy",
  opts = {
    ensure_installed = { "lua", "python", "go", "rust", "python", "c++", "c", "yaml", "html", "css", "javascript", "typescripta" },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
