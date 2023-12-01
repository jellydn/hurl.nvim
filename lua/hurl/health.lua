local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local error = vim.health.error or vim.health.report_error

-- Add health check for default formatter: jq and prettier
function M.check()
  start('hurl.nvim health check')
  local jq = vim.fn.executable('jq')
  local prettier = vim.fn.executable('prettier')

  if jq == 0 then
    error('jq not found')
  else
    ok('jq found')
  end

  if prettier == 0 then
    error('prettier not found')
  else
    ok('prettier found')
  end

  ok('hurl.nvim: All good!')
end

return M
