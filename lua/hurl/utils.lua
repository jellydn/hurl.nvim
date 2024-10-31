local log = require('hurl.vlog')
local git = require('hurl.git_utils')

local M = {}

--- Get the log file path
---@return string
M.get_log_file_path = function()
  return log.get_log_file()
end

--- Log info
---@vararg any
M.log_info = function(...)
  -- Only save log when debug is on
  if not _HURL_GLOBAL_CONFIG.debug then
    return
  end

  log.info(...)
end

--- Log error
---@vararg any
M.log_error = function(...)
  -- Only save log when debug is on
  if not _HURL_GLOBAL_CONFIG.debug then
    return
  end

  log.error(...)
end

--- Show info notification
---@vararg any
M.notify = function(...)
  --  Ignore if the flag is off
  if not _HURL_GLOBAL_CONFIG.show_notification then
    return
  end

  vim.notify(...)
end

--- Get visual selection
---@return string[]
M.get_visual_selection = function()
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
M.create_tmp_file = function(content)
  -- create temp file base on pid and datetime
  local tmp_file = string.format(
    '%s/%s.hurl',
    vim.fn.stdpath('cache'),
    vim.fn.getpid() .. '-' .. vim.fn.localtime()
  )

  if not tmp_file then
    M.lor_error('hurl: failed to create tmp file')
    M.notify('hurl: failed to create tmp file', vim.log.levels.ERROR)
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
M.create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'hurl.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

--- Format the body of the request
---@param body string
---@param type 'json' | 'html' | 'xml' | 'text'
---@return string[] | nil
M.format = function(body, type)
  local formatters = _HURL_GLOBAL_CONFIG.formatters
    or {
      json = { 'jq' },
      html = { 'prettier', '--parser', 'html' },
      xml = { 'tidy', '-xml', '-i', '-q' },
    }

  -- If no formatter is defined, return the body
  if not formatters[type] then
    return vim.split(body, '\n')
  end

  M.log_info('formatting body with ' .. type)
  local stdout = vim.fn.systemlist(formatters[type], body)
  if vim.v.shell_error ~= 0 then
    M.log_error('formatter failed' .. vim.v.shell_error)
    return vim.split(body, '\n')
  end

  if stdout == nil or #stdout == 0 then
    M.log_info('formatter returned empty body')
    return vim.split(body, '\n')
  end

  M.log_info('formatted body: ' .. table.concat(stdout, '\n'))
  return stdout
end

--- Check if nvim is running in nightly or stable version
---@return boolean
M.is_nightly = function()
  local is_stable_version = false
  if vim.fn.has('nvim-0.11.0') == 1 then
    is_stable_version = true
  end

  return is_stable_version
end

--- Check if a treesitter parser is available
---@param ft string
---@return boolean
local function treesitter_parser_available(ft)
  local res, parser = pcall(vim.treesitter.get_parser, 0, ft)
  return res and parser ~= nil
end

M.is_hurl_parser_available = treesitter_parser_available('hurl')

-- Looking for vars.env file base on the current file buffer
---@return table
local function find_env_files(file, root_dir, cache_dir, current_file_dir, scan_dir)
  local files = {
    {
      path = root_dir .. '/' .. file,
      dest = cache_dir .. '/' .. file,
    },
  }

  -- Scan git root directory and all sub directories with the current file buffer
  if git.is_git_repo() then
    local git_root = git.get_git_root()

    table.insert(files, {
      path = git_root .. '/' .. file,
      dest = cache_dir .. '/' .. file,
    })

    local git_root_parts = git.split_path(git_root)
    local current_dir_parts = git.split_path(current_file_dir)
    local sub_path = git_root

    for i = #git_root_parts + 1, #current_dir_parts do
      sub_path = sub_path .. '/' .. current_dir_parts[i]

      table.insert(files, {
        path = sub_path .. '/' .. file,
        dest = cache_dir .. '/' .. file,
      })
    end
  end

  for _, s in ipairs(scan_dir) do
    local dir = root_dir .. s.dir
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(files, {
        path = dir .. '/' .. file,
        dest = cache_dir .. '/' .. file,
      })
    end
  end

  -- sort by path length, the current buffer file path will be the first
  table.sort(files, function(a, b)
    return #a.path > #b.path
  end)
  return files
end

-- Looking for vars.env file base on the current file buffer
---@return table
M.find_env_files_in_folders = function()
  local root_dir = vim.fn.expand('%:p:h')
  local cache_dir = vim.fn.stdpath('cache')
  local current_file_dir = vim.fn.expand('%:p:h:h')
  local env_files = {}

  local scan_dir = {
    {
      dir = '/src',
    },
    {
      dir = '/test',
    },
    {
      dir = '/tests',
    },
    {
      dir = '/server',
    },
    {
      dir = '/src/tests',
    },
    {
      dir = '/server/tests',
    },
  }

  for _, file in ipairs(_HURL_GLOBAL_CONFIG.env_file) do
    local env_file = find_env_files(file, root_dir, cache_dir, current_file_dir, scan_dir)
    vim.list_extend(env_files, env_file)
  end

  return env_files
end

M.has_file_in_opts = function(opts)
  if #opts == 0 then
    M.log_error('No file path provided in opts.')
    return false
  end

  local file_path = opts[1]

  local file = io.open(file_path, 'r')
  if not file then
    M.log_error('Error: Failed to open file: ' .. file_path)
    vim.notify('Error: Failed to open file: ' .. file_path, vim.log.levels.ERROR)
    return false
  end

  for line in file:lines() do
    if line:lower():find('file') or line:lower():find('multipart') then
      file:close() -- Close the file before returning
      return true -- Return true if any line contains the keyword
    end
  end

  file:close()

  return false
end

return M
