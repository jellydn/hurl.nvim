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

  -- unmount component when cursor leaves buffer
  split:on(event.BufLeave, function()
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
    utils.log_info('No content')
    return
  end

  -- Add content to the bottom
  utils.log_info('Adding content to buffer:' .. vim.inspect(content))
  vim.api.nvim_buf_set_lines(split.bufnr, headers_table.line, -1, false, content)

  split:map('n', 'q', '<cmd>q<cr>')

  -- Only change the buffer option on nightly builds
  if vim.fn.has('nvim-0.10.0') == 1 then
    -- Set content to highlight
    vim.api.nvim_buf_set_option(split.bufnr, 'filetype', type)
    -- Add word wrap
    vim.api.nvim_buf_set_option(split.bufnr, 'wrap', true)
    -- Enable folding for bottom buffer
    vim.api.nvim_buf_set_option(split.bufnr, 'foldmethod', 'expr')
  end
end

return M
