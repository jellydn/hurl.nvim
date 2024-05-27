local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = _HURL_GLOBAL_CONFIG.split_position,
  size = _HURL_GLOBAL_CONFIG.split_size,
  -- Create a custom filetype so that we can use https://github.com/folke/edgy.nvim to manage the window
  -- E.g: { title = "Hurl Nvim", ft = "hurl-nvim" },
  buf_options = { filetype = 'hurl-nvim' },
})

local utils = require('hurl.utils')

local M = {}

-- Show content in a popup
---@param data table
---   - body string
---   - headers table
---@param type 'json' | 'html' | 'text'
M.show = function(data, type)
  -- mount/open the component
  split:mount()

  vim.api.nvim_buf_set_name(split.bufnr, 'hurl-response')

  if _HURL_GLOBAL_CONFIG.auto_close then
    -- unmount component when buffer is closed
    split:on(event.BufLeave, function()
      split:unmount()
    end)
  end

  -- Add headers to the top
  local headers_table = utils.render_header_table(data.headers)
  -- Hide header block if empty headers
  if headers_table.line == 0 then
    utils.log_info('no headers')
  else
    if headers_table.line > 0 then
      vim.api.nvim_buf_set_lines(split.bufnr, 0, 1, false, headers_table.headers)
    end
  end

  local content = utils.format(data.body, type)
  if not content then
    utils.log_info('No content')
    return
  end

  -- Add content to the bottom
  vim.api.nvim_buf_set_lines(split.bufnr, headers_table.line, -1, false, content)

  local function quit()
    -- set buffer name to empty string so it wouldn't conflict when next time buffer opened
    vim.api.nvim_buf_set_name(split.bufnr, '')
    vim.cmd('q')
    split:unmount()
  end
  split:map('n', 'q', function()
    quit()
  end)

  -- Set content to highlight, refer https://github.com/MunifTanjim/nui.nvim/issues/76#issuecomment-1001358770
  vim.api.nvim_buf_set_option(split.bufnr, 'filetype', type)
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
