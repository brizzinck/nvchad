local M = {}

function M.read_clipboard()
  local esc = string.char(0x1b)
  local query = esc .. "]52;c;?" .. esc .. "\\"
  vim.api.nvim_chan_send(vim.v.stderr, query)

  local ok, data = pcall(vim.fn.getcharstr)
  if not ok or not data then
    return ""
  end

  local clipboard_b64 = data:match "52;c;([^%a%d+/=]+)"
  if clipboard_b64 then
    local decoded = vim.fn.system("base64 --decode", clipboard_b64)
    return decoded
  end

  return ""
end

return M
