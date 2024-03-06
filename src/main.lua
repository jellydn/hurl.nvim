local M = {}
local vim = vim or {}
local config = require('hurl.config')

local function executeFormatterCommand(responseBody, command)
    local handle = io.popen(command .. " '" .. responseBody:gsub("'", "\\'") .. "'", 'r')
    local output = handle:read("*a")
    local success, _, exitCode = handle:close()
    if success and exitCode == 0 then
        return output
    else
        return nil, "Error executing formatter command: " .. command
    end
end

function M.processHttpResponse(response)
    local contentType = response.headers['Content-Type'] or response.headers['content-type']
    local formatterCommand
    if contentType:find('application/json') then
        formatterCommand = table.concat(config.formatters.json, " ")
    elseif contentType:find('text/html') then
        formatterCommand = table.concat(config.formatters.html, " ")
    else
        return nil, "Unsupported content type: " .. contentType
    end

    local formattedResponse, error = executeFormatterCommand(response.body, formatterCommand)
    if not formattedResponse then
        vim.api.nvim_err_writeln(error)
        return
    end

    if config.mode == 'popup' then
        require('hurl.display').showPopup(formattedResponse)
    else
        require('hurl.display').showInCurrentBuffer(formattedResponse)
    end
end

return M
