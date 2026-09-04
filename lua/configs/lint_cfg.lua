local lint = require "lint"

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },

  python = { "pylint" },
  go = { "golangcilint" },
  rust = { "clippy" },
  c = { "cppcheck" },
  cpp = { "cppcheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})
