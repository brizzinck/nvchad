return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "lua-language-server",
      "stylua",

      "html-lsp",
      "css-lsp",
      "prettier",
      "eslint-lsp",

      "typescript-language-server",
      "js-debug-adapter",

      "gopls",

      "clangd",
      "clang-format",

      "pyright",
      "black",
      "pylint",

      "rust-analyzer",
      "rustfmt",
      "clippy",
    },
  },
}
