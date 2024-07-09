local utils = require('hurl.utils')
local M = {}

--- Show the last request in the history
---@param response table
M.show = function(response)
  local container = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)
  if not response.headers then
    -- Do not show anything if there is no response
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
  if utils.is_json_response(content_type) then
    container.show(response, 'json')
  else
    if utils.is_html_response(content_type) then
      container.show(response, 'html')
    else
      if utils.is_xml_response(content_type) then
        container.show(response, 'xml')
      else
        container.show(response, 'text')
      end
    end
  end
end

return M
