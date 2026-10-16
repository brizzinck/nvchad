local dashboard = require "alpha.themes.dashboard"

local user = os.getenv "USER" or "User"

dashboard.section.header.val = {
  "███████╗██╗  ██╗ █████╗ ██╗     ███████╗███████╗",
  "██╔════╝██║ ██╔╝██╔══██╗██║     ██╔════╝██╔════╝",
  "███████╗█████╔╝ ███████║██║     ███████╗█████╗  ",
  "╚════██║██╔═██╗ ██╔══██║██║     ╚════██║██╔══╝  ",
  "███████║██║  ██╗██║  ██║███████╗███████║███████╗",
  "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝",
}

dashboard.section.buttons.val = {
  dashboard.button("f", "󰈞  Find File", ":Telescope find_files<CR>"),
  dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
  dashboard.button("w", "󰈬  Find Word", ":Telescope live_grep<CR>"),
  dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
  dashboard.button("q", "  Quit", ":qa<CR>"),
}

dashboard.section.footer.val = {
  "\u{f007}  " .. user,
}

-- AlphaHeader (purple, echoes the wallpaper) is defined in chadrc.lua; no big red "error" block
dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "Normal"
dashboard.section.footer.opts.hl = "Comment"

require("alpha").setup(dashboard.config)
