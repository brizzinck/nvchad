return {
  "kdheepak/lazygit.nvim",
  cmd = "LazyGit",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local lazygit = require "lazygit"

    local original_close_window = lazygit.close_window

    lazygit.close_window = function(...)
      local win_id = lazygit.win_id

      if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
      end

      original_close_window(...)
    end
  end,
}
