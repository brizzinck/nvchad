return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup {
      ensure_installed = {
        "bash",
        "comment",
        "css",
        "diff",
        "dockerfile",
        "elixir",
        "git_config",
        "gitcommit",
        "gitignore",
        "groovy",
        "go",
        "heex",
        "hcl",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rst",
        "rust",
        "scss",
        "ssh_config",
        "sql",
        "terraform",
        "typst",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    }

    vim.treesitter.language.register("groovy", "Jenkinsfile")

    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[0][0].foldmethod = "expr"
  end,
}
