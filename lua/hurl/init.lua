local utils = require('hurl.utils')
--- Default configuration for hurl.nvim
local default_config = {
  debug = false,
  mode = 'split',
  show_notification = false,
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
  env_pattern =  '.*%.env.*',
  fixture_vars = {
    {
      name = 'random_int_number',
      callback = function()
        return math.random(1, 1000)
      end,
    },
    {
      name = 'random_float_number',
      callback = function()
        local result = math.random() * 10
        return string.format('%.2f', result)
      end,
    },
  },
  find_env_files_in_folders = utils.find_env_files_in_folders,
  formatters = {
    json = { 'jq' },
    html = {
      'prettier',
      '--parser',
      'html',
    },
    xml = {
      'tidy',
      '-xml',
      '-i',
      '-q',
    },
  },
  -- Default mappings for the response popup or split views
  mappings = {
    close = 'q', -- Close the response popup or split view
    next_panel = '<C-n>', -- Move to the next response popup window
    prev_panel = '<C-p>', -- Move to the previous response popup window
  },
  -- File root directory for uploading files
  -- file_root = vim.fn.getcwd(),
  -- Save capture as global variable
  save_captures_as_globals = true,
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

  _HURL_GLOBAL_CONFIG = vim.tbl_deep_extend('force', _HURL_GLOBAL_CONFIG, options or default_config)

  require('hurl.main').setup()
end

return M
