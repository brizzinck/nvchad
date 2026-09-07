return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      -- f/F/t/T keep their native meaning (forward/backward, `;`/`,` repeat)
      -- but work across lines; `s` stays native, flash jump lives on `S`.
      char = {
        enabled = true,
        multi_line = true,
        jump_labels = false,
        keys = { "f", "F", "t", "T", ";", "," },
      },
    },
  },
  keys = {
    { "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
