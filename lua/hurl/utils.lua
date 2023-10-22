local log = require('hurl.vlog')

local util = {}

--- Log function
--- Print the variable to stdout
---@vararg any
util.log = function(...)
  -- Only print when debug is on
  if not _HURL_CFG.debug then
    return
  end

  log.info(...)
end

--- Get visual selection
---@return string[]
util.get_visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return lines
end

--- Create tmp file
---@param content any
---@return string|nil
util.create_tmp_file = function(content)
  local tmp_file = vim.fn.tempname()
  if not tmp_file then
    return
  end

  local f = io.open(tmp_file, 'w')
  if not f then
    return
  end
  if type(content) == 'table' then
    local c = vim.fn.join(content, '\n')
    f:write(c)
  else
    f:write(content)
  end
  f:close()
  return tmp_file
end

--- Create custom command
---@param cmd string The command name
---@param func function The function to execute
---@param opt table The options
util.create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'hurl.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

--- Format the body of the request
---@param body string
---@param type 'json' | 'html'
---@return string[] | nil
util.format = function(body, type)
  local formatters = { json = 'jq', html = { 'prettier', '--parser', 'html' } }
  local stdout = vim.fn.systemlist(formatters[type], body)
  if vim.v.shell_error ~= 0 then
    util.log('formatter failed' .. tostring(vim.v.shell_error))
    return nil
  end
  return stdout
end

--- Render header table
---@param headers table
util.render_header_table = function(headers)
  local result = {}
  local maxKeyLength = 0
  for k, _ in pairs(headers) do
    maxKeyLength = math.max(maxKeyLength, #k)
  end

  local line = 0
  for k, v in pairs(headers) do
    line = line + 1
    if line == 1 then
      -- Add header for the table view
      table.insert(
        result,
        string.format('%-' .. maxKeyLength .. 's | %s', 'Header Key', 'Header Value')
      )

      line = line + 1
    end
    table.insert(result, string.format('%-' .. maxKeyLength .. 's | %s', k, v))
  end

  return {
    line = line,
    headers = result,
  }
end

return util
