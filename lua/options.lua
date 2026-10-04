require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.undolevels = 300
vim.opt.synmaxcol = 300

-- Big files: treesitter + cmp buffer source + ibl + undo on a 50 MB log/JSON easily pushes nvim past 1 GB.
local BIGFILE = 1.5 * 1024 * 1024
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
  callback = function(a)
    local st = vim.uv.fs_stat(a.match)
    if not (st and st.size > BIGFILE) then
      return
    end
    vim.b[a.buf].bigfile = true
    vim.bo[a.buf].undolevels = -1
    vim.bo[a.buf].swapfile = false
    vim.bo[a.buf].undofile = false
    vim.wo.foldmethod = "manual"
    vim.wo.spell = false
    vim.api.nvim_create_autocmd("FileType", {
      buffer = a.buf,
      once = true,
      callback = function()
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(a.buf) then
            pcall(vim.treesitter.stop, a.buf)
            vim.bo[a.buf].syntax = "off"
            pcall(vim.cmd, "IBLDisable")
          end
        end)
      end,
    })
  end,
})

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "md" },
  callback = function()
    local opt = vim.opt_local
    opt.wrap = true
    opt.breakindent = true
    opt.conceallevel = 2
    opt.textwidth = 0
    opt.wrapmargin = 0
    opt.linebreak = true
    opt.breakat = " \t;,!?"

    vim.keymap.set("n", "<leader>mw", function()
      local w = vim.opt_local.wrap:get()
      vim.opt_local.wrap = not w
      vim.notify("Markdown wrap: " .. (not w and "ON" or "OFF"))
    end, { buffer = true, desc = "Toggle markdown wrap" })
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
--
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy "+",
--     ["*"] = require("vim.ui.clipboard.osc52").copy "*",
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste "+",
--     ["*"] = require("vim.ui.clipboard.osc52").paste "*",
--   },
-- }
--
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
