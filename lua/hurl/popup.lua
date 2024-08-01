local Popup = require('nui.popup')
local event = require('nui.utils.autocmd').event
local Layout = require('nui.layout')

local utils = require('hurl.utils')

local M = {}
local popups = {
  bottom = Popup({
    border = 'single',
    enter = true,
    buf_options = { filetype = 'json' },
  }),
  top = Popup({
    border = { style = 'rounded' },
    buf_options = { filetype = 'bash' },
  }),
}

local layout = Layout(
  {
    relative = 'editor',
    position = _HURL_GLOBAL_CONFIG.popup_position,
    size = _HURL_GLOBAL_CONFIG.popup_size,
  },
  Layout.Box({
    Layout.Box(popups.top, { size = {
      height = '20%',
    } }),
    Layout.Box(popups.bottom, { grow = 1 }),
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
    vim.cmd('q')
    layout:unmount()
  end

  -- Map q to quit
  popups.top:map('n', _HURL_GLOBAL_CONFIG.mappings.close, function()
    quit()
  end)
  popups.bottom:map('n', _HURL_GLOBAL_CONFIG.mappings.close, function()
    quit()
  end)

  -- Map <Ctr-n> to next popup
  popups.top:map('n', _HURL_GLOBAL_CONFIG.mappings.next_panel, function()
    vim.api.nvim_set_current_win(popups.bottom.winid)
  end)
  popups.bottom:map('n', _HURL_GLOBAL_CONFIG.mappings.next_panel, function()
    vim.api.nvim_set_current_win(popups.top.winid)
  end)
  -- Map <Ctr-p> to previous popup
  popups.top:map('n', _HURL_GLOBAL_CONFIG.mappings.prev_panel, function()
    vim.api.nvim_set_current_win(popups.bottom.winid)
  end)
  popups.bottom:map('n', _HURL_GLOBAL_CONFIG.mappings.prev_panel, function()
    vim.api.nvim_set_current_win(popups.top.winid)
  end)

  -- Add headers to the top
  local headers_table = utils.render_header_table(data.headers)
  -- Hide header block if empty headers
  if headers_table.line == 0 then
    vim.api.nvim_win_close(popups.top.winid, true)
  else
    if headers_table.line > 0 then
      vim.api.nvim_buf_set_lines(popups.top.bufnr, 0, 1, false, headers_table.headers)
    end
  end

  -- Add response time as virtual text
  vim.api.nvim_buf_set_extmark(
    popups.top.bufnr,
    vim.api.nvim_create_namespace('response_time_ns'),
    0,
    0,
    {
      end_line = 1,
      id = 1,
      virt_text = { { 'Response: ' .. data.response_time .. ' ms', 'Comment' } },
      virt_text_pos = 'eol',
    }
  )

  local content = utils.format(data.body, type)
  if not content then
    utils.log_info('No content')
    return
  end

  -- Add content to the bottom
  vim.api.nvim_buf_set_lines(popups.bottom.bufnr, 0, -1, false, content)

  -- Set content to highlight, refer https://github.com/MunifTanjim/nui.nvim/issues/76#issuecomment-1001358770
  vim.api.nvim_buf_set_option(popups.bottom.bufnr, 'filetype', type)

  -- Show the popup after populating the content for alignment
  layout:show()
end

M.clear = function()
  -- Check if popup is open
  if not popups.bottom.winid then
    return
  end
  -- Clear the buffer and adding `Processing...` message
  vim.api.nvim_buf_set_lines(popups.top.bufnr, 0, -1, false, { 'Processing...' })
  vim.api.nvim_buf_set_lines(popups.bottom.bufnr, 0, -1, false, { 'Processing...' })
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
      width = '50%',
      height = '50%',
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
