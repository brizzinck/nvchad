require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<C-s>", "<cmd>w!<CR>", { desc = "Force Write" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Force Quit" })
map("n", "<leader>n", "<cmd>enew<CR>", { desc = "New File" })
map("n", "<leader>c", function()
  require("nvchad.tabufline").close_buf()
end, { desc = "Close Buffer" })

_G.show_diagnostic_float = function()
  vim.diagnostic.open_float(nil, {
    focusable = false,
    scope = "cursor",
    border = "rounded",
  })
end

_G.focus_diagnostic_float = function()
  vim.diagnostic.open_float(nil, {
    focusable = true,
    scope = "cursor",
    border = "rounded",
    close_events = {},
  })

  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end, 30)
end

map("n", "<leader>dk", "<cmd>lua show_diagnostic_float()<CR>", { desc = "Show Diagnostic Popup (no focus)" })
map("n", "<leader>dK", "<cmd>lua focus_diagnostic_float()<CR>", { desc = "Focus Diagnostic Popup" })

local function goto_diagnostic(direction, opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local cur_line = cur_pos[1] - 1

  local diagnostics = vim.diagnostic.get(bufnr)

  local filtered = vim.tbl_filter(function(d)
    return d.severity == opts.severity
  end, diagnostics)

  if #filtered == 0 then
    vim.notify("No diagnostics of severity: " .. opts.name, vim.log.levels.INFO)
    return
  end

  table.sort(filtered, function(a, b)
    return a.lnum < b.lnum
  end)

  local target = nil

  if direction == "next" then
    for _, d in ipairs(filtered) do
      if d.lnum > cur_line then
        target = d
        break
      end
    end
    if not target then
      target = filtered[1]
    end
  else
    for i = #filtered, 1, -1 do
      local d = filtered[i]
      if d.lnum < cur_line then
        target = d
        break
      end
    end
    if not target then
      target = filtered[#filtered]
    end
  end

  if target then
    vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col or 0 })
    vim.diagnostic.open_float(nil, { focusable = true })
  else
    vim.notify("No " .. direction .. " diagnostic of severity: " .. opts.name, vim.log.levels.INFO)
  end
end

map("n", "]e", function()
  goto_diagnostic("next", { severity = vim.diagnostic.severity.ERROR, name = "Error" })
end, { desc = "Next Error" })

map("n", "[e", function()
  goto_diagnostic("prev", { severity = vim.diagnostic.severity.ERROR, name = "Error" })
end, { desc = "Prev Error" })

map("n", "]w", function()
  goto_diagnostic("next", { severity = vim.diagnostic.severity.WARN, name = "Warning" })
end, { desc = "Next Warning" })

map("n", "[w", function()
  goto_diagnostic("prev", { severity = vim.diagnostic.severity.WARN, name = "Warning" })
end, { desc = "Prev Warning" })

map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize Up" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize Down" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize Left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize Right" })

map("n", "\\", "<cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "|", "<cmd>split<CR>", { desc = "Horizontal Split" })

map("n", "]t", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

map("i", "<C-s>", "<cmd>w!<CR><ESC>", { desc = "Force Write" })
map("i", "jj", "<ESC>", { desc = "Esc insert" })
map("i", "jk", "<ESC>", { desc = "Esc insert" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })

map("n", "<leader>cx", function()
  require("nvchad.tabufline").closeAllBufs()
end, { desc = "Close All Buffers" })

map("n", "]b", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })

map("n", ">b", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })
map("n", "<b", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })

map("n", "<leader>bc", function()
  require("nvchad.tabufline").closeOtherBufs()
end, { desc = "Close all buffers except current" })

map("n", "<leader>bC", function()
  require("nvchad.tabufline").closeAllBufs()
end, { desc = "Close all buffers" })

map("n", "<leader>e", "<cmd>Neotree toggle filesystem<CR>", { desc = "Toggle NeoTree" })
map("n", "<leader>o", "<cmd>Neotree focus filesystem<CR>", { desc = "Focus NeoTree" })

map("n", "<leader>H", "<cmd>Alpha<CR>", { desc = "Dashboard/Home" })

map("n", "<leader>Ss", "<cmd>SaveSession<CR>", { desc = "Save Session" })
map("n", "<leader>Sl", "<cmd>LoadLastSession<CR>", { desc = "Load Last Session" })
map("n", "<leader>Sd", "<cmd>DeleteSession<CR>", { desc = "Delete Session" })
map("n", "<leader>Sf", "<cmd>SearchSession<CR>", { desc = "Search Sessions" })
map("n", "<leader>S.", "<cmd>LoadCurrentDirSession<CR>", { desc = "Load CWD Session" })

map("n", "<leader>pa", "<cmd>Lazy update<CR>", { desc = "Lazy Update Packages" })
map("n", "<leader>pA", "<cmd>NvChadUpdate<CR>", { desc = "Update NVChad" })
map(
  "n",
  "<leader>pl",
  "<cmd>!git -C ~/.local/share/nvchad/ log --pretty=oneline -10<CR>",
  { desc = "NVChad Changelog (пример)" }
)
map("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Mason Installer" })
map("n", "<leader>pi", "<cmd>Lazy install<CR>", { desc = "Lazy Install" })
map("n", "<leader>ps", "<cmd>Lazy<CR>", { desc = "Lazy Status" })
map("n", "<leader>pS", "<cmd>Lazy sync<CR>", { desc = "Lazy Sync" })
map("n", "<leader>pu", "<cmd>Lazy check<CR>", { desc = "Check for plugin updates" })
map("n", "<leader>pU", "<cmd>Lazy update<CR>", { desc = "Lazy plugin update" })

map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "LSP Info" })
map("n", "<leader>lI", "<cmd>NullLsInfo<CR>", { desc = "Null-ls Info" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Document" })
map("n", "<leader>lf", function()
  vim.lsp.buf.format { async = true }
end, { desc = "Format Document" })
map("n", "<leader>lS", "<cmd>SymbolsOutline<CR>", { desc = "Symbols Outline" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>lD", "<cmd>Telescope diagnostics<CR>", { desc = "All Diagnostics" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
map("n", "<leader>lh", vim.lsp.buf.signature_help, { desc = "LSP Signature Help" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })
map("n", "<leader>lG", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Workspace Symbols" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go Declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go Definition" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Type Definition" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "Go Implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go References" })
map("n", "<leader>lR", vim.lsp.buf.references, { desc = "Go References" })

map("n", "<leader>dc", "<cmd>lua require('dap').continue()<CR>", { desc = "DAP Continue/Start" })
map("n", "<leader>dp", "<cmd>lua require('dap').pause()<CR>", { desc = "DAP Pause" })
map("n", "<leader>dr", "<cmd>lua require('dap').restart()<CR>", { desc = "DAP Restart" })
map("n", "<leader>ds", "<cmd>lua require('dap').run_to_cursor()<CR>", { desc = "DAP Run to Cursor" })
map("n", "<leader>dq", "<cmd>lua require('dap').close()<CR>", { desc = "DAP Close Session" })
map("n", "<leader>dQ", "<cmd>lua require('dap').terminate()<CR>", { desc = "DAP Terminate" })
map(
  "n",
  "<leader>dC",
  "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { desc = "Conditional Breakpoint" }
)
map("n", "<leader>dB", "<cmd>lua require('dap').clear_breakpoints()<CR>", { desc = "Clear Breakpoints" })
map("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>", { desc = "DAP Step Over" })
map("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>", { desc = "DAP Step Into" })
map("n", "<S-F11>", "<cmd>lua require('dap').step_out()<CR>", { desc = "DAP Step Out" })
map("n", "<leader>dE", "<cmd>lua require('dap.ui.widgets').hover()<CR>", { desc = "DAP Evaluate Expression" })
map("n", "<leader>dR", "<cmd>lua require('dap').repl.toggle()<CR>", { desc = "DAP Toggle REPL" })
map("n", "<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<CR>", { desc = "DAP Hover" })

map("n", "<leader>f'", "<cmd>Telescope marks<CR>", { desc = "Telescope Marks" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Telescope Buffers" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<CR>", { desc = "Find word at cursor" })
map("n", "<leader>fC", "<cmd>Telescope commands<CR>", { desc = "Telescope Commands" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fF", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>", { desc = "Find files (hidden)" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help Tags" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fm", "<cmd>Telescope man_pages<CR>", { desc = "Man Pages" })
map("n", "<leader>fn", "<cmd>Telescope notifications<CR>", { desc = "Notifications" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Recently opened files" })
map("n", "<leader>fr", "<cmd>Telescope registers<CR>", { desc = "Registers" })
map("n", "<leader>ft", "<cmd>Telescope colorscheme<CR>", { desc = "Colorschemes" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
map("n", "<leader>fW", "<cmd>Telescope live_grep hidden=true no_ignore=true<CR>", { desc = "Live Grep (hidden)" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git Branches" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git Commits (repo)" })
map("n", "<leader>gC", "<cmd>Telescope git_bcommits<CR>", { desc = "Git Commits (current file)" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "Git Status" })
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "LSP Document Symbols" })
map("n", "<leader>lG", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "LSP Workspace Symbols" })

map("n", "<C-]>", function()
  require("nvchad.term").toggle { pos = "vsp", size = 0.4 }
end, { desc = "Toggle Terminal Vertical" })
map("n", "<C-\\>", function()
  require("nvchad.term").toggle { pos = "sp", size = 0.4 }
end, { desc = "Toggle Terminal Horizontal" })
map("n", "<C-f>", function()
  require("nvchad.term").toggle { pos = "float" }
end, { desc = "Toggle Terminal Float" })
map("t", "<C-]>", function()
  require("nvchad.term").toggle { pos = "vsp" }
end, { desc = "Toggle Terminal Vertical" })

map("n", "<leader>gg", function()
  vim.cmd "LazyGit"
end, { desc = "Open LazyGit" })

map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find Todo" })

map("n", "<leader>qx", "<cmd>TroubleToggle<CR>", { desc = "Open Trouble" })
map("n", "<leader>qw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Open Workspace Trouble" })
map("n", "<leader>qd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Open Document Trouble" })
map("n", "<leader>qq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Open Quickfix" })
map("n", "<leader>ql", "<cmd>TroubleToggle loclist<CR>", { desc = "Open Location List" })
map("n", "<leader>qt", "<cmd>TodoTrouble<CR>", { desc = "Open Todo Trouble" })

map("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand "%")
end, { desc = "Run file test" })
map("n", "<leader>to", "<cmd>Neotest output<CR>", { desc = "Show test output" })
map("n", "<leader>ts", "<cmd>Neotest summary<CR>", { desc = "Show test summary" })

map("n", "<leader>gl", "<cmd>Flog<CR>", { desc = "Git Log" })
map("n", "<leader>gf", "<cmd>DiffviewFileHistory<CR>", { desc = "Git File History" })
map("n", "<leader>gc", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Git Last Commit" })
map("n", "<leader>gt", "<cmd>DiffviewToggleFile<CR>", { desc = "Git File History" })
