-- Shared "is this a video/audio file" check, used by neo_tree.lua and
-- yazi.lua to route media files into utils/mpv.lua instead of opening them
-- as an nvim buffer.
local M = {}

local MEDIA_EXTS = {
  mp4 = true,
  mkv = true,
  webm = true,
  mov = true,
  avi = true,
  m4v = true,
  flv = true,
  wmv = true,
  mp3 = true,
  wav = true,
  flac = true,
  ogg = true,
  m4a = true,
  opus = true,
}

function M.is_media(path)
  return MEDIA_EXTS[vim.fn.fnamemodify(path, ":e"):lower()] == true
end

return M
