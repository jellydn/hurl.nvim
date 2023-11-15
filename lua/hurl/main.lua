local utils = require('hurl.utils')
local M = {}
local response = {}
local is_running = false
--- Check if the current directory is a git repo
---@return boolean
local function is_git_repo()
  vim.fn.system('git rev-parse --is-inside-work-tree')
  return vim.v.shell_error == 0
end
--- Get the git root directory
---@return string|nil The git root directory
local function get_git_root()
  local dot_git_path = vim.fn.finddir('.git', '.;')
  return vim.fn.fnamemodify(dot_git_path, ':h')
end
local function split_path(path)
  local parts = {}
  for part in string.gmatch(path, '[^/]+') do
    table.insert(parts, part)
  end
  return parts
end
-- Looking for vars.env file base on the current file buffer
---@return table
local function find_env_files_in_folders()
  local root_dir = vim.fn.expand('%:p:h')
  local cache_dir = vim.fn.stdpath('cache')
  local current_file_dir = vim.fn.expand('%:p:h:h')
  local env_files = {
    {
      path = root_dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
      dest = cache_dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
    },
  }
  -- NOTE: it may be better to use a user config to define the scan directories
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

  -- Scan git root directory and all sub directories with the current file buffer
  if is_git_repo() then
    local git_root = get_git_root()
    table.insert(env_files, {
      path = git_root .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
      dest = cache_dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
    })

    local git_root_parts = split_path(git_root)
    local current_dir_parts = split_path(current_file_dir)
    local sub_path = git_root

    for i = #git_root_parts + 1, #current_dir_parts do
      sub_path = sub_path .. '/' .. current_dir_parts[i]
      table.insert(env_files, {
        path = sub_path .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
        dest = cache_dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
      })
    end
  end

  for _, s in ipairs(scan_dir) do
    local dir = root_dir .. s.dir
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(env_files, {
        path = dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
        dest = cache_dir .. '/' .. _HURL_GLOBAL_CONFIG.env_file,
      })
    end
  end

  -- sort by path length, the current buffer file path will be the first
  table.sort(env_files, function(a, b)
    return #a.path > #b.path
  end)

  return env_files
end

--- Output handler
---@class Output
local on_output = function(code, data, event)
  local head_state
  if data[1] == '' then
    table.remove(data, 1)
  end
  if not data[1] then
    return
  end
  if event == 'stderr' and #data > 1 then
    response.body = data
    utils.log_error(vim.inspect(data))
    response.raw = data
    response.headers = {}
    return
  end

  local status = tonumber(string.match(data[1], '([%w+]%d+)'))
  head_state = 'start'
  if status then
    response.status = status
    response.headers = { status = data[1] }
    response.headers_str = data[1] .. '\r\n'
  end

  for i = 2, #data do
    local line = data[i]
    if line == '' or line == nil then
      head_state = 'body'
    elseif head_state == 'start' then
      local key, value = string.match(line, '([%w-]+):%s*(.+)')
      if key and value then
        response.headers[key] = value
        response.headers_str = response.headers_str .. line .. '\r\n'
      end
    elseif head_state == 'body' then
      response.body = response.body or ''
      response.body = response.body .. line
    end
  end
  response.raw = data

  utils.log_info('hurl: response status ' .. response.status)
  utils.log_info('hurl: response headers ' .. vim.inspect(response.headers))
  utils.log_info('hurl: response body ' .. response.body)
end

--- Call hurl command
---@param opts table The options
---@param callback? function The callback function
local function execute_hurl_cmd(opts, callback)
  -- Check if a request is currently running
  if is_running then
    vim.notify('hurl: request is running. Please try again later.', vim.log.levels.INFO)
    return
  end

  is_running = true
  vim.notify('hurl: running request', vim.log.levels.INFO)

  -- Check vars.env exist on the current file buffer
  -- Then inject the command with --variables-file vars.env
  local env_files = find_env_files_in_folders()
  for _, env in ipairs(env_files) do
    utils.log_info('hurl: looking for ' .. _HURL_GLOBAL_CONFIG.env_file .. ' in ' .. env.path)
    if vim.fn.filereadable(env.path) == 1 then
      utils.log_info('hurl: found ' .. _HURL_GLOBAL_CONFIG.env_file .. ' in ' .. env.path)
      table.insert(opts, '--variables-file')
      table.insert(opts, env.path)
      break
    end
  end

  local cmd = vim.list_extend({ 'hurl', '-i', '--no-color' }, opts)
  response = {}

  utils.log_info('hurl: running command' .. vim.inspect(cmd))
  vim.fn.jobstart(cmd, {
    on_stdout = on_output,
    on_stderr = on_output,
    on_exit = function(i, code)
      utils.log_info('exit at ' .. i .. ' , code ' .. code)
      is_running = false
      if code ~= 0 then
        -- Send error code and response to quickfix and open it
        -- It should display the error message
        vim.fn.setqflist({}, 'r', {
          title = 'hurl',
          lines = response.raw or response.body,
        })
        vim.fn.setqflist({}, 'a', {
          title = 'hurl',
          lines = { response.headers_str },
        })
        vim.cmd('copen')
        return
      end

      vim.notify('hurl: request finished', vim.log.levels.INFO)

      if callback then
        return callback(response)
      else
        -- show messages
        local lines = response.raw or response.body
        if #lines == 0 then
          return
        end

        local container = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)
        local content_type = response.headers['content-type']
          or response.headers['Content-Type']
          or ''

        utils.log_info('Detected content type: ' .. content_type)

        if utils.is_json_response(content_type) then
          container.show(response, 'json')
        else
          if utils.is_html_response(content_type) then
            container.show(response, 'html')
          else
            container.show(response, 'text')
          end
        end
      end
    end,
  })
end
--- Run current file
--- It will throw an error if that is not valid hurl file
---@param opts table The options
local function run_current_file(opts)
  opts = opts or {}
  table.insert(opts, vim.fn.expand('%:p'))
  execute_hurl_cmd(opts)
end

--- Create a temporary file with the lines to run
---@param lines string[]
---@param opts table The options
local function run_lines(lines, opts)
  -- Create a temporary file with the lines to run
  local fname = utils.create_tmp_file(lines)
  if not fname then
    vim.notify('hurl: create tmp file failed. Please try again!', vim.log.levels.WARN)
    return
  end

  -- Add the temporary file to the arguments
  table.insert(opts, fname)
  execute_hurl_cmd(opts)

  -- Clean up the temporary file after a delay
  local timeout = 1000
  vim.defer_fn(function()
    local success = os.remove(fname)
    if not success then
      vim.notify('hurl: remove file failed', vim.log.levels.WARN)
    else
      utils.log_info('hurl: remove file success ' .. fname)
    end
  end, timeout)
end

--- Run selection
---@param opts table The options
local function run_selection(opts)
  opts = opts or {}
  local lines = utils.get_visual_selection()
  if not lines then
    return
  end

  run_lines(lines, opts)
end

--- Run at current line
---@param start_line number
---@param end_line number
---@param opts table
local function run_at_lines(start_line, end_line, opts)
  opts = opts or {}
  -- Get the lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if not lines or vim.tbl_isempty(lines) then
    vim.notify('hurl: no lines to run', vim.log.levels.WARN)
    return
  end

  run_lines(lines, opts)
end

local function find_http_verb(line, current_line_number)
  if not line then
    return nil
  end

  local verbs = { 'GET', 'POST', 'PUT', 'DELETE', 'PATCH' }
  local verb_start, verb_end, verb

  for _, v in ipairs(verbs) do
    verb_start, verb_end = line:find(v)
    if verb_start then
      verb = v
      break
    end
  end

  if verb_start then
    return {
      line_number = current_line_number,
      start_pos = verb_start,
      end_pos = verb_end,
      method = verb,
    }
  else
    return nil
  end
end

--- Find the HTTP verbs in the current buffer
---@return table
local function find_http_verb_positions_in_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local total_lines = vim.api.nvim_buf_line_count(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line_number = cursor[1]

  local next_entry = 0
  local current_index = 0
  local current_verb = nil
  local end_line = total_lines -- Default to the last line of the buffer

  for i = 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local result = find_http_verb(line, i)
    if result then
      next_entry = next_entry + 1
      if i == current_line_number then
        current_index = next_entry
        current_verb = result
      elseif current_verb and i > current_verb.line_number then
        end_line = i - 1 -- The end line of the current verb is the line before the next verb starts
        break -- No need to continue once the end line of the current verb is found
      end
    end
  end

  if current_verb and current_index == next_entry then
    -- If the current verb is the last one, the end line is the last line of the buffer
    end_line = total_lines
  end

  return {
    current = current_index,
    start_line = current_verb and current_verb.line_number or nil,
    end_line = end_line,
  }
end

function M.setup()
  -- Run request for a range of lines or the entire file
  utils.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      utils.log_info('hurl: running current file')
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })

  -- Toggle mode between split and popup
  utils.create_cmd('HurlToggleMode', function()
    local mode = _HURL_GLOBAL_CONFIG.mode
    if mode == 'split' then
      _HURL_GLOBAL_CONFIG.mode = 'popup'
    else
      _HURL_GLOBAL_CONFIG.mode = 'split'
    end
    vim.notify('hurl: mode changed to ' .. _HURL_GLOBAL_CONFIG.mode, vim.log.levels.INFO)
  end, { nargs = '*', range = true })

  -- Run request at current line if there is a HTTP method
  utils.create_cmd('HurlRunnerAt', function(opts)
    local result = find_http_verb_positions_in_buffer()
    if result.current > 0 and result.start_line and result.end_line then
      utils.log_info(
        'hurl: running request at line ' .. result.start_line .. ' to ' .. result.end_line
      )
      run_at_lines(result.start_line, result.end_line, opts.fargs)
    else
      vim.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Run request to current entry if there is a HTTP method
  utils.create_cmd('HurlRunnerToEntry', function(opts)
    local result = find_http_verb_positions_in_buffer()
    if result.current > 0 then
      opts.fargs = opts.fargs or {}
      opts.fargs = vim.list_extend(opts.fargs, { '--to-entry', result.current })
      utils.log_info('hurl: running request to entry #' .. vim.inspect(result))
      run_current_file(opts.fargs)
    else
      vim.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Add new command to change env file with input
  utils.create_cmd('HurlSetEnvFile', function(opts)
    local env_file = opts.fargs[1]
    if not env_file then
      vim.notify('hurl: please provide the env file name', vim.log.levels.INFO)
      return
    end
    _HURL_GLOBAL_CONFIG.env_file = env_file
    vim.notify('hurl: env file changed to ' .. _HURL_GLOBAL_CONFIG.env_file, vim.log.levels.INFO)
  end, { nargs = '*', range = true })
end

return M
