--- Global configuration for hurl.nvim
_HURL_CFG = {
  -- Debug mode
  -- Default: false
  debug = false,
}
local M = {}

function M.setup(options)
  _HURL_CFG = vim.tbl_extend('force', _HURL_CFG, options or {})

  require('hurl.utils').log('hurl.nvim loaded')

  require('hurl.wrapper').setup()
end

return M
