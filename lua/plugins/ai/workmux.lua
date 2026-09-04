-- workmux: git worktree + tmux window per agent task. Thin wrappers only — the tool has
-- its own TUI (dashboard/sidebar); nvim just launches it in a tmux window/pane.
local function in_tmux()
  return vim.env.TMUX ~= nil and vim.fn.executable "tmux" == 1
end

local function tmux_window(cmd, name)
  if vim.fn.executable "workmux" ~= 1 then
    vim.notify("workmux not installed: cargo install workmux", vim.log.levels.ERROR)
    return
  end
  if not in_tmux() then
    vim.notify("workmux needs nvim to run inside tmux", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "tmux", "new-window", "-n", name or "wm", cmd }, { detach = true })
end

local function tmux_split(cmd)
  if not in_tmux() then
    return tmux_window(cmd)
  end
  vim.fn.jobstart({ "tmux", "split-window", "-h", "-l", "60", cmd }, { detach = true })
end

local function add()
  vim.ui.input({ prompt = "workmux add — branch: " }, function(branch)
    if not branch or branch == "" then
      return
    end
    vim.ui.input({ prompt = "prompt for the agent (empty = none): " }, function(prompt)
      local parts = { "workmux", "add", vim.fn.shellescape(branch), "-b" }
      if prompt and prompt ~= "" then
        table.insert(parts, "-p")
        table.insert(parts, vim.fn.shellescape(prompt))
      end
      local cmd = table.concat(parts, " ")
      vim.fn.jobstart({ "sh", "-c", cmd }, {
        detach = true,
        on_exit = function(_, code)
          vim.schedule(function()
            vim.notify(code == 0 and ("workmux: created " .. branch) or ("workmux add failed (" .. code .. ")"),
              code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end)
        end,
      })
    end)
  end)
end

return {
  dir = vim.fn.stdpath "config",
  name = "workmux-keys",
  keys = {
    { "<leader>awa", add, desc = "workmux: add worktree + agent" },
    { "<leader>awd", function() tmux_window("workmux dashboard", "wm-dash") end, desc = "workmux: dashboard" },
    { "<leader>aws", function() vim.fn.jobstart({ "workmux", "sidebar" }, { detach = true }) end, desc = "workmux: toggle sidebar" },
    { "<leader>awl", function() tmux_split("workmux list; read -r _") end, desc = "workmux: list worktrees" },
    { "<leader>awm", function() tmux_split("workmux merge; read -r _") end, desc = "workmux: merge current worktree" },
    { "<leader>awo", function() tmux_split("workmux open") end, desc = "workmux: open worktree window" },
  },
}
