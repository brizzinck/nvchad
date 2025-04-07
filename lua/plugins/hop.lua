return {
  "phaazon/hop.nvim",
  branch = "v2",
  config = function()
    local hop = require "hop"
    hop.setup { keys = "etovxqpdygfblzhckisuran" }

    vim.keymap.set("n", "<leader>fs", function()
      hop.hint_char1 { current_line_only = true }
    end, { desc = "Hop to symbol in current line" })

    vim.keymap.set("n", "<leader>fl", function()
      hop.hint_lines()
    end, { desc = "Hop to line in current window" })

    vim.keymap.set("n", "<leader>fw", function()
      hop.hint_words()
    end, { desc = "Hop to word in current window" })

    vim.keymap.set("n", "<leader>fp", function()
      hop.hint_patterns()
    end, { desc = "Hop to pattern in current window" })
  end,
}
