---@type ChadrcConfig

local M = {}

M.base46 = {
  theme = "everforest",
  transparency = true,

  statusline = {
    theme = "vscode_colored",
    -- "agents" = agentdash segment (🤖 working / 💬 waiting / ✅ done)
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "agents", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      agents = function()
        return require("agentdash.statusline").render()
      end,
    },
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
