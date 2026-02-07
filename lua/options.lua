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

local original_close = vim.api.nvim_win_close
vim.api.nvim_win_close = function(winid, force)
  pcall(original_close, winid, force)
end

-- vim.g.clipboard = {
--   name = "osc52",
--   copy = {
--     ["+"] = function(lines, _)
--       require("osc52").copy(table.concat(lines, "\n"))
--     end,
--     ["*"] = function(lines, _)
--       require("osc52").copy(table.concat(lines, "\n"))
--     end,
--   },
--   paste = {
--     ["+"] = function()
--       local content = vim.fn.getreg "+"
--       return vim.split(content, "\n"), "l"
--     end,
--     ["*"] = function()
--       local content = vim.fn.getreg "*"
--       return vim.split(content, "\n"), "l"
--     end,
--   },
-- }
--
-- vim.keymap.set("n", "p", function()
--   local clip = require("osc52_paste").read_clipboard()
--   if clip ~= "" then
--     vim.api.nvim_put({ clip }, "c", true, true)
--   end
-- end, { desc = "Paste from local clipboard via OSC52" })
