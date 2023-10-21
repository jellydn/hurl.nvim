--- @module hurl.nvim
--- Plugin entrypoint
---@return boolean
local function setup()
  print('hello world')
  return true
end

return {
  setup = setup,
}
