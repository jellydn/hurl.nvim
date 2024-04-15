local utils = require('hurl.utils')
local git = require('hurl.git_utils')
local http = require('hurl.http_utils')
local spinner = require('hurl.spinner')

local M = {}

local response = {}
local head_state = ''
local is_running = false

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
local function find_env_files_in_folders()
  local root_dir = vim.fn.expand('%:p:h')
  local cache_dir = vim.fn.stdpath('cache')
  local current_file_dir = vim.fn.expand('%:p:h:h')
  local env_files = {}

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

  for _, file in ipairs(_HURL_GLOBAL_CONFIG.env_file) do
    local temp_file = find_env_files(file, root_dir, cache_dir, current_file_dir, scan_dir)
    vim.list_extend(env_files, temp_file)
  end

  return env_files
end

--- Output handler
---@class Output
local on_output = function(code, data, event)
  utils.log_info('hurl: on_output ' .. vim.inspect(code) .. vim.inspect(data))

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

  if head_state == 'body' then
    -- Append the data to the body if we are in the body state
    utils.log_info('hurl: append data to body' .. vim.inspect(data))
    response.body = response.body or ''
    response.body = response.body .. table.concat(data, '\n')
    return
  end

  -- TODO: The header parser sometime not working properly, e.g: https://google.com
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
  if response.body then
    utils.log_info('hurl: response body ' .. response.body)
  else
    -- Fall back to empty string for non-body responses
    response.body = ''
  end
end

--- Call hurl command
---@param opts table The options
---@param callback? function The callback function
local function execute_hurl_cmd(opts, callback)
  -- Check if a request is currently running
  if is_running then
    utils.log_info('hurl: request is already running')
    utils.notify('hurl: request is running. Please try again later.', vim.log.levels.INFO)
    return
  end

  is_running = true
  spinner.show()
  head_state = ''
  utils.log_info('hurl: running request')
  utils.notify('hurl: running request', vim.log.levels.INFO)

  local is_verbose_mode = vim.tbl_contains(opts, '--verbose')
  if not _HURL_GLOBAL_CONFIG.auto_close and not is_verbose_mode and response.body then
    local container = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)
    utils.log_info('hurl: clear previous response if this is not auto close')
    container.clear()
  end

  -- Check vars.env exist on the current file buffer
  -- Then inject the command with --variables-file vars.env
  local env_files = find_env_files_in_folders()
  for _, env in ipairs(env_files) do
    utils.log_info(
      'hurl: looking for ' .. vim.inspect(_HURL_GLOBAL_CONFIG.env_file) .. ' in ' .. env.path
    )
    if vim.fn.filereadable(env.path) == 1 then
      utils.log_info('hurl: found env file in ' .. env.path)
      table.insert(opts, '--variables-file')
      table.insert(opts, env.path)
    end
  end

  -- Inject global variables into the command
  if _HURL_GLOBAL_CONFIG.global_vars then
    for var_name, var_value in pairs(_HURL_GLOBAL_CONFIG.global_vars) do
      table.insert(opts, '--variable')
      table.insert(opts, var_name .. '=' .. var_value)
    end
  end

  local cmd = vim.list_extend({ 'hurl', '-i', '--no-color' }, opts)
  response = {}

  utils.log_info('hurl: running command' .. vim.inspect(cmd))

  -- Parse [Captures] section and update global variables
  if _HURL_GLOBAL_CONFIG.captures then
    for capture_name, capture_method in pairs(_HURL_GLOBAL_CONFIG.captures) do
      local captured_value = nil -- Placeholder for capture extraction logic
      -- TODO: Implement capture extraction logic based on capture_method

      if captured_value then
        _HURL_GLOBAL_CONFIG.global_vars = _HURL_GLOBAL_CONFIG.global_vars or {}
        _HURL_GLOBAL_CONFIG.global_vars[capture_name] = captured_value
        utils.log_info('hurl: captured variable ' .. capture_name .. ' set to ' .. captured_value)
        utils.notify('hurl: captured variable ' .. capture_name .. ' set to ' .. captured_value, vim.log.levels.INFO)
      else
        utils.log_error('hurl: failed to capture variable ' .. capture_name)
        utils.notify('hurl: failed to capture variable ' .. capture_name, vim.log.levels.ERROR)
      end
    end
  end

  vim.fn.jobstart(cmd, {
    on_stdout = callback or on_output,
    on_stderr = callback or on_output,
    on_exit = function(i, code)
      utils.log_info('exit at ' .. i .. ' , code ' .. code)
      is_running = false
      spinner.hide()
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

      utils.log_info('hurl: request finished')
      utils.notify('hurl: request finished', vim.log.levels.INFO)

      if callback then
        return callback(response)
      else
        -- show messages
        local lines = response.raw or response.body
        if #lines == 0 then
          return
        end

        local content_type = response.headers['content-type']
          or response.headers['Content-Type']
          or response.headers['Content-type']
          or 'unknown'

        utils.log_info('Detected content type: ' .. content_type)
        if response.headers['content-length'] == '0' then
          utils.log_info('hurl: empty response')
          utils.notify('hurl: empty response', vim.log.levels.INFO)
        end

        local container = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)
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
---@param callback? function The callback function
local function run_lines(lines, opts, callback)
  -- Create a temporary file with the lines to run
  local fname = utils.create_tmp_file(lines)
  if not fname then
    utils.log_warn('hurl: create tmp file failed')
    utils.notify('hurl: create tmp file failed. Please try again!', vim.log.levels.WARN)
    return
  end

  -- Add the temporary file to the arguments
  table.insert(opts, fname)
  execute_hurl_cmd(opts, callback)

  -- Clean up the temporary file after a delay
  local timeout = 1000
  vim.defer_fn(function()
    local success = os.remove(fname)
    if not success then
      utils.log_info('hurl: remove file failed ' .. fname)
      utils.notify('hurl: remove file failed', vim.log.levels.WARN)
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
---@param callback? function
local function run_at_lines(start_line, end_line, opts, callback)
  opts = opts or {}
  -- Get the lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if not lines or vim.tbl_isempty(lines) then
    utils.notify('hurl: no lines to run', vim.log.levels.WARN)
    return
  end

  run_lines(lines, opts, callback)
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
    utils.log_info('hurl: mode changed to ' .. _HURL_GLOBAL_CONFIG.mode)
    utils.notify('hurl: mode changed to ' .. _HURL_GLOBAL_CONFIG.mode, vim.log.levels.INFO)
  end, { nargs = '*', range = true })

  -- Run request at current line if there is a HTTP method
  utils.create_cmd('HurlRunnerAt', function(opts)
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    if result.current > 0 and result.start_line and result.end_line then
      utils.log_info(
        'hurl: running request at line ' .. result.start_line .. ' to ' .. result.end_line
      )
      run_at_lines(result.start_line, result.end_line, opts.fargs)
    else
      utils.log_info('hurl: not HTTP method found in the current line' .. result.start_line)
      utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Run request to current entry if there is a HTTP method
  utils.create_cmd('HurlRunnerToEntry', function(opts)
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    utils.log_info('hurl: running request to entry #' .. vim.inspect(result))
    if result.current > 0 then
      run_at_lines(1, result.end_line, opts.fargs)
    else
      utils.log_info('hurl: not HTTP method found in the current line' .. result.end_line)
      utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Add new command to change env file with input
  utils.create_cmd('HurlSetEnvFile', function(opts)
    local env_file = opts.fargs[1]
    if not env_file then
      utils.log_info('hurl: please provide the env file name')
      utils.notify('hurl: please provide the env file name', vim.log.levels.INFO)
      return
    end
    _HURL_GLOBAL_CONFIG.env_file = vim.split(env_file, ',')
    local updated_env = vim.inspect(_HURL_GLOBAL_CONFIG.env_file)
    utils.log_info('hurl: env file changed to ' .. updated_env)
    utils.notify('hurl: env file changed to ' .. updated_env, vim.log.levels.INFO)
  end, { nargs = '*', range = true })

  -- Run Hurl in verbose mode and send output to quickfix
  utils.create_cmd('HurlVerbose', function(opts)
    -- It should be the same logic with run at current line but with verbose flag
    -- The response will be sent to quickfix
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    if result.current > 0 and result.start_line and result.end_line then
      utils.log_info(
        'hurl: running request at line ' .. result.start_line .. ' to ' .. result.end_line
      )
      opts.fargs = opts.fargs or {}
      opts.fargs = vim.list_extend(opts.fargs, { '--verbose' })

      -- Clear quickfix list
      vim.fn.setqflist({}, 'r', {
        title = 'hurl',
        lines = {},
      })
      run_at_lines(1, result.end_line, opts.fargs, function(code, data, event)
        utils.log_info('hurl: verbose callback ' .. vim.inspect(code) .. vim.inspect(data))
        vim.fn.setqflist({}, 'a', {
          title = 'hurl - data',
          lines = data,
        })
        vim.fn.setqflist({}, 'a', {
          title = 'hurl - event',
          lines = event,
        })
        vim.cmd('copen')
      end)
    else
      if result then
        utils.log_info('hurl: not HTTP method found in the current line' .. result.start_line)
        utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
      end
    end
  end, { nargs = '*', range = true })

  utils.create_cmd('HurlSetVariable', function(opts)
    local var_name = opts.fargs[1]
    local var_value = opts.fargs[2]
    if not var_name or not var_value then
      utils.log_info('hurl: please provide the variable name and its value')
      utils.notify('hurl: please provide the variable name and its value', vim.log.levels.INFO)
      return
    end
    _HURL_GLOBAL_CONFIG.global_vars = _HURL_GLOBAL_CONFIG.global_vars or {}
    _HURL_GLOBAL_CONFIG.global_vars[var_name] = var_value
    utils.log_info('hurl: global variable ' .. var_name .. ' set to ' .. var_value)
    utils.notify(
      'hurl: global variable ' .. var_name .. ' set to ' .. var_value,
      vim.log.levels.INFO
    )
  end, { nargs = '*', range = true })

  -- Show all global variables
  utils.create_cmd('HurlManageVariable', function()
    -- Prepare the lines to display in the popup
    local lines = {}
    if not _HURL_GLOBAL_CONFIG.global_vars or vim.tbl_isempty(_HURL_GLOBAL_CONFIG.global_vars) then
      utils.log_info('hurl: no global variables set')
      utils.notify('hurl: no global variables set', vim.log.levels.INFO)
      table.insert(lines, 'No global variables set. Please use :HurlSetVariable to set one.')
    else
      for var_name, var_value in pairs(_HURL_GLOBAL_CONFIG.global_vars) do
        table.insert(lines, var_name .. ' = ' .. var_value)
      end
    end

    local popup = require('hurl.popup')
    popup.show_text('Hurl.nvim - Global variables', lines)
  end, {
    nargs = '*',
    range = true,
  })

  -- Show debug info
  utils.create_cmd('HurlDebugInfo', function()
    -- Get the log file path
    local log_file_path = utils.get_log_file_path()
    local lines = { 'Log file path: ' .. log_file_path }
    local popup = require('hurl.popup')
    popup.show_text('Hurl.nvim - Debug info', lines)
  end, {
    nargs = '*',
    range = true,
  })
end

return M
