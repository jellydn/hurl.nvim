local M = {}

local function trim(s)
  return s:match('^%s*(.-)%s*$')
end

function M.parse_hurl_output(stderr, stdout)
  local lines = {}
  for line in stderr:gmatch('[^\r\n]+') do
    table.insert(lines, line)
  end

  local entries = {}
  local currentEntry = nil
  local isResponseHeader = false
  local isTimings = false
  local isCaptures = false
  local isError = false

  for i, line in ipairs(lines) do
    if line:find('^%* Executing entry') then
      if currentEntry then
        table.insert(entries, currentEntry)
      end
      currentEntry = {
        requestMethod = '',
        requestUrl = '',
        requestHeaders = {},
        response = {
          status = '',
          headers = {},
          body = '',
        },
        timings = {},
        captures = {},
        error = nil,
      }
      isResponseHeader = false
      isTimings = false
      isCaptures = false
      isError = false
    elseif line:find('^%* Request:') then
      -- Check the next line for the actual request details
      if i < #lines then
        local nextLine = lines[i + 1]
        local method, url = nextLine:match('^%* (%w+)%s+(.+)')
        if method and url and currentEntry then
          currentEntry.requestMethod = method
          currentEntry.requestUrl = url
        end
      end
    elseif line:find('^error:') then
      isError = true
      currentEntry.error = line:sub(8) -- Remove "error: " prefix
    elseif isError then
      -- Append additional error information
      currentEntry.error = currentEntry.error .. '\n' .. line
    elseif line:find('^%* curl') then
      if currentEntry then
        currentEntry.curlCommand = trim(line:sub(3))
      end
    elseif line:find('^> ') then
      local key, value = line:sub(3):match('([^:]+):%s*(.+)')
      if key and value and currentEntry then
        currentEntry.requestHeaders[trim(key)] = trim(value)
      end
    elseif line:find('^< ') then
      isResponseHeader = true
      if line:find('^< HTTP/') then
        if currentEntry then
          currentEntry.response.status = line:sub(3)
        end
      else
        local key, value = line:sub(3):match('([^:]+):%s*(.+)')
        if key and value and currentEntry then
          currentEntry.response.headers[trim(key)] = trim(value)
        end
      end
    elseif line:find('^%* Timings:') then
      isTimings = true
    elseif isTimings and trim(line) ~= '' then
      local cleanedLine = line:find('^%* ') and line:sub(3) or line
      local key, value = cleanedLine:match('([^:]+):%s*(.+)')
      if currentEntry and key and value then
        currentEntry.timings[key] = value
      end
    elseif isTimings and trim(line) == '' then
      isTimings = false
    elseif line:find('^%* Captures:') then
      isCaptures = true
    elseif isCaptures and trim(line) ~= '' then
      local key, value = line:match('^%* ([^:]+):%s*(.+)')
      if currentEntry and key and value then
        currentEntry.captures[key] = value
      end
    elseif isCaptures and trim(line) == '' then
      isCaptures = false
    end
  end

  if currentEntry then
    table.insert(entries, currentEntry)
  end

  for _, entry in ipairs(entries) do
    if not entry.error then
      entry.response.body = entry.response.body .. trim(stdout)
    end
  end

  return { entries = entries }
end

return M
