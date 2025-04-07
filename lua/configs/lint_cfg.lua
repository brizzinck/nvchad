local lint = require "lint"

lint.linters.golangci_lint = {
  cmd = "golangci-lint",
  stdin = false,
  args = { "run", "--out-format", "line-number" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
    source = "golangci-lint",
    severity = vim.diagnostic.severity.WARN,
  }),
}

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },

  python = { "pylint" },
  go = { "golangci_lint" },
  rust = { "clippy" },
  c = { "cppcheck" },
  cpp = { "cppcheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})
