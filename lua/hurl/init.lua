--- Global configuration for hurl.nvim
_HURL_CFG = {
  -- Debug mode
  -- Default: false
  debug = false,

  -- Display in a floating window or in a quick fix list
  -- Default is popup
  mode = 'popup',
}
local M = {}

--- Setup hurl.nvim
---@param options (table | nil)
--       - debug: (boolean | nil) default: false.
--       - mode: ('popup' | 'quickfix') default: popup.
function M.setup(options)
  _HURL_CFG = vim.tbl_extend('force', _HURL_CFG, options or {})

  require('hurl.wrapper').setup()
end

return M
