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

-- Rounded border for every floating window that does not set its own (nvim 0.11+: hover, signature,
-- diagnostics float, vim.ui.input, plugins that honour 'winborder'). Plugins with their own border
-- option (telescope, cmp, lazy, which-key) are styled in their specs.
vim.o.winborder = "rounded"

local sev = vim.diagnostic.severity
vim.diagnostic.config {
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { current_line = true, spacing = 2, prefix = "●", source = "if_many" },
  float = { border = "rounded", source = "if_many", header = "" },
  signs = {
    text = {
      [sev.ERROR] = "\u{f057} ",
      [sev.WARN] = "\u{f071} ",
      [sev.HINT] = "\u{f0336} ",
      [sev.INFO] = "\u{f05a} ",
    },
    numhl = {
      [sev.ERROR] = "DiagnosticError",
      [sev.WARN] = "DiagnosticWarn",
    },
  },
}

-- docker-compose files get the compound filetype that docker_compose_language_service attaches to
-- (yamlls attaches to it too)
vim.filetype.add {
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    ["docker%-compose%..+%.ya?ml"] = "yaml.docker-compose",
    ["compose%..+%.ya?ml"] = "yaml.docker-compose",
  },
}

-- Per-split winbar (statusline is global, laststatus=3): file name, active split green, inactive muted
-- (WinBar / WinBarNC are defined in chadrc.lua). Skipped for floats, special buffers, the tree and the dashboard.
local winbar_skip_ft = { ["neo-tree"] = true, alpha = true, qf = true, help = true, man = true, trouble = true }
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("winbar_per_split", { clear = true }),
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.fn.win_gettype(win) ~= "" or vim.bo.buftype ~= "" or winbar_skip_ft[vim.bo.filetype] then
      vim.wo[win].winbar = ""
      return
    end
    vim.wo[win].winbar = " %<%f%{&modified ? ' ●' : ''} "
  end,
})

-- Mode-coloured cursor: shape per mode, colour via the Cursor* groups from chadrc.lua (OSC 12 in the TUI)
vim.o.guicursor = table.concat({
  "n-c-sm:block-Cursor",
  "i-ci-ve:ver25-CursorInsert",
  "v:block-CursorVisual",
  "r-cr-o:hor20-CursorReplace",
  "t:block-blinkon500-blinkoff500-TermCursor",
}, ",")

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
