local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = _HURL_GLOBAL_CONFIG.split_position,
  size = _HURL_GLOBAL_CONFIG.split_size,
})

local utils = require('hurl.utils')

local M = {}

-- Show content in a split
---@param data table
---   - body string
---   - headers table
---@param type 'json' | 'html' | 'xml' | 'text'
M.show = function(data, type)
  local function quit()
    vim.cmd(_HURL_GLOBAL_CONFIG.mappings.close)
    split:unmount()
  end
  -- mount/open the component
  split:mount()

  -- Create a custom filetype so that we can use https://github.com/folke/edgy.nvim to manage the window
  -- E.g: { title = "Hurl Nvim", ft = "hurl-nvim" },
  vim.bo[split.bufnr].filetype = 'hurl-nvim'

  if _HURL_GLOBAL_CONFIG.auto_close then
    -- unmount component when buffer is closed
    split:on(event.BufLeave, function()
      quit()
    end)
  end

  local output_lines = {}

  -- Add headers
  table.insert(output_lines, '# Headers')
  table.insert(output_lines, '')
  for key, value in pairs(data.headers) do
    table.insert(output_lines, '- **' .. key .. '**: ' .. value)
  end

  -- Add response time
  table.insert(output_lines, '')
  table.insert(output_lines, '**Response Time**: ' .. data.response_time .. ' ms')
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

  -- Set content
  vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, output_lines)

  -- Set content to highlight, refer https://github.com/MunifTanjim/nui.nvim/issues/76#issuecomment-1001358770
  -- After 200ms, the highlight will be applied
  vim.defer_fn(function()
    -- Set filetype to markdown
    vim.api.nvim_buf_set_option(split.bufnr, 'filetype', 'markdown')
    -- recomputing foldlevel, this is needed if we setup foldexpr
    vim.api.nvim_feedkeys('zx', 'n', true)
  end, 200)

  split:map('n', _HURL_GLOBAL_CONFIG.mappings.close, function()
    quit()
  end)
end

M.clear = function()
  -- Check if split is open
  if not split.winid then
    return
  end

  -- Clear the buffer and adding `Processing...` message
  vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, { 'Processing...' })
end

return M
