local M = {}

--- Check if the current directory is a git repo
---@return boolean
local function is_git_repo()
  vim.fn.system('git rev-parse --is-inside-work-tree')

  return vim.v.shell_error == 0
end

--- Get the git root directory
---@return string|nil The git root directory
local function get_git_root()
  local dot_git_path = vim.fn.finddir('.git', '.;')
  return vim.fn.fnamemodify(dot_git_path, ':h')
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
