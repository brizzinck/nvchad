-- Generates static frame thumbnails for video files via ffmpegthumbnailer, so
-- image.nvim (which only decodes images) has something it can actually render.
local M = {}

local VIDEO_EXTS = {
  mp4 = true,
  mkv = true,
  webm = true,
  mov = true,
  avi = true,
  m4v = true,
  flv = true,
  wmv = true,
}

M.patterns = vim.tbl_map(function(ext)
  return "*." .. ext
end, vim.tbl_keys(VIDEO_EXTS))

function M.is_video(path)
  return VIDEO_EXTS[vim.fn.fnamemodify(path, ":e"):lower()] == true
end

--- Generate (and cache) a static thumbnail PNG for a video file.
---@param path string absolute path to the video file
---@return string|nil thumbnail path, or nil if generation failed
function M.thumbnail(path)
  if vim.fn.executable "ffmpegthumbnailer" == 0 then return nil end

  local cache_dir = vim.fn.stdpath "cache" .. "/video-thumbnails"
  vim.fn.mkdir(cache_dir, "p")

  local key = vim.fn.fnamemodify(path, ":p") .. ":" .. vim.fn.getftime(path)
  local out = ("%s/%s.png"):format(cache_dir, vim.fn.sha256(key))

  if vim.fn.filereadable(out) == 0 then
    vim.fn.system { "ffmpegthumbnailer", "-i", path, "-o", out, "-s", "0", "-q", "8" }
  end

  return vim.fn.filereadable(out) == 1 and out or nil
end

return M
