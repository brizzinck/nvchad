-- Core mpv process/IPC management, kept separate from the keymap wiring in
-- mappings.lua the same way video_thumbnail.lua separates the ffmpeg part
-- from image.lua's UI glue.
--
-- Renders via mpv's own --vo=tct (true-color terminal glyphs) inside a
-- toggleterm floating window, not a native Wayland GUI window: spawning mpv
-- as a real GPU-rendered window crashed the whole Hyprland session on this
-- machine (full logout, no window clickable) on real video/audio files --
-- likely a GPU driver / Wayland presentation crash, not yet root-caused.
-- --vo=tct never touches the compositor's own rendering path, so it's the
-- safe option until that's understood. Picture quality is blockier as a
-- result (half-block glyphs, bounded by terminal cell grid) -- see the
-- discussion in git log for this file around the native-window attempt.
local Terminal = require("toggleterm.terminal").Terminal

local M = {}

M.socket = vim.fn.stdpath "run" .. "/mpv.sock"

---@type table? current player terminal instance (singleton: one mpv at a time)
local player

--- Play a local file or URL.
---@param target string path or URL
function M.open(target)
  if not target or target == "" then return end
  if vim.fn.filereadable(vim.fn.expand(target)) == 1 then target = vim.fn.expand(target) end

  if player then player:shutdown() end

  -- A stale socket file (left behind by a crash, suspend/resume, or a killed
  -- session) makes mpv fail to bind the IPC socket and die almost instantly,
  -- with no obvious error -- indistinguishable from "the player doesn't work".
  vim.fn.delete(M.socket)

  local cmd = ("mpv --vo=tct --input-ipc-server=%s -- %s"):format(
    vim.fn.shellescape(M.socket),
    vim.fn.shellescape(target)
  )

  player = Terminal:new {
    cmd = cmd,
    direction = "float",
    float_opts = {
      relative = "editor",
      row = math.floor(vim.o.lines * 0.02),
      col = math.floor(vim.o.columns * 0.08),
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.o.lines * 0.9),
      border = "curved",
    },
    -- close_on_exit=false: mpv exiting non-zero (bad path, unsupported codec,
    -- missing file) must not silently tear the window down -- with
    -- close_on_exit=true that looked indistinguishable from the player
    -- "doing nothing" since mpv's own error output vanished along with the
    -- buffer before anyone could read it.
    close_on_exit = false,
    on_open = function(term)
      vim.cmd "startinsert"
      vim.keymap.set("t", "q", function()
        term:shutdown()
      end, { buffer = term.bufnr, desc = "Quit mpv" })
    end,
    on_exit = function(term, _, exit_code)
      player = nil
      -- Closing the terminal window (the "q" mapping below, or any other way
      -- of killing the buffer/job) sends mpv a signal, which libuv reports
      -- as exit code 128+signal (129 = SIGHUP, 143 = SIGTERM) -- that's a
      -- normal close, not a failure, so only >=128 codes above these get
      -- flagged. Genuine mpv errors (bad path, unsupported codec, missing
      -- file) exit with their own small codes (1-4) and still notify.
      if exit_code == 0 or exit_code == 129 or exit_code == 143 then
        term:shutdown()
      else
        vim.notify(
          ("mpv exited with code %d for %s -- see the player window for its output"):format(exit_code, target),
          vim.log.levels.ERROR
        )
      end
    end,
  }
  player:open()
end

--- Hide/show the player window without killing playback (audio keeps running while
--- you go back to editing -- this is what makes it usable as a background music player).
function M.toggle()
  if player then player:toggle() end
end

function M.stop()
  if player then player:shutdown() end
  player = nil
end

return M
