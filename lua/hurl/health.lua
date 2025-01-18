local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error

-- Add health check for default formatter: jq and prettier
M.check = function()
  start('hurl.nvim health check')
  local jq = vim.fn.executable('jq')
  local prettier = vim.fn.executable('prettier')
  local hurl = vim.fn.executable('hurl')

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

  if hurl == 0 then
    error('hurl not found')
  else
    ok('hurl found')
  end

  if require('hurl.utils').is_hurl_parser_available then
    ok('treesitter[hurl]: installed')
  else
    warn(
      'treesitter[hurl]: missing parser for syntax highlighting. Install "nvim-treesitter/nvim-treesitter" plugin and run ":TSInstall hurl".'
    )
  end

  -- Check for hurl version > 4.3.0
  local hurl_version_output = vim.fn.system('hurl --version')
  local hurl_version = hurl_version_output:match('%d+%.%d+%.%d+')

  if hurl_version then
    local major, minor, patch = hurl_version:match('(%d+)%.(%d+)%.(%d+)')
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

    if major > 4 or (major == 4 and (minor > 3 or (minor == 3 and patch > 0))) then
      ok('hurl version > 4.3.0 found')
    else
      error('hurl version <= 4.3.0 found')
    end
  else
    error('Unable to determine hurl version')
  end

  ok('hurl.nvim: All good!')
end

return M
