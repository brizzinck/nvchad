-- codediff.nvim: VSCode-quality diff/explorer for reviewing what an agent changed in the
-- working tree. review.nvim adds [ISSUE]/[SUGGESTION] comments on diff lines and sends them
-- back to the agent via sidekick — closing the review loop without leaving the diff.
return {
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
      diff = { layout = "side-by-side" },
      explorer = { auto_refresh = true, untracked = "all" },
      keymaps = {
        view = {
          -- <leader>b/<leader>e are taken by buffer-close and NeoTree in our config
          toggle_explorer = "<localleader>b",
          focus_explorer = "<localleader>e",
        },
      },
    },
    keys = {
      { "<leader>ae", "<cmd>CodeDiff<cr>", desc = "AI: explore working-tree changes (codediff)" },
      { "<leader>aE", "<cmd>CodeDiff file HEAD<cr>", desc = "AI: diff current file vs HEAD" },
    },
  },
  {
    "georgeguimaraes/review.nvim",
    version = "v*",
    dependencies = { "esmuellert/codediff.nvim", "MunifTanjim/nui.nvim" },
    cmd = { "Review" },
    opts = {},
    keys = {
      { "<leader>ar", "<cmd>Review open<cr>", desc = "AI: review changes with comments" },
      { "<leader>aR", "<cmd>Review sidekick<cr>", desc = "AI: send review comments to agent" },
    },
  },
}
