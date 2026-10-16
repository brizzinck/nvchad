---@type ChadrcConfig

-- palette: everforest-black (~/dotfiles/themes/static/everforest-black)
local M = {}

M.base46 = {
  theme = "everforest",
  transparency = false, -- real #000000 via changed_themes below, with visible surfaces and borders

  changed_themes = {
    everforest = {
      base_30 = {
        black = "#000000",
        darker_black = "#000000",
        black2 = "#0b0e0d",
        one_bg = "#0b0e0d",
        one_bg2 = "#141a17",
        one_bg3 = "#1f2a24",
        grey = "#3a4440",
        grey_fg = "#4e5a54",
        grey_fg2 = "#5f6b65",
        light_grey = "#6b7770",
        line = "#222a27",
        statusline_bg = "#000000",
        lightbg = "#141a17",
        pmenu_bg = "#a7c080",
      },
      base_16 = {
        base00 = "#000000",
        base01 = "#0b0e0d",
        base02 = "#1f2a24",
        base03 = "#3a4440",
      },
    },
  },

  -- hl_override only touches groups that a base46 integration already defines
  hl_override = {
    Comment = { fg = "#5f875f", italic = true },
    ["@comment"] = { fg = "#5f875f", italic = true },
    CursorLine = { bg = "#0b0e0d" },
    Visual = { bg = "#2a3530" },
    FloatBorder = { fg = "#3a4440", bg = "NONE" },
    WinSeparator = { fg = "#222a27" },
    TelescopeBorder = { fg = "#3a4440" },
    TelescopePromptBorder = { fg = "#3a4440" },
    ErrorMsg = { fg = "#e67e80", bg = "NONE", bold = true },
    WarningMsg = { fg = "#dbbc7f", bg = "NONE" },
    DiffChange = { bg = "#1c2a2a", fg = "none" },
    DiffAdd = { bg = "#16261a", fg = "none" },
    DiffRemoved = { bg = "#2c1416", fg = "none" },

    -- diagnostics on the Everforest Black accents (info blue, hint aqua; base46 uses green/purple)
    DiagnosticError = { fg = "#e67e80" },
    DiagnosticWarn = { fg = "#dbbc7f" },
    DiagnosticInfo = { fg = "#7fbbb3" },
    DiagnosticHint = { fg = "#83c092" },

    -- statusline (vscode_colored): coloured text on a quiet surface, no bright blocks
    St_NormalMode = { fg = "#a7c080", bg = "#141a17" },
    St_InsertMode = { fg = "#7fbbb3", bg = "#141a17" },
    St_VisualMode = { fg = "#d699b6", bg = "#141a17" },
    St_ReplaceMode = { fg = "#e67e80", bg = "#141a17" },
    St_CommandMode = { fg = "#dbbc7f", bg = "#141a17" },
    St_TerminalMode = { fg = "#83c092", bg = "#141a17" },
    St_NTerminalMode = { fg = "#dbbc7f", bg = "#141a17" },
    St_SelectMode = { fg = "#d699b6", bg = "#141a17" },
    St_ConfirmMode = { fg = "#e69875", bg = "#141a17" },
    St_cwd = { fg = "#859289", bg = "#141a17" }, -- was red, which means "error" in this palette
    St_LspHints = { fg = "#83c092" },
    St_LspMsg = { fg = "#859289" },
  },

  -- hl_add creates groups (merged into the base46 `defaults` cache)
  hl_add = {
    NeoTreeCursorLine = { bg = "#141a17", bold = true },
    NeoTreeGitUntracked = { fg = "#e69875" },
    NotifyBackground = { bg = "#000000" },
    AlphaHeader = { fg = "#d699b6" },
    WinBar = { fg = "#a7c080", bold = true },
    WinBarNC = { fg = "#6b7770" },
    Cursor = { fg = "#000000", bg = "#e7dabe" }, -- same as the ghostty cursor colour
    CursorInsert = { bg = "#7fbbb3" },
    CursorVisual = { bg = "#d699b6" },
    CursorReplace = { bg = "#e67e80" },

    -- real undercurl with palette colours (needs tmux terminal-features usstyle, set in S5)
    DiagnosticUnderlineError = { undercurl = true, sp = "#e67e80" },
    DiagnosticUnderlineWarn = { undercurl = true, sp = "#dbbc7f" },
    DiagnosticUnderlineInfo = { undercurl = true, sp = "#7fbbb3" },
    DiagnosticUnderlineHint = { undercurl = true, sp = "#83c092" },
    DiagnosticUnnecessary = { fg = "#6b7770" },

    -- agentdash statusline segment: same colours as the tmux agent badges
    St_AgentWorking = { fg = "#dbbc7f", bg = "#000000" },
    St_AgentWaiting = { fg = "#e69875", bg = "#000000" },
    St_AgentDone = { fg = "#a7c080", bg = "#000000" },
    St_AgentError = { fg = "#e67e80", bg = "#000000" },
  },
}

-- NvChad v2.5 reads the statusline/tabufline/telescope options from M.ui (not M.base46)
M.ui = {
  statusline = {
    theme = "vscode_colored",
    -- "agents" = agentdash segment (working / waiting / done / error counters)
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "agents", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      agents = function()
        return require("agentdash.statusline").render()
      end,
    },
  },

  tabufline = {
    treeOffsetFt = "neo-tree", -- was "NvimTree": buffers were drawn over neo-tree
    order = { "treeOffset", "buffers", "tabs" }, -- no "btns": gray toggle block and filled red X
  },

  telescope = { style = "bordered" },
}

return M
