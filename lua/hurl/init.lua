local utils = require('hurl.utils')
--- Default configuration for hurl.nvim
local default_config = {
  debug = false,
  mode = 'split',
  auto_close = true,
  -- Default split options
  split_position = 'right',
  split_size = '50%',
  -- Default popup options
  popup_position = '50%',
  popup_size = {
    width = 80,
    height = 40,
  },
  env_file = { 'vars.env' },
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
  if options and options.env_file ~= nil and type(options.env_file) == 'string' then
    utils.log_warn('env_file should be a table')
    options.env_file = { options.env_file }
  end

  _HURL_GLOBAL_CONFIG = vim.tbl_extend('force', _HURL_GLOBAL_CONFIG, options or default_config)

  require('hurl.main').setup()
end

return M
