---@type ChadrcConfig

local M = {}

M.ui = {
  theme = "everforest",
  transparency = true,

  statusline = {
    theme = "vscode_colored",
  },

  hl_override = {
    Comment = { fg = "#5f875f", italic = true },
    ["@comment"] = { fg = "#5f875f", italic = true },
    DiffChange = {
      bg = "#3e4d3e",
      fg = "none",
    },
    DiffAdd = {
      bg = "#284828",
      fg = "none",
    },
    DiffRemoved = {
      bg = "#4c2c2c",
      fg = "none",
    },
  },
}

M.disabled = {
  n = {
    ["<A-i>"] = "",
  },
  t = {
    ["<A-i>"] = "",
  },
}

return M
