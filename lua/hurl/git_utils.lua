local M = {}

--- Check if the current directory is a git repo
---@return boolean
local function is_git_repo()
  local result = vim.fn.system('git rev-parse --is-inside-work-tree')

  return vim.v.shell_error == 0 and result == 'true'
end

--- Get the git root directory
---@return string|nil The git root directory
local function get_git_root()
  local git_root_path = require('plenary.job')
    :new({ command = 'git', args = { 'rev-parse', '--show-toplevel' } })
    :sync()[1]
  return git_root_path
end

local function split_path(path)
  local parts = {}
  for part in string.gmatch(path, '[^/]+') do
    table.insert(parts, part)
  end
  return parts
end

M.is_git_repo = is_git_repo
M.get_git_root = get_git_root
M.split_path = split_path

return M
