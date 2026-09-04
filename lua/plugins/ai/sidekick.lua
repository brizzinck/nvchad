-- sidekick.nvim: AI CLIs (claude/codex/gemini/copilot) in persistent tmux windows
-- + Copilot Next Edit Suggestions. Claude's IDE bridge is claudecode.nvim.
return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    nes = {
      enabled = function()
        return vim.g.sidekick_nes ~= false
      end,
    },
    cli = {
      watch = true,
      picker = "telescope",
      win = {
        layout = "right",
        split = { width = 90 },
      },
      mux = {
        backend = "tmux",
        enabled = true,
        create = "window",
      },
      -- Every CLI launched fully unattended: no permission/approval prompts, ever.
      -- Diffs/output are still reviewable afterwards via <leader>ar (codediff) and the
      -- agentdash sidebar — this only removes the interactive "may I?" step.
      tools = {
        claude = { cmd = { "claude", "--permission-mode", "bypassPermissions" } },
        codex = { cmd = { "codex", "--dangerously-bypass-approvals-and-sandbox" } },
        gemini = { cmd = { "gemini", "--yolo" } },
        copilot = { cmd = { "copilot", "--banner", "--allow-all" } },
      },
      prompts = {
        gotest = "Write table-driven Go tests for {function} in {file}. Follow project conventions (testify require/assert, when/then subtests).",
        golint = "Fix these lint findings without changing behaviour:\n{diagnostics_all}",
        pr = "Review the current git changes ({changes}) as a strict senior Go reviewer. List concrete issues with file:line, then a short summary.",
        explain_ru = "Объясни этот код кратко, по-русски: {this}",
      },
    },
  },
  keys = {
    {
      "<Tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "AI: toggle last CLI" },
    { "<leader>ac", function() require("sidekick.cli").toggle { name = "claude", focus = true } end, desc = "AI: Claude" },
    { "<leader>ax", function() require("sidekick.cli").toggle { name = "codex", focus = true } end, desc = "AI: Codex" },
    { "<leader>ag", function() require("sidekick.cli").toggle { name = "gemini", focus = true } end, desc = "AI: Gemini" },
    { "<leader>ao", function() require("sidekick.cli").toggle { name = "copilot", focus = true } end, desc = "AI: Copilot CLI" },
    { "<leader>al", function() require("sidekick.cli").select() end, desc = "AI: select CLI / session" },
    { "<leader>a+", function() require("utils.ai_sessions").open_new() end, desc = "AI: new session (pick tool)" },
    { "<leader>a=", function() require("utils.ai_sessions").open_new "claude" end, desc = "AI: new Claude session" },
    { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "AI: prompt picker" },
    { "<leader>as", function() require("sidekick.cli").send { msg = "{selection}" } end, mode = { "x" }, desc = "AI: send selection" },
    { "<leader>as", function() require("sidekick.cli").send { msg = "{this}" } end, mode = { "n" }, desc = "AI: send this (pos/func)" },
    {
      "<leader>at",
      function()
        vim.g.sidekick_nes = not (vim.g.sidekick_nes ~= false)
        vim.notify("NES " .. (vim.g.sidekick_nes and "ON" or "OFF"))
      end,
      desc = "AI: toggle NES",
    },
    { "<c-.>", function() require("sidekick.cli").focus() end, mode = { "n", "x", "i", "t" }, desc = "AI: focus/hide CLI" },
  },
}
