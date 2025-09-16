# GitHub Copilot Instructions for hurl.nvim

## Project Overview

`hurl.nvim` is a Neovim plugin that enables developers to run HTTP requests directly from `.hurl` files within their editor. The plugin provides a seamless API development workflow by executing requests and displaying responses without leaving Neovim.

### Key Features
- Execute HTTP requests from `.hurl` files
- Multiple display modes (popup/split view)
- Environment variable support with `vars.env` files
- Response formatting (JSON, HTML, XML)
- Request history and management
- Variable management and fixtures
- Integration with Neovim's LSP and treesitter

## Architecture and Key Components

### Core Structure
```
lua/hurl/
├── init.lua           # Main setup and configuration
├── main.lua           # Core functionality and command registration
├── popup.lua          # Popup window implementation
├── split.lua          # Split view implementation
├── http_utils.lua     # HTTP request utilities
├── utils.lua          # General utility functions
├── git_utils.lua      # Git-related utilities
├── history.lua        # Request history management
├── health.lua         # Health check implementation
├── codelens.lua       # CodeLens integration
└── vlog.lua           # Logging utilities
```

### Configuration System
- Default configuration in `lua/hurl/init.lua`
- Global config stored in `_HURL_GLOBAL_CONFIG`
- User configurations merged with `vim.tbl_deep_extend`

## Code Patterns and Conventions

### Lua Style
- Use modern Lua patterns and idioms
- Follow Neovim plugin conventions
- Prefer local functions and variables
- Use meaningful variable names
- Include type annotations with EmmyLua format

### Error Handling
- Use `pcall` for operations that might fail
- Provide meaningful error messages
- Log errors with appropriate severity levels
- Handle edge cases gracefully

### Example Pattern:
```lua
local function safe_operation()
  local ok, result = pcall(function()
    -- risky operation
    return some_function()
  end)
  
  if not ok then
    utils.log_error('Operation failed: ' .. result)
    return nil
  end
  
  return result
end
```

### Configuration Patterns
- Always provide sensible defaults
- Validate user input
- Use deep merge for configuration extension
- Support both string and table formats where appropriate

### Example:
```lua
-- Handle both string and table for env_file
if options and options.env_file ~= nil and type(options.env_file) == 'string' then
  utils.log_warn('env_file should be a table')
  options.env_file = { options.env_file }
end
```

## Development Guidelines

### File Organization
- Keep modules focused and cohesive
- Separate UI logic (popup, split) from core logic
- Use utility modules for reusable functionality
- Follow single responsibility principle

### Testing
- Use `vusted` for testing (run with `make test`)
- Test files are in `test/` directory
- Follow existing test patterns in `*_spec.lua` files
- Test both success and failure scenarios

### Documentation
- Maintain comprehensive README with examples
- Use EmmyLua annotations for function documentation
- Include inline comments for complex logic
- Keep examples in documentation up-to-date

### Dependencies
- Minimize external dependencies
- Use Neovim built-in functions when possible
- Core dependencies: `nui.nvim`, `plenary.nvim`, `nvim-treesitter`
- Optional dependencies should degrade gracefully

## Neovim Plugin Specific Guidelines

### Command Registration
- Use descriptive command names with `Hurl` prefix
- Provide completion where appropriate
- Include command descriptions for help
- Support range operations for visual mode

### Autocommands
- Use appropriate events for file type detection
- Clean up resources on buffer deletion
- Handle window/tab changes gracefully

### UI Implementation
- Support both popup and split modes
- Implement consistent key mappings
- Provide visual feedback for long operations
- Handle window resizing and repositioning

### Integration Points
- Use treesitter for syntax highlighting
- Implement health checks in `health.lua`
- Support LSP features where appropriate
- Integrate with Neovim's built-in features

## Environment and Variable Management

### Environment Files
- Support multiple environment file names
- Search in standard project locations
- Handle missing files gracefully
- Provide clear error messages for syntax errors

### Variable Fixtures
- Support dynamic variable generation
- Implement callback-based variable system
- Ensure reproducible behavior where possible
- Document fixture variable usage

## HTTP Request Handling

### Request Execution
- Use external `hurl` command for actual HTTP requests
- Parse command output appropriately
- Handle timeouts and network errors
- Support verbose and debug modes

### Response Processing
- Format responses based on content type
- Support multiple formatters (jq, prettier, tidy)
- Handle large responses efficiently
- Preserve raw response data

## Code Quality Standards

### Performance
- Avoid blocking the UI thread
- Use async operations where appropriate
- Cache expensive computations
- Minimize memory usage

### Maintainability
- Keep functions small and focused
- Use consistent naming conventions
- Avoid deep nesting
- Refactor common patterns into utilities

### Security
- Validate user input
- Handle sensitive data appropriately
- Avoid code injection vulnerabilities
- Use secure default configurations

## Contributing Guidelines

### Pull Requests
- Follow existing code style
- Include tests for new functionality
- Update documentation as needed
- Provide clear commit messages
- Test with multiple Neovim versions

### Issue Handling
- Reproduce issues before fixing
- Provide minimal reproduction cases
- Consider backward compatibility
- Document breaking changes clearly

## Common Patterns to Follow

### Module Structure
```lua
local M = {}

-- Private functions
local function private_helper()
  -- implementation
end

-- Public API
function M.public_function()
  -- implementation
end

-- Setup function (if applicable)
function M.setup(opts)
  -- configuration setup
end

return M
```

### Configuration Validation
```lua
local function validate_config(config)
  assert(type(config) == 'table', 'Config must be a table')
  -- Additional validation
end
```

### Error Logging
```lua
local utils = require('hurl.utils')

-- Use appropriate log levels
utils.log_info('Information message')
utils.log_warn('Warning message') 
utils.log_error('Error message')
```

This document should guide GitHub Copilot in understanding the project structure, conventions, and best practices for contributing to hurl.nvim.