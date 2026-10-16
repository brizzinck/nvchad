-- explicit border: with 'winborder' set, which-key (border = nil) would get a border it does not account for
return {
  "folke/which-key.nvim",
  opts = {
    win = { border = "rounded" },
    -- hide the Cyrillic twins registered by langmapper (their desc carries "LM (")
    filter = function(mapping)
      return not (mapping.desc and mapping.desc:find("LM (", 1, true))
    end,
  },
}
