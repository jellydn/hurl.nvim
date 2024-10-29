local M = {}

-- Add virtual text for Hurl entries by finding HTTP verbs
function M.add_virtual_text_for_hurl_entries()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Create a dedicated namespace for Hurl entry markers
  local ns_id = vim.api.nvim_create_namespace('hurl_entries')

  -- Clear existing virtual text before adding new ones
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Define all supported HTTP methods
  local http_methods = {
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'HEAD',
    'OPTIONS',
  }

  local entry_number = 1
  for i, line in ipairs(lines) do
    -- Match any HTTP method, ignoring preceding whitespace and comments
    local method = line:match('^%s*#?%s*([A-Z]+)')
    if method and vim.tbl_contains(http_methods, method) then
      vim.api.nvim_buf_set_virtual_text(bufnr, ns_id, i - 1, {
        { 'Entry #' .. entry_number, 'Comment' },
      }, {})
      entry_number = entry_number + 1
    end
  end
end

-- Setup function to attach buffer autocmd
function M.setup()
  local group = vim.api.nvim_create_augroup('HurlEntryMarkers', { clear = true })

  -- Handle buffer events
  vim.api.nvim_create_autocmd({
    'BufEnter',
    'TextChanged',
    'InsertLeave',
  }, {
    group = group,
    pattern = '*.hurl',
    callback = function()
      M.add_virtual_text_for_hurl_entries()
    end,
  })
end

return M
