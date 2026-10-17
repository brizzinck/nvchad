return {
  "williamboman/mason.nvim",
  opts = {
    -- packages live in the shared read-only copy for managed users (lua/shared.lua), else in stdpath("data")/mason
    install_root_dir = require("shared").mason_root(),
    ensure_installed = {
      "lua-language-server",
      "stylua",

      "html-lsp",
      "css-lsp",
      "prettier",
      "eslint-lsp",

      "typescript-language-server",
      "yaml-language-server",
      "json-lsp",
      "dockerfile-language-server",
      "docker-compose-language-service",
      "bash-language-server",
      "taplo",
      "js-debug-adapter",

      "gopls",
      "golangci-lint",
      "delve",
      "gomodifytags",
      "impl",
      "gotests",

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
