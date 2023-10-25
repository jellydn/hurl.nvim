local util = require('hurl.utils')

local M = {}

local response = {}

--- Output handler
---@class Output
local on_output = function(code, data, event)
  util.log_info('hurl: code ', code)
  local head_state
  if data[1] == '' then
    table.remove(data, 1)
  end
  if not data[1] then
    return
  end

  if event == 'stderr' and #data > 1 then
    response.body = data
    util.log_error(vim.inspect(data))
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

  util.log_info('hurl: response status ' .. response.status)
  util.log_info('hurl: response headers ' .. vim.inspect(response.headers))
  util.log_info('hurl: response body ' .. response.body)
end

--- Call hurl command
---@param opts table The options
---@param callback? function The callback function
local function request(opts, callback)
  vim.notify('hurl: running request', vim.log.levels.INFO)
  local cmd = vim.list_extend({ 'hurl', '-i', '--no-color' }, opts)
  response = {}

  vim.fn.jobstart(cmd, {
    on_stdout = on_output,
    on_stderr = on_output,
    on_exit = function(i, code)
      util.log_info('exit at ' .. i .. ' , code ' .. code)
      if code ~= 0 then
        -- Send error code and response to quickfix and open it
        vim.fn.setqflist({ { filename = '', text = vim.inspect(response.body) } })
        vim.cmd('copen')
      end

      if callback then
        return callback(response)
      else
        -- show messages
        local lines = response.raw or response.body
        if #lines == 0 then
          return
        end

        local container = require('hurl.' .. _HURL_CFG.mode)
        --show body if it is json
        if util.is_json_response(response.headers['content-type']) then
          container.show(response, 'json')
        else
          if util.is_html_response(response.headers['content-type']) then
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
  local lines = util.get_visual_selection()
  if not lines then
    return
  end
  local fname = util.create_tmp_file(lines)

  if not fname then
    return
  end

  table.insert(opts, fname)
  request(opts)
  vim.defer_fn(function()
    os.remove(fname)
  end, 1000)
end

function M.setup()
  util.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })
end

return M
