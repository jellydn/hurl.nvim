local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = _HURL_GLOBAL_CONFIG.split_position,
  size = _HURL_GLOBAL_CONFIG.split_size,
  buf_options = { filetype = 'markdown' },
})

local utils = require('hurl.utils')

local M = {}

-- Show content in a split
---@param data table
---   - body string
---   - headers table
---@param type 'json' | 'html' | 'xml' | 'text' | 'markdown'
M.show = function(data, type)
  local function quit()
    vim.cmd(_HURL_GLOBAL_CONFIG.mappings.close)
    split:unmount()
  end
  -- mount/open the component
  split:mount()

  if _HURL_GLOBAL_CONFIG.auto_close then
    -- unmount component when buffer is closed
    split:on(event.BufLeave, function()
      quit()
    end)
  end

  local output_lines = {}

  if type == 'markdown' then
    -- For markdown, we just use the body as-is
    output_lines = vim.split(data.body, '\n')
  else
    -- Add request information
    table.insert(output_lines, '# Request')
    table.insert(output_lines, '')
    table.insert(output_lines, string.format('**Method**: %s', data.method or 'N/A'))
    table.insert(output_lines, string.format('**URL**: %s', data.url or 'N/A'))
    table.insert(output_lines, string.format('**Status**: %s', data.status or 'N/A'))
    table.insert(output_lines, '')

    -- Add curl command
    table.insert(output_lines, '# Curl Command')
    table.insert(output_lines, '')
    table.insert(output_lines, '```bash')
    table.insert(output_lines, data.curl_command or 'N/A')
    table.insert(output_lines, '```')
    table.insert(output_lines, '')

    -- Add headers
    table.insert(output_lines, '# Headers')
    table.insert(output_lines, '')
    if data.headers then
      for key, value in pairs(data.headers) do
        table.insert(output_lines, string.format('- **%s**: %s', key, value))
      end
    else
      table.insert(output_lines, 'No headers available')
    end

    -- Add response time
    table.insert(output_lines, '')
    local response_time = tonumber(data.response_time) or 0
    table.insert(output_lines, string.format('**Response Time**: %.2f ms', response_time))
    table.insert(output_lines, '')

    -- Add body
    table.insert(output_lines, '# Body')
    table.insert(output_lines, '')
    table.insert(output_lines, '```' .. type)
    local content = utils.format(data.body, type)
    if content then
      for _, line in ipairs(content) do
        table.insert(output_lines, line)
      end
    else
      table.insert(output_lines, 'No content')
    end
    table.insert(output_lines, '```')
  end

  -- Set content
  vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, output_lines)

  split:map('n', _HURL_GLOBAL_CONFIG.mappings.close, function()
    quit()
  end)
end

M.clear = function()
  -- Check if split is open
  if not split.winid then
    return
  end

  -- Clear the buffer and add `Processing...` message with the current Hurl command
  vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, {
    'Processing...',
    '',
    '# Hurl Command',
    '',
    '```sh',
    _HURL_GLOBAL_CONFIG.last_hurl_command or 'N/A',
    '```',
  })
end

return M
