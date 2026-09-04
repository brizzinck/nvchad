-- image.nvim only ever decodes images (its own hijack_file_patterns and the markdown
-- integration both hand raw paths to ImageMagick). It has no concept of video at all, so
-- video files need a real frame extracted first: ImageMagick's own ffmpeg delegate returns
-- the same degenerate frame regardless of the requested index, so we shell out to
-- ffmpegthumbnailer (utils/video_thumbnail.lua) and point image.nvim at that instead.
local video = require "utils.video_thumbnail"

-- Matches image.nvim's own default hijack_file_patterns (we don't override it).
local IMAGE_EXTS = { png = true, jpg = true, jpeg = true, gif = true, webp = true, avif = true }

return {
  "3rd/image.nvim",
  build = false,
  event = "VeryLazy",
  opts = {
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" },
        resolve_image_path = function(document_path, image_path, resolve_absolute_path)
          local abs = resolve_absolute_path(document_path, image_path)
          if video.is_video(abs) then return video.thumbnail(abs) or abs end
          return abs
        end,
      },
      neorg = { enabled = false },
      typst = { enabled = false },
      html = { enabled = false },
      css = { enabled = false },
    },
    max_width_window_percentage = 80,
    max_height_window_percentage = 60,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    -- avoid ghost images left behind in inactive tmux panes/windows
    tmux_show_only_in_active_window = true,
  },
  config = function(_, opts)
    require("image").setup(opts)

    -- Opening a video file directly: render a static thumbnail frame the same way
    -- image.nvim's own hijack_file_patterns does for images (it just can't do this
    -- itself since it only knows how to hand raw paths to the image decoder).
    local function try_hijack(buf, win)
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" or not video.is_video(name) then return end
      if vim.bo[buf].filetype == "image_nvim" then return end
      local thumb = video.thumbnail(name)
      if not thumb then
        vim.notify("video preview: ffmpegthumbnailer failed for " .. name, vim.log.levels.WARN)
        return
      end
      require("image").hijack_buffer(thumb, win, buf)
    end

    vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "TabEnter" }, {
      pattern = video.patterns,
      callback = function(ev)
        try_hijack(ev.buf, vim.api.nvim_get_current_win())
      end,
    })

    -- "VeryLazy" (this plugin's load trigger) fires after Neovim has already read any
    -- cmdline file arguments and fired their one BufWinEnter, so `nvim clip.mp4` (or,
    -- pre-existing bug, `nvim photo.png`) would otherwise never get hijacked. Catch
    -- buffers that were already open by the time we got here.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local win = vim.fn.bufwinid(buf)
      if win ~= -1 then
        local name = vim.api.nvim_buf_get_name(buf)
        if video.is_video(name) then
          try_hijack(buf, win)
        elseif IMAGE_EXTS[vim.fn.fnamemodify(name, ":e"):lower()] then
          pcall(require("image").hijack_buffer, name, win, buf)
        end
      end
    end
  end,
}
