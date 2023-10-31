local utils = require('hurl.utils')

local M = {}

local response = {}
local is_running = false

-- Looking for vars.env file base on the current file buffer
-- NOTE: Refactor this later if there is a better way, e.g: define scan folders in the configuration
---@return table
local function get_env_file_in_folders()
  local root_dir = vim.fn.expand('%:p:h')
  local cache_dir = vim.fn.stdpath('cache')
  local env_files = {
    { path = root_dir .. '/vars.env', dest = cache_dir .. '/vars.env' },
  }
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

  for _, s in ipairs(scan_dir) do
    local dir = root_dir .. s.dir
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(env_files, { path = dir .. '/vars.env', dest = cache_dir .. '/vars.env' })
    end
  end

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
local function request(opts, callback)
  if is_running then
    vim.notify('hurl: request is running. Please try again later.', vim.log.levels.INFO)
    return
  end

  is_running = true
  vim.notify('hurl: running request', vim.log.levels.INFO)

  -- Check vars.env exist on the current file buffer
  -- Then inject the command with --variables-file vars.env
  local env_files = get_env_file_in_folders()
  for _, env in ipairs(env_files) do
    if vim.fn.filereadable(env.path) == 1 then
      utils.log_info('hurl: found vars.env ' .. env.path)
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
        vim.fn.setqflist({ { filename = vim.inspect(cmd), text = vim.inspect(response.body) } })
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
  request(opts)
end

--- Run selection
---@param opts table The options
local function run_selection(opts)
  opts = opts or {}
  local lines = utils.get_visual_selection()
  if not lines then
    return
  end
  local fname = utils.create_tmp_file(lines)

  if not fname then
    vim.notify('hurl: create tmp file failed. Please try again!', vim.log.levels.WARN)
    return
  end

  table.insert(opts, fname)
  request(opts)

  -- Clean tmp file after 1s
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

local function find_http_verb_positions_in_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local total_lines = vim.api.nvim_buf_line_count(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line_number = cursor[1]

  local total = 0
  local current = 0

  for i = 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local result = find_http_verb(line)
    if result ~= nil then
      total = total + 1
      if i == current_line_number then
        current = total
      end
    end
  end

  return {
    total = total,
    current = current,
  }
end

function M.setup()
  utils.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })

  utils.create_cmd('HurlRunnerAt', function(opts)
    local result = find_http_verb_positions_in_buffer()
    if result.current > 0 then
      opts.fargs = opts.fargs or {}
      opts.fargs = vim.list_extend(opts.fargs, { '--to-entry', result.current })
      run_current_file(opts.fargs)
    else
      vim.notify('hurl: no http method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })
end

return M
