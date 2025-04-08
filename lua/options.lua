require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.wrap = false

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

vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*",
  callback = function(args)
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == "terminal" then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end, 5)
  end,
})
