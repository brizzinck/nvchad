return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = { lookahead = true },
      move = { set_jumps = true },
    }

    local select = require "nvim-treesitter-textobjects.select"
    local move = require "nvim-treesitter-textobjects.move"

    local function map_select(mode, lhs, query)
      vim.keymap.set(mode, lhs, function()
        select.select_textobject(query, "textobjects")
      end, { desc = "Select " .. query })
    end

    map_select({ "x", "o" }, "af", "@function.outer")
    map_select({ "x", "o" }, "if", "@function.inner")
    map_select({ "x", "o" }, "ac", "@class.outer")
    map_select({ "x", "o" }, "ic", "@class.inner")
    map_select({ "x", "o" }, "aa", "@parameter.outer")
    map_select({ "x", "o" }, "ia", "@parameter.inner")

    vim.keymap.set({ "n", "x", "o" }, "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, { desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, { desc = "Previous function start" })
    vim.keymap.set({ "n", "x", "o" }, "]a", function()
      move.goto_next_start("@parameter.inner", "textobjects")
    end, { desc = "Next parameter" })
    vim.keymap.set({ "n", "x", "o" }, "[a", function()
      move.goto_previous_start("@parameter.inner", "textobjects")
    end, { desc = "Previous parameter" })
  end,
}
