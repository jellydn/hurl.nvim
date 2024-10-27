local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event
local Layout = require('nui.layout')

local utils = require('hurl.utils')

local M = {}

local popups = {
  body = Popup({
    border = 'single',
    enter = true,
    buf_options = { filetype = 'markdown' },
  }),
  info = Popup({
    border = 'single',
    enter = true,
    buf_options = { filetype = 'markdown' },
  }),
}

local layout = Layout(
  {
    relative = 'editor',
    position = _HURL_GLOBAL_CONFIG.popup_position,
    size = _HURL_GLOBAL_CONFIG.popup_size,
  },
  Layout.Box({
    Layout.Box(popups.info, { size = '30%' }),
    Layout.Box(popups.body, { grow = 1 }),
  }, { dir = 'col' })
)

-- Show content in a popup
---@param data table
---   - body string
---   - headers table
---@param type 'json' | 'html' | 'xml' | 'text'
M.show = function(data, type)
  layout:mount()

  -- Close popup when buffer is closed
  if _HURL_GLOBAL_CONFIG.auto_close then
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
  end

  local function quit()
    vim.cmd(_HURL_GLOBAL_CONFIG.mappings.close)
    layout:unmount()
  end

  -- Map q to quit for both popups
  for _, popup in pairs(popups) do
    popup:map('n', _HURL_GLOBAL_CONFIG.mappings.close, function()
      quit()
    end)
  end

  -- Map <Ctr-n> to next popup
  popups.body:map('n', _HURL_GLOBAL_CONFIG.mappings.next_panel, function()
    vim.api.nvim_set_current_win(popups.info.winid)
  end)
  popups.info:map('n', _HURL_GLOBAL_CONFIG.mappings.next_panel, function()
    vim.api.nvim_set_current_win(popups.body.winid)
  end)
  -- Map <Ctr-p> to previous popup
  popups.body:map('n', _HURL_GLOBAL_CONFIG.mappings.prev_panel, function()
    vim.api.nvim_set_current_win(popups.info.winid)
  end)
  popups.info:map('n', _HURL_GLOBAL_CONFIG.mappings.prev_panel, function()
    vim.api.nvim_set_current_win(popups.body.winid)
  end)
  -- Info popup content
  local info_lines = {}

  -- Add request information
  table.insert(info_lines, '# Request')
  table.insert(info_lines, '')
  table.insert(info_lines, string.format('**Method**: %s', data.method))
  table.insert(info_lines, string.format('**URL**: %s', data.url))
  table.insert(info_lines, string.format('**Status**: %s', data.status))
  table.insert(info_lines, '')

  -- Add curl command
  table.insert(info_lines, '# Curl Command')
  table.insert(info_lines, '')
  table.insert(info_lines, '```bash')
  table.insert(info_lines, data.curl_command or 'N/A')
  table.insert(info_lines, '```')
  table.insert(info_lines, '')

  -- Add headers
  table.insert(info_lines, '# Headers')
  table.insert(info_lines, '')
  for key, value in pairs(data.headers) do
    table.insert(info_lines, string.format('- **%s**: %s', key, value))
  end

  -- Add response time
  table.insert(info_lines, '')
  table.insert(info_lines, string.format('**Response Time**: %.2f ms', data.response_time))

  -- Set info content
  vim.api.nvim_buf_set_lines(popups.info.bufnr, 0, -1, false, info_lines)

  -- Body popup content
  local body_lines = {}

  -- Add body
  table.insert(body_lines, '# Body')
  table.insert(body_lines, '')
  table.insert(body_lines, '```' .. type)
  local content = utils.format(data.body, type)
  if content then
    for _, line in ipairs(content) do
      table.insert(body_lines, line)
    end
  else
    table.insert(body_lines, 'No content')
  end
  table.insert(body_lines, '```')

  -- Set body content
  vim.api.nvim_buf_set_lines(popups.body.bufnr, 0, -1, false, body_lines)

  -- Show the popup after populating the content for alignment
  layout:show()

  -- Set cursor to the body popup
  vim.api.nvim_set_current_win(popups.body.winid)
end

M.clear = function()
  -- Check if popup is open
  if not layout.winid then
    return
  end
  -- Clear the buffer and add `Processing...` message with spinner and Hurl command
  for _, popup in pairs(popups) do
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
      'Processing... ',
      _HURL_GLOBAL_CONFIG.last_hurl_command or 'N/A',
    })
  end
end

--- Show text in a popup
---@param title string
---@param lines table
---@param bottom? string
---@return any
M.show_text = function(title, lines, bottom)
  -- Create a new popup
  local text_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = 'rounded',
      text = {
        top = title,
        top_align = 'center',
        bottom = bottom or 'Press `q` to close',
        bottom_align = 'left',
      },
    },
    position = '50%',
    size = {
      width = '90%',
      height = '90%',
    },
  })

  text_popup:on('BufLeave', function()
    text_popup:unmount()
  end, { once = true })

  vim.api.nvim_buf_set_lines(text_popup.bufnr, 0, 1, false, lines)

  local function quit()
    vim.cmd('q')
    text_popup:unmount()
  end

  -- Map q to quit
  text_popup:map('n', 'q', function()
    quit()
  end)

  text_popup:mount()

  return text_popup
end

return M
