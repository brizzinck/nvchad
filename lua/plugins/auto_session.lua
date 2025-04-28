return {
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      require("auto-session").setup {
        log_level = "info",
        auto_session_root_dir = vim.fn.stdpath "data" .. "/sessions/",
        auto_session_suppress_dirs = { "~/", "~/job", "~/Downloads", "/" },
        pre_save_cmds = { "Neotree close" },
      }
    end,
  },
}
