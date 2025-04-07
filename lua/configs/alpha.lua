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
  "💻 Welcome, " .. user .. "!",
}

-- optional: highlight groups
dashboard.section.header.opts.hl = "Keyword"
dashboard.section.buttons.opts.hl = "Function"
dashboard.section.footer.opts.hl = "Type"

require("alpha").setup(dashboard.config)
