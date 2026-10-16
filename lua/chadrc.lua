---@type ChadrcConfig

-- Palette: Everforest, variants "black" (pure #000000, default) and "night" (near-black).
-- Tokens come from ~/dotfiles/themes/palette (see lua/palette.lua); `theme black|night` switches variants.
-- Without tokens (no dotfiles checkout) this stays stock base46 everforest.
local M = {}

M.base46 = {
  theme = "everforest",
  transparency = false, -- real bg and visible surfaces come from changed_themes below
}

local data = require("palette").get()

if data then
  local t = data.tokens

  M.base46.changed_themes = {
    everforest = {
      base_30 = {
        white = t.fg,
        darker_black = t.bg,
        black = t.bg,
        black2 = t.surface,
        one_bg = t.surface,
        one_bg2 = t.raised,
        one_bg3 = t.select,
        grey = t.border,
        grey_fg = t.muted,
        grey_fg2 = t.muted,
        light_grey = t.subtext,
        line = t.line,
        statusline_bg = t.bg,
        lightbg = t.raised,
        red = t.red,
        baby_pink = t.red_br,
        pink = t.purple_br,
        green = t.green,
        vibrant_green = t.green_br,
        blue = t.blue,
        nord_blue = t.blue,
        folder_bg = t.blue,
        teal = t.aqua,
        cyan = t.aqua_br,
        yellow = t.yellow,
        sun = t.yellow_br,
        orange = t.orange,
        purple = t.purple_br,
        dark_purple = t.purple,
        pmenu_bg = t.green,
      },
      base_16 = {
        base00 = t.bg,
        base01 = t.surface,
        base02 = t.select,
        base03 = t.border,
        base04 = t.muted,
        base05 = t.fg,
        base06 = t.fg,
        base07 = t.fg_hi,
        base08 = t.blue, -- identifiers, properties, parameters
        base09 = t.purple, -- numbers, constants
        base0A = t.aqua, -- types
        base0B = t.yellow, -- strings
        base0C = t.orange, -- escapes, tags
        base0D = t.green, -- functions, titles, directories
        base0E = t.red, -- keywords
        base0F = t.purple,
      },
    },
  }

  -- Groups that must carry palette colours whether or not a base46 integration defines them:
  -- the table is used for hl_override (groups base46 defines) and hl_add (groups it does not).
  local shared = {
    Comment = { fg = t.comment, italic = true },
    ["@comment"] = { fg = t.comment, italic = true },
    CursorLine = { bg = t.surface },
    Visual = { bg = t.visual },
    LspReferenceText = { bg = t.visual },
    LspReferenceRead = { bg = t.visual },
    LspReferenceWrite = { bg = t.visual },
    FloatBorder = { fg = t.border, bg = "NONE" },
    WinSeparator = { fg = t.line },
    TelescopeBorder = { fg = t.border },
    TelescopePromptBorder = { fg = t.border },
    TelescopeSelection = { bg = t.select },
    TelescopeMatching = { fg = t.green, bold = true },
    CmpItemAbbrMatch = { fg = t.green, bold = true },
    BlinkCmpLabelMatch = { fg = t.green, bold = true },
    StatusLine = { fg = t.subtext, bg = t.bg },

    -- base46 paints Error with base08 (= blue) as a background, which shows errors as a blue block
    Error = { fg = t.red, bg = t.error_bg },
    ErrorMsg = { fg = t.red, bg = "NONE", bold = true },
    WarningMsg = { fg = t.yellow, bg = "NONE" },

    -- search: blue = match, yellow = the current one (tmux copy mode uses the same pair)
    Search = { fg = t.bg, bg = t.blue },
    IncSearch = { fg = t.bg, bg = t.yellow },
    CurSearch = { fg = t.bg, bg = t.yellow, bold = true },

    DiffAdd = { bg = t.diff_add_bg, fg = "NONE" },
    DiffAdded = { bg = t.diff_add_bg, fg = "NONE" },
    DiffDelete = { fg = t.red, bg = t.diff_del_bg },
    DiffRemoved = { bg = t.diff_del_bg, fg = "NONE" },
    DiffChange = { bg = t.diff_chg_bg, fg = "NONE" },
    DiffText = { bg = t.diff_chg_word, fg = "NONE" },
    GitSignsAdd = { fg = t.green },
    GitSignsChange = { fg = t.yellow },
    GitSignsDelete = { fg = t.red },

    -- diagnostics: error red, warn yellow, info blue, hint aqua (base46 uses green/purple for info/hint)
    DiagnosticError = { fg = t.red },
    DiagnosticWarn = { fg = t.yellow },
    DiagnosticInfo = { fg = t.blue },
    DiagnosticHint = { fg = t.aqua },
    DiagnosticVirtualTextError = { fg = t.red, bg = t.error_bg },
    DiagnosticVirtualTextWarn = { fg = t.yellow, bg = t.warn_bg },
    DiagnosticVirtualTextInfo = { fg = t.blue, bg = t.info_bg },
    DiagnosticVirtualTextHint = { fg = t.aqua, bg = t.hint_bg },
    DiagnosticUnnecessary = { fg = t.muted },
    DiagnosticUnderlineError = { undercurl = true, sp = t.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = t.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = t.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = t.aqua },

    -- statusline (vscode_colored): coloured text on a quiet surface, no bright blocks
    St_NormalMode = { fg = t.green, bg = t.raised },
    St_InsertMode = { fg = t.blue, bg = t.raised },
    St_VisualMode = { fg = t.purple, bg = t.raised },
    St_ReplaceMode = { fg = t.red, bg = t.raised },
    St_CommandMode = { fg = t.yellow, bg = t.raised },
    St_TerminalMode = { fg = t.aqua, bg = t.raised },
    St_NTerminalMode = { fg = t.yellow, bg = t.raised },
    St_SelectMode = { fg = t.purple, bg = t.raised },
    St_ConfirmMode = { fg = t.orange, bg = t.raised },
    St_cwd = { fg = t.subtext, bg = t.raised }, -- was red, which means "error" in this palette
    St_LspHints = { fg = t.aqua },
    St_LspMsg = { fg = t.subtext },
  }

  -- hl_override only touches groups that a base46 integration already defines
  M.base46.hl_override = vim.deepcopy(shared)

  -- hl_add creates groups (merged into the base46 `defaults` cache) and also covers the shared table
  M.base46.hl_add = vim.tbl_extend("force", vim.deepcopy(shared), {
    NeoTreeCursorLine = { bg = t.raised, bold = true },
    NeoTreeGitUntracked = { fg = t.orange },
    NotifyBackground = { bg = t.bg },
    AlphaHeader = { fg = t.purple },
    WinBar = { fg = t.green, bold = true },
    WinBarNC = { fg = t.muted },
    Cursor = { fg = t.cursor_text, bg = t.cursor }, -- same as the ghostty cursor colours
    CursorInsert = { bg = t.blue },
    CursorVisual = { bg = t.purple },
    CursorReplace = { bg = t.red },

    -- agentdash statusline segment: same colours as the tmux agent badges
    St_AgentWorking = { fg = t.yellow, bg = t.bg },
    St_AgentWaiting = { fg = t.orange, bg = t.bg },
    St_AgentDone = { fg = t.green, bg = t.bg },
    St_AgentError = { fg = t.red, bg = t.bg },
  })

  -- :terminal gets the ANSI list through palette.apply() (base46 would colour it from base_16 by position,
  -- which shows red as blue and green as yellow)
  M.term = { base46_colors = false }
end

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
