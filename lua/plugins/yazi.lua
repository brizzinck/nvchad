return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  version = "*",
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Yazi at current file" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi in cwd" },
    -- <C-Up> is already bound to window resize, use <leader>y instead
    { "<leader>y", "<cmd>Yazi toggle<cr>", desc = "Toggle last Yazi session" },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
    -- mp4/mp3/etc play in mpv instead of opening as an nvim buffer (which
    -- just showed the raw bytes -- nvim has no business editing audio). This
    -- is a fallback for open paths other than <Enter> (which ~/.config/yazi
    -- keymap.toml now intercepts itself, publishing "play-media" instead --
    -- see the User autocmd below -- so the embedded yazi window doesn't
    -- close just to preview a video).
    open_file_function = function(chosen_file)
      if require("utils.media").is_media(chosen_file) then
        require("utils.mpv").open(chosen_file)
      else
        vim.cmd("edit " .. vim.fn.fnameescape(chosen_file))
      end
    end,
    forwarded_dds_events = { "nvim-cycle-buffer", "play-media" },
  },
  config = function(_, opts)
    require("yazi").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "YaziDDSCustom",
      callback = function(args)
        local event = args.data
        if event.type ~= "play-media" then return end
        local ok, path = pcall(vim.json.decode, event.raw_data)
        if ok and path then require("utils.mpv").open(path) end
      end,
    })
  end,
}
