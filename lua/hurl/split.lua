local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local split = Split({
  relative = 'editor',
  position = 'bottom',
  size = '30%',
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

  -- unmount component when cursor leaves buffer
  split:on(event.BufLeave, function()
    -- TODO: clear buffer on unmount
    split:unmount()
  end)

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
    return
  end

  split:map('n', 'q', '<cmd>q<cr>')

  -- Set content to highlight
  vim.api.nvim_buf_set_option(split.bufnr, 'filetype', type)

  -- Add content to the bottom
  vim.api.nvim_buf_set_lines(split.bufnr, headers_table.line, -1, false, content)
end

return M
