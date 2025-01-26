local hurl_parser = require('hurl.lib.hurl_parser')
local utils = require('hurl.utils')
local spinner = require('hurl.spinner')
local history = require('hurl.history')

local M = {}
M.is_running = false
M.start_time = nil
M.response = {}

--- Log the Hurl command
---@param cmd table
local function save_last_hurl_command(cmd)
  local command_str = table.concat(cmd, ' ')
  _HURL_GLOBAL_CONFIG.last_hurl_command = command_str
  utils.log_info('hurl: running command: ' .. command_str)
end

--- Save captures as global variables
---@param captures table
local function save_captures_as_globals(captures)
  if _HURL_GLOBAL_CONFIG.save_captures_as_globals and captures then
    for key, value in pairs(captures) do
      _HURL_GLOBAL_CONFIG.global_vars = _HURL_GLOBAL_CONFIG.global_vars or {}
      -- Wrap the value in quotes if it contains spaces
      local formatted_value = value:find('%s') and ('"' .. value .. '"') or value
      _HURL_GLOBAL_CONFIG.global_vars[key] = formatted_value
      utils.log_info(
        string.format('hurl: saved capture %s = %s as global variable', key, formatted_value)
      )
    end
  end
end

--- Run the hurl command in verbose or very verbose mode
---@param filePath string
---@param fromEntry integer
---@param toEntry integer
---@param isVeryVerbose boolean
---@param additionalArgs table
function M.run_hurl_verbose(filePath, fromEntry, toEntry, isVeryVerbose, additionalArgs)
  local args = { filePath }
  table.insert(args, isVeryVerbose and '--very-verbose' or '--verbose')
  if fromEntry then
    table.insert(args, '--from-entry')
    table.insert(args, tostring(fromEntry))
  end
  if toEntry then
    table.insert(args, '--to-entry')
    table.insert(args, tostring(toEntry))
  end

  -- Add additional arguments (like --json)
  if additionalArgs then
    vim.list_extend(args, additionalArgs)
  end

  -- Inject environment variables from .env files
  local env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders()
  for _, env in ipairs(env_files) do
    utils.log_info(
      'hurl: looking for ' .. vim.inspect(_HURL_GLOBAL_CONFIG.env_file) .. ' in ' .. env.path
    )
    if vim.fn.filereadable(env.path) == 1 then
      utils.log_info('hurl: found env file in ' .. env.path)
      table.insert(args, '--variables-file')
      table.insert(args, env.path)
    end
  end

  -- Inject global variables into the command
  if _HURL_GLOBAL_CONFIG.global_vars then
    for var_name, var_value in pairs(_HURL_GLOBAL_CONFIG.global_vars) do
      table.insert(args, '--variable')
      table.insert(args, var_name .. '=' .. var_value)
    end
  end

  -- Inject fixture variables into the command
  if _HURL_GLOBAL_CONFIG.fixture_vars then
    for _, fixture in pairs(_HURL_GLOBAL_CONFIG.fixture_vars) do
      table.insert(args, '--variable')
      table.insert(args, fixture.name .. '=' .. fixture.callback())
    end
  end

  -- Add file root for uploads
  local file_root = _HURL_GLOBAL_CONFIG.file_root or vim.fn.getcwd()
  table.insert(args, '--file-root')
  table.insert(args, file_root)

  local stdout_data = ''
  local stderr_data = ''

  -- Log the Hurl command
  local hurl_command = 'hurl ' .. table.concat(args, ' ')
  save_last_hurl_command({ 'hurl', unpack(args) })

  -- Always use split mode for verbose commands
  local display = require('hurl.split')

  -- Clear the display and show processing message
  display.clear()
  spinner.show()

  local start_time = vim.loop.hrtime()

  -- Start the Hurl command asynchronously
  vim.fn.jobstart({ 'hurl', unpack(args) }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        stdout_data = stdout_data .. table.concat(data, '\n')
      end
    end,
    on_stderr = function(_, data)
      if data then
        stderr_data = stderr_data .. table.concat(data, '\n')
      end
    end,
    on_exit = function(_, code)
      -- Hide the spinner
      spinner.hide()

      local end_time = vim.loop.hrtime()
      local response_time = (end_time - start_time) / 1e6 -- Convert to milliseconds

      local display_data = {
        headers = {},
        body = stderr_data,
        response_time = response_time,
        status = code,
        url = filePath,
        method = 'N/A',
        curl_command = 'N/A',
        hurl_command = hurl_command,
        captures = {},
        timings = {},
      }

      if code ~= 0 then
        utils.log_info('Hurl command failed with code ' .. code)
        display.show({ body = '# Hurl Error\n\n```sh\n' .. stderr_data .. '\n```' }, 'markdown')
        history.update_history(display_data, 'error')
        return
      end

      utils.log_info('Hurl command executed successfully')

      -- Parse the output using the hurl_parser
      local result = hurl_parser.parse_hurl_output(stderr_data, stdout_data)

      -- Format the parsed result
      local output_lines = {}
      table.insert(output_lines, '# Hurl Command')
      table.insert(output_lines, '')
      table.insert(output_lines, '```sh')
      table.insert(output_lines, hurl_command)
      table.insert(output_lines, '```')
      table.insert(output_lines, '')

      for index, entry in ipairs(result.entries) do
        -- Request
        table.insert(output_lines, '# Request #' .. index)
        table.insert(output_lines, '')
        table.insert(output_lines, '## ' .. entry.requestMethod .. ' ' .. entry.requestUrl)
        table.insert(output_lines, '')
        table.insert(output_lines, '## Response: ' .. entry.response.status)

        -- Curl Command
        table.insert(output_lines, '## Curl Command:')
        table.insert(output_lines, '```bash')
        table.insert(output_lines, entry.curlCommand or 'N/A')
        table.insert(output_lines, '```')
        table.insert(output_lines, '')

        -- Headers
        table.insert(output_lines, '### Headers:')
        for key, value in pairs(entry.response.headers) do
          table.insert(output_lines, '- **' .. key .. '**: ' .. value)
        end
        table.insert(output_lines, '')

        -- Body
        table.insert(output_lines, '### Body:')
        table.insert(output_lines, '```json')
        local formatted_body = utils.format(entry.response.body, 'json')
        for _, line in ipairs(formatted_body or {}) do
          table.insert(output_lines, line)
        end
        table.insert(output_lines, '```')

        -- Captures
        if entry.captures and next(entry.captures) then
          table.insert(output_lines, '')
          table.insert(output_lines, '### Captures:')
          for key, value in pairs(entry.captures) do
            table.insert(output_lines, '- **' .. key .. '**: ' .. value)
          end
        end

        -- Timings
        table.insert(output_lines, '')
        table.insert(output_lines, '### Timing:')
        table.insert(
          output_lines,
          string.format('- **Total Response Time**: %.2f ms', response_time)
        )
        if entry.timings then
          for key, value in pairs(entry.timings) do
            table.insert(output_lines, string.format('- **%s**: %s', key, value))
          end
        end

        table.insert(output_lines, '---')

        -- Update history for each entry
        local entry_display_data = {
          headers = entry.response.headers,
          body = entry.response.body,
          response_time = response_time,
          status = entry.response.status,
          url = entry.requestUrl,
          method = entry.requestMethod,
          curl_command = entry.curlCommand,
          hurl_command = hurl_command,
          captures = entry.captures,
          timings = entry.timings,
        }
        history.update_history(entry_display_data)

        -- Save captures as global variables
        save_captures_as_globals(entry.captures)
      end

      -- Show the result using the display module
      display.show({ body = table.concat(output_lines, '\n') }, 'markdown')
    end,
  })
end

--- Execute Hurl command
---@param opts table The options
---@param callback? function The callback function
function M.execute_hurl_cmd(opts, callback)
  -- Check if a request is currently running
  if M.is_running then
    utils.log_info('hurl: request is already running')
    utils.notify('hurl: request is running. Please try again later.', vim.log.levels.INFO)
    return
  end

  M.is_running = true
  M.start_time = vim.loop.hrtime() -- Capture the start time
  spinner.show()
  utils.log_info('hurl: running request')
  utils.notify('hurl: running request', vim.log.levels.INFO)

  local is_json_mode = vim.tbl_contains(opts, '--json')
  local is_file_mode = utils.has_file_in_opts(opts)

  -- Add verbose mode by default if not in JSON mode
  if not is_json_mode and not vim.tbl_contains(opts, '--verbose') then
    table.insert(opts, '--verbose')
  end

  -- Check vars.env exist on the current file buffer
  -- Then inject the command with --variables-file vars.env
  local env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders()
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
      -- If the value is wrapped in quotes, we need to escape it properly
      if var_value:sub(1, 1) == '"' and var_value:sub(-1) == '"' then
        table.insert(opts, var_name .. '=' .. var_value:gsub('"', '\\"'))
      else
        table.insert(opts, var_name .. '=' .. var_value)
      end
    end
  end

  -- Inject fixture variables into the command
  if _HURL_GLOBAL_CONFIG.fixture_vars then
    for _, fixture in pairs(_HURL_GLOBAL_CONFIG.fixture_vars) do
      table.insert(opts, '--variable')
      table.insert(opts, fixture.name .. '=' .. fixture.callback())
    end
  end

  local cmd = vim.list_extend({ 'hurl' }, opts)
  if is_file_mode then
    local file_root = _HURL_GLOBAL_CONFIG.file_root or vim.fn.getcwd()
    vim.list_extend(cmd, { '--file-root', file_root })
  end
  M.response = {}

  save_last_hurl_command(cmd)

  -- Clear the display and show processing message with Hurl command
  local ok, display = pcall(require, 'hurl.' .. (_HURL_GLOBAL_CONFIG.mode or 'split'))
  if not ok then
    utils.notify('Failed to load display module: ' .. display, vim.log.levels.ERROR)
    return
  end
  display.clear()

  local stdout_data = ''
  local stderr_data = ''

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        stdout_data = stdout_data .. table.concat(data, '\n')
      end
    end,
    on_stderr = function(_, data)
      if data then
        stderr_data = stderr_data .. table.concat(data, '\n')
      end
    end,
    on_exit = function(_, code)
      M.is_running = false
      spinner.hide()

      local display_data = {
        headers = {},
        body = stderr_data,
        response_time = (vim.loop.hrtime() - M.start_time) / 1e6, -- Convert to milliseconds
        status = code,
        url = 'N/A',
        method = 'N/A',
        curl_command = 'N/A',
        hurl_command = table.concat(cmd, ' '),
        captures = {},
        timings = {},
      }

      if code ~= 0 then
        utils.log_error('Hurl command failed with code ' .. code)
        utils.notify('Hurl command failed. Check the split view for details.', vim.log.levels.ERROR)

        -- Show error in split view
        local split = require('hurl.split')
        local error_data = {
          body = '# Hurl Error\n\n```sh\n' .. stderr_data .. '\n```',
          headers = {},
          method = 'ERROR',
          url = 'N/A',
          status = code,
          response_time = 0,
          curl_command = 'N/A',
        }
        split.show(error_data, 'markdown')
        history.update_history(display_data, 'error')
        return
      end

      utils.log_info('hurl: request finished')
      utils.notify('hurl: request finished', vim.log.levels.INFO)

      -- Calculate the response time
      local end_time = vim.loop.hrtime()
      M.response.response_time = (end_time - M.start_time) / 1e6 -- Convert to milliseconds

      if is_json_mode then
        M.response.body = stdout_data
        M.response.display_type = 'json'
        if callback then
          return callback(M.response)
        end
      else
        -- Parse the output using the hurl_parser
        local result = hurl_parser.parse_hurl_output(stderr_data, stdout_data)

        -- Display the result using popup or split based on the configuration
        local container = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)

        -- Prepare the data for display
        local last_entry = result.entries[#result.entries]
        local entry_display_data = {
          headers = last_entry.response.headers,
          body = last_entry.response.body,
          response_time = M.response.response_time,
          status = last_entry.response.status,
          url = last_entry.requestUrl,
          method = last_entry.requestMethod,
          curl_command = last_entry.curlCommand,
        }

        -- Separate headers from body
        local body_start = entry_display_data.body:find('\n\n')
        if body_start then
          local headers_str = entry_display_data.body:sub(1, body_start - 1)
          entry_display_data.body = entry_display_data.body:sub(body_start + 2)

          -- Parse additional headers from the body
          for header in headers_str:gmatch('([^\n]+)') do
            local key, value = header:match('([^:]+):%s*(.*)')
            if key and value then
              entry_display_data.headers[key] = value
            end
          end
        end

        -- Determine the content type
        local content_type = entry_display_data.headers['Content-Type']
          or entry_display_data.headers['content-type']
          or 'text/plain'

        local display_type = 'text'
        if content_type:find('json') then
          display_type = 'json'
        elseif content_type:find('html') then
          display_type = 'html'
        elseif content_type:find('xml') then
          display_type = 'xml'
        end

        entry_display_data.display_type = display_type

        container.show(entry_display_data, display_type)

        history.update_history(entry_display_data)

        -- Save captures as global variables
        if result.entries and #result.entries > 0 then
          save_captures_as_globals(result.entries[#result.entries].captures)
        end
      end
    end,
  })
end

return M
