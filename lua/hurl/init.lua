--- Default configuration for hurl.nvim
local default_config = {
  debug = false,
  mode = 'split',
  formatters = {
    json = { 'jq' },
    html = {
      'prettier',
      '--parser',
      'html',
    },
  },
}
--- Global configuration for entire plugin, easy to access from anywhere
_HURL_GLOBAL_CONFIG = default_config
local M = {}

--- Setup hurl.nvim
---@param options (table | nil)
--       - debug: (boolean | nil) default: false.
--       - mode: ('popup' | 'split') default: popup.
function M.setup(options)
  _HURL_GLOBAL_CONFIG = vim.tbl_extend('force', _HURL_GLOBAL_CONFIG, options or default_config)

  require('hurl.main').setup()
end

return M
