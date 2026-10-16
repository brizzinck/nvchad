-- explicit border: with 'winborder' set, which-key (border = nil) would get a border it does not account for
return {
  "folke/which-key.nvim",
  opts = {
    win = { border = "rounded" },
  },
}
