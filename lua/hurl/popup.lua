local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event
local Layout = require('nui.layout')

local utils = require('hurl.utils')

local M = {}
local popups = {
  bottom = Popup({ border = 'single', enter = true }),
  top = Popup({ border = {
    style = 'rounded',
  } }),
}

local layout = Layout(
  {
    position = '50%',
    size = {
      width = 80,
      height = 40,
    },
  },
  Layout.Box({
    Layout.Box(popups.top, { size = {
      height = '20%',
    } }),
    Layout.Box(popups.bottom, { grow = 1 }),
  }, { dir = 'col' })
)

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
---@param data table
---   - body string
---   - headers table
---@param type 'json' | 'html'
M.show = function(data, type)
  layout:mount()

  -- Close popup when buffer is closed
  for _, popup in pairs(popups) do
    popup:on(event.BufLeave, function()
      vim.schedule(function()
        local current_buffer = vim.api.nvim_get_current_buf()
        for _, p in pairs(popups) do
          if p.bufnr == current_buffer then
            return
          end
        end
        layout:unmount()
      end)
    end)
  end

  -- Map q to quit
  popups.top:map('n', 'q', '<cmd>q<cr>')
  popups.bottom:map('n', 'q', '<cmd>q<cr>')

  -- Map <Ctr-n> to next popup
  popups.top:map('n', '<C-n>', function()
    vim.api.nvim_set_current_win(popups.bottom.winid)
  end)
  popups.bottom:map('n', '<C-n>', function()
    vim.api.nvim_set_current_win(popups.top.winid)
  end)
  -- Map <Ctr-p> to previous popup
  popups.top:map('n', '<C-p>', function()
    vim.api.nvim_set_current_win(popups.bottom.winid)
  end)
  popups.bottom:map('n', '<C-p>', function()
    vim.api.nvim_set_current_win(popups.top.winid)
  end)

  -- Add headers to the top
  local headers = {}
  local line = 0
  for k, v in pairs(data.headers) do
    line = line + 1
    table.insert(headers, k .. ': ' .. v)
  end

  -- Hide header block if empty headers
  if line == 0 then
    vim.api.nvim_win_close(popups.top.winid, true)
  else
    if line > 0 then
      vim.api.nvim_buf_set_lines(popups.top.bufnr, 0, 1, false, headers)
    end
  end

  local content = format(data.body, type)
  if not content then
    return
  end

  -- Set content to highlight
  vim.api.nvim_buf_set_option(popups.top.bufnr, 'filetype', 'bash')
  vim.api.nvim_buf_set_option(popups.bottom.bufnr, 'filetype', type)

  -- Add content to the bottom
  vim.api.nvim_buf_set_lines(popups.bottom.bufnr, 0, -1, false, content)
end

return M
