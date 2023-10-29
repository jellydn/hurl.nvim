--- Global configuration for hurl.nvim
_HURL_CFG = {
  debug = false,
  mode = 'split',
}
local M = {}

--- Setup hurl.nvim
---@param options (table | nil)
--       - debug: (boolean | nil) default: false.
--       - mode: ('popup' | 'split') default: popup.
function M.setup(options)
  _HURL_CFG = vim.tbl_extend('force', _HURL_CFG, options or {})

  require('hurl.main').setup()
end

return M
