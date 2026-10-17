-- Where plugins and Mason packages live: the owner's own directories, or the shared read-only copy that every managed
-- user (td, yc, ...) reads from /srv/nvim-shared (installed by `usr nvim-sync` as the owner, see dotfiles
-- infrastructure/users). Per-user state (lockfile copy, base46 cache, treesitter parsers, sessions) always stays per user.
--
-- The shared copy is used when
--   * $NVIM_SHARED names a directory (forced; `usr nvim-sync` sets it for the owner), or
--   * /srv/nvim-shared/.ready exists and this user cannot write there (a managed user).
-- $NVIM_SHARED=0 switches it off. The owner can write the shared directory, so the owner keeps the per-user directories
-- unless he sets $NVIM_SHARED himself.
local M = {}

local uv = vim.uv or vim.loop
local DEFAULT = vim.env.NVIM_SHARED_DEFAULT or "/srv/nvim-shared" -- the env override is for tests

local function pick()
  local env = vim.env.NVIM_SHARED
  if env == "0" or env == "off" then
    return nil
  end
  if env and env ~= "" then
    return env
  end
  if uv.fs_stat(DEFAULT .. "/.ready") and not uv.fs_access(DEFAULT, "W") then
    return DEFAULT
  end
  return nil
end

M.root = pick() -- nil = per-user directories

function M.lazy_root()
  return (M.root and (M.root .. "/lazy")) or (vim.fn.stdpath "data" .. "/lazy")
end

function M.mason_root()
  return (M.root and (M.root .. "/mason")) or (vim.fn.stdpath "data" .. "/mason")
end

local function read(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local s = f:read "*a"
  f:close()
  return s
end

-- lazy-lock.json: the committed one in the config directory while it can be written (the owner); otherwise (the config is
-- a read-only link into /srv/dotfiles) a per-user copy in the state directory that follows the committed pins whenever
-- those change, so `Lazy restore` keeps working and plugin operations can write their lockfile.
function M.lockfile()
  local repo = vim.fn.stdpath "config" .. "/lazy-lock.json"
  local dir = vim.fs.dirname(uv.fs_realpath(repo) or repo)
  if uv.fs_access(repo, "W") and uv.fs_access(dir, "W") then
    return repo
  end
  local state = vim.fn.stdpath "state"
  local mine = state .. "/lazy-lock.json"
  local src = read(repo)
  if src then
    local sum = vim.fn.sha256(src)
    local marker = state .. "/lazy-lock.source"
    if read(mine) == nil or vim.trim(read(marker) or "") ~= sum then
      vim.fn.mkdir(state, "p")
      local out = io.open(mine, "wb")
      if out then
        out:write(src)
        out:close()
        local m = io.open(marker, "wb")
        if m then
          m:write(sum)
          m:close()
        end
      end
    end
  end
  return mine
end

return M
