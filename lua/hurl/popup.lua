local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event

local utils = require('hurl.utils')

local M = {}

local popup = Popup({
  enter = true,
  focusable = true,
  border = {
    style = 'rounded',
  },
  position = '50%',
  size = {
    width = '80%',
    height = '60%',
  },
})

--- Format the body of the request
---@param body string
---@param type 'json' | 'html'
---@return string[] | nil
local function format(body, type)
  local formatters = { json = 'jq', html = { 'prettier', '--parser', 'html' } }
  local stdout = vim.fn.systemlist(formatters[type], body)
  if vim.v.shell_error ~= 0 then
    utils.log('formatter failed' .. tostring(vim.v.shell_error))
    return nil
  end
  return stdout
end

-- Show content in a popup
---@param body string
---@param type 'json' | 'html'
M.show = function(body, type)
  popup:mount()
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local content = format(body, type)
  if not content then
    return
  end

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, content)
end

return M
