require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
}

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.cmd "echo ''"
  end,
})
