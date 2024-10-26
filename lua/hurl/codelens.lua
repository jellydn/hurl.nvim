local M = {}

-- Add virtual text for Hurl entries by finding HTTP verbs
function M.add_virtual_text_for_hurl_entries()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  -- Only add virtual text if the filetype is 'hurl'
  if filetype ~= 'hurl' then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Clear existing virtual text
  vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

  local entry_number = 1
  for i, line in ipairs(lines) do
    -- Simple pattern to match common HTTP verbs
    if
      line:match('^%s*GET')
      or line:match('^%s*POST')
      or line:match('^%s*PUT')
      or line:match('^%s*DELETE')
    then
      vim.api.nvim_buf_set_virtual_text(bufnr, -1, i - 1, {
        { 'Entry #' .. entry_number, 'Comment' },
      }, {})
      entry_number = entry_number + 1
    end
  end
end

return M
