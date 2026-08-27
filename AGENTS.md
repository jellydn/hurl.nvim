# AGENTS.md

## 📦 Project Overview

**hurl.nvim** is a Neovim plugin that enables developers to run HTTP requests directly from `.hurl` files within their editor. The plugin provides a seamless API development workflow by executing requests and displaying responses without leaving Neovim.

- **Repository:** [jellydn/hurl.nvim](https://github.com/jellydn/hurl.nvim)
- **Primary Language:** Lua
- **Key Dependencies:** `nui.nvim`, `plenary.nvim`, `nvim-treesitter`
- **Test Framework:** `vusted`
- **Build System:** `Makefile`
- **CI:** GitHub Actions
- **Issue Tracking:** GitHub Issues
- **Additional Docs:** `README.md` for user documentation

---

## 🗂️ Repository Structure

```
hurl.nvim/
├── lua/hurl/               # Main plugin code
│   ├── init.lua           # Main setup and configuration
│   ├── main.lua           # Core functionality and command registration
│   ├── popup.lua          # Popup window implementation
│   ├── split.lua          # Split view implementation
│   ├── http_utils.lua     # HTTP request utilities
│   ├── utils.lua          # General utility functions
│   ├── git_utils.lua      # Git-related utilities
│   ├── history.lua        # Request history management
│   ├── health.lua         # Health check implementation
│   ├── codelens.lua       # CodeLens integration
│   └── vlog.lua           # Logging utilities
├── test/                  # Vusted-based tests
│   ├── hurl_spec.lua
│   ├── plugin_spec.lua
│   └── hurl_parser_spec.lua
├── example/               # Example .hurl files for testing
├── doc/                   # Vim help documentation
├── .github/               # CI, issue templates, workflows
├── README.md              # Main user documentation
├── CHANGELOG.md           # Version history
├── Makefile               # Build and test commands
└── version.txt            # Version info
```

---

## 🚦 Quick Start

1. **Install core dependencies:**

   ```bash
   # For testing and development
   make install
   ```

2. **Run tests:**

   ```bash
   make test                    # Run all tests (requires vusted)
   ```

3. **Lint and format:**

   ```bash
   # Uses stylua for formatting (if available)
   stylua lua/ test/
   ```

4. **Try the plugin:**

   ```lua
   -- Basic setup in init.lua
   require('hurl').setup({
     debug = false,
     mode = 'split',
     show_notification = false,
     formatters = {
       json = { 'jq' },
       html = { 'prettier', '--parser', 'html' },
     },
   })
   ```

---

## 🧑‍💻 Development Guidelines

### 1. **Code Style & Quality**

- **Lua 5.1+** (Neovim compatible)
- **Type annotations:** Use EmmyLua format for function documentation
- **Naming:** Use snake_case for functions and variables, PascalCase for modules
- **Error handling:** Use `pcall` for operations that might fail
- **Logging:** Use the built-in logging system (`utils.log_*`)

### 2. **Plugin Architecture**

- **Main entry:** `init.lua` handles setup and configuration
- **Core logic:** `main.lua` registers commands and manages plugin lifecycle
- **UI components:** Separate popup and split view implementations
- **Utilities:** Modular utility functions for HTTP, Git, and general operations
- **Configuration:** Global config stored in `_HURL_GLOBAL_CONFIG`
- **Health checks:** Implement checks in `health.lua`

### 3. **HTTP Request Handling**

- **External dependency:** Uses external `hurl` command for actual HTTP requests
- **Request parsing:** Parse `.hurl` files using treesitter or custom parsers
- **Environment support:** Support for `vars.env` files and variable substitution
- **Response formatting:** Multiple formatters (jq, prettier, tidy)
- **Error handling:** Graceful handling of network errors and timeouts

### 4. **Testing**

- **Test framework:** Use `vusted` for Lua testing
- **Test files:** Place in `test/` directory with `*_spec.lua` naming
- **Coverage:** Test both success and failure scenarios
- **Mocking:** Mock external dependencies (hurl command, file system)
- **CI:** Automated testing via GitHub Actions

### 5. **Documentation**

- **README.md:** Comprehensive user documentation with examples
- **Vim help:** Generate help documentation in `doc/`
- **EmmyLua annotations:** Document function signatures and types
- **Code comments:** Explain complex logic and algorithms
- **Changelog:** Maintain version history in `CHANGELOG.md`

### 6. **Configuration System**

- **Default config:** Provide sensible defaults in `init.lua`
- **User config:** Support deep merging with `vim.tbl_deep_extend`
- **Validation:** Validate user input and provide helpful error messages
- **Backwards compatibility:** Handle deprecated options gracefully

### 7. **UI Implementation**

- **Display modes:** Support both popup and split view modes
- **Key mappings:** Consistent keybindings across UI components
- **Responsive design:** Handle window resizing and repositioning
- **Visual feedback:** Provide clear indicators for long-running operations
- **Accessibility:** Support standard Neovim navigation patterns

### 8. **Integration Points**

- **Treesitter:** Use for syntax highlighting and parsing
- **LSP:** Optional integration for enhanced development experience
- **File type detection:** Automatic detection of `.hurl` files
- **Autocommands:** Clean resource management and event handling

## 9. The Code Base

### General Structure

The repository contains a Neovim plugin written in Lua that provides HTTP request capabilities:

```
lua/hurl/
├── init.lua           # Plugin setup and configuration
├── main.lua           # Command registration and core functionality
├── popup.lua          # Popup window implementation using nui.nvim
├── split.lua          # Split window implementation
├── http_utils.lua     # HTTP request processing
├── utils.lua          # General utilities and helpers
├── git_utils.lua      # Git-related functionality
├── history.lua        # Request history management
├── health.lua         # Health check implementation
├── codelens.lua       # CodeLens integration
└── vlog.lua           # Logging utilities
```

### Key Functionality

- **Configuration:** `init.lua` sets up default configuration and merges user options:

```lua
local default_config = {
  debug = false,
  mode = 'split',
  show_notification = false,
  auto_close = true,
  split_position = 'right',
  split_size = '50%',
  popup_position = '50%',
  popup_size = { width = 80, height = 40 },
  env_file = { 'vars.env' },
  formatters = {
    json = { 'jq' },
    html = { 'prettier', '--parser', 'html' },
    xml = { 'tidy', '-xml', '-i', '-q' },
  },
}
```

- **Commands:** `main.lua` registers Neovim commands and sets up autocommands:

```lua
vim.api.nvim_create_user_command('HurlRunner', function()
  require('hurl').run_current_file()
end, {})

vim.api.nvim_create_user_command('HurlRunnerAt', function()
  require('hurl').run_at_cursor()
end, {})
```

- **HTTP Processing:** The plugin uses the external `hurl` command to execute requests and process responses with configurable formatters.

---

## 🛠️ Common Commands & Development Workflow

### Development Commands

- **Setup development environment:**

  ```bash
  # Install vusted for testing
  make install
  ```

- **Run tests:**

  ```bash
  make test                    # Run all tests
  vusted test/                 # Direct vusted execution
  ```

- **Format code:**

  ```bash
  stylua lua/ test/           # Format Lua code (if stylua is installed)
  ```

- **Generate documentation:**
  ```bash
  # Generate vim help docs (if using vimdoc)
  vimdoc lua/hurl/init.lua
  ```

### Plugin Commands

- **Basic usage:**

  ```vim
  :HurlRunner                 " Run entire .hurl file
  :HurlRunnerAt              " Run request at cursor
  :HurlRunnerToEntry         " Run from start to cursor
  :HurlToggleMode            " Toggle between popup/split
  :HurlVerbose               " Run in verbose mode
  ```

- **Variable management:**
  ```vim
  :HurlSetVariable API_KEY your_key    " Set environment variable
  :HurlManageVariable                  " Open variable manager
  :HurlSetEnvFile custom.env          " Set custom env file
  ```

---

## 🧩 Agent Code Integration

### a. **File Navigation & Context**

- **Plugin entry:** `lua/hurl/init.lua`
- **Core logic:** `lua/hurl/main.lua`
- **UI components:** `lua/hurl/popup.lua`, `lua/hurl/split.lua`
- **Utilities:** `lua/hurl/utils.lua`, `lua/hurl/http_utils.lua`
- **Tests:** `test/*.lua`
- **Documentation:** `README.md`, `doc/`

### b. **Best Practices for Coding Assistance Agents**

- **Always check plugin dependencies** before modifying core functionality (nui.nvim, plenary.nvim)
- **When adding commands:** Update both `main.lua` and documentation
- **When modifying UI:** Ensure both popup and split modes work consistently
- **When changing config:** Update default config and add validation
- **When adding features:** Add corresponding tests and update README
- **Environment handling:** Respect user's environment file preferences and search paths

### c. **Common Patterns**

- **Module structure:** Follow Neovim plugin conventions with `local M = {}` pattern
- **Configuration:** Use `vim.tbl_deep_extend` for merging user config
- **Error handling:** Use `pcall` and provide meaningful error messages
- **UI creation:** Use nui.nvim for consistent UI components
- **Async operations:** Use `vim.schedule` for UI updates from async contexts
- **Command registration:** Use `vim.api.nvim_create_user_command` with proper options

---

## 🧪 Testing & Quality Assurance

### Test Structure

- **Unit tests:** Test individual functions and modules
- **Integration tests:** Test command execution and UI interactions
- **Mock external dependencies:** Mock `hurl` command and file system operations
- **Test configuration:** Test various configuration scenarios

### Quality Standards

- **Code coverage:** Aim for high test coverage of core functionality
- **Error scenarios:** Test error handling and edge cases
- **Performance:** Ensure UI responsiveness and efficient request handling
- **Compatibility:** Test with multiple Neovim versions

---

## 📝 Documentation & Examples

### User Documentation

- **README.md:** Installation, configuration, and usage examples
- **Help docs:** Vim help documentation for commands and functions
- **Examples:** Sample `.hurl` files and configuration snippets

### Developer Documentation

- **Code comments:** Explain complex algorithms and business logic
- **Function documentation:** EmmyLua annotations for all public functions
- **Architecture decisions:** Document design choices and trade-offs

---

## 🛡️ Security & Best Practices

### Security Considerations

- **Environment variables:** Secure handling of sensitive data in env files
- **Command execution:** Safe execution of external `hurl` command
- **File access:** Proper validation of file paths and permissions
- **Error messages:** Avoid exposing sensitive information in error output

### Performance

- **Async operations:** Non-blocking HTTP requests and UI updates
- **Memory management:** Efficient handling of large responses
- **Caching:** Cache environment variables and parsed configurations
- **Resource cleanup:** Proper cleanup of buffers and windows

---

## 🏷️ Branching & Workflow

### Development Workflow

- **Branch naming:** `feature/description`, `bugfix/description`, `docs/description`
- **Commit messages:** Follow conventional commit format
- **Pull requests:** Include tests, documentation updates, and changelog entries
- **Code review:** Focus on functionality, performance, and user experience

### Release Process

- **Version management:** Update `version.txt` and `CHANGELOG.md`
- **Testing:** Comprehensive testing before release
- **Documentation:** Update README and help docs
- **Tagging:** Proper git tagging for releases

---

## 🧭 Quick Reference

| Task                      | Command/Location                  |
| ------------------------- | --------------------------------- |
| Run tests                 | `make test`                       |
| Install test dependencies | `make install`                    |
| Format code               | `stylua lua/ test/`               |
| Main plugin file          | `lua/hurl/init.lua`               |
| Core functionality        | `lua/hurl/main.lua`               |
| UI components             | `lua/hurl/popup.lua`, `split.lua` |
| Utilities                 | `lua/hurl/utils.lua`              |
| Tests                     | `test/*.lua`                      |
| Documentation             | `README.md`                       |
| Configuration             | `_HURL_GLOBAL_CONFIG` global      |
| Commands                  | `:Hurl*` commands                 |
| Environment files         | `vars.env` (configurable)         |

---

## 🧠 Additional Instructions

### For AI Coding Assistants

- **This file provides comprehensive context** for understanding hurl.nvim's architecture and development practices
- **Always respect the plugin's architecture** when making changes (separate UI logic, modular utilities)
- **Test thoroughly** - HTTP clients need robust error handling and edge case coverage
- **Consider user experience** - Plugin should work seamlessly within Neovim workflows
- **Environment handling is critical** - Respect user's environment file setup and variable substitution
- **UI consistency** - Ensure both popup and split modes provide equivalent functionality
- **External dependencies** - Handle missing `hurl` command gracefully with helpful error messages
- **Performance matters** - Don't block Neovim's UI thread with long-running HTTP requests
- **Security first** - Be careful with environment variable handling and command execution

### Development Notes

- **External hurl dependency:** Plugin requires the `hurl` CLI tool to be installed
- **File discovery:** Environment files searched in multiple locations (current dir, src/, test/, etc.)
- **Variable substitution:** Support for dynamic variables through fixture callbacks
- **Response formatting:** Configurable formatters for different content types
- **History management:** Track and replay previous requests
- **Git integration:** Discover project root and environment files using git context

---

## 🏁 Final Notes

- **This file is the definitive guide** for AI agents working on hurl.nvim
- **Keep it updated** when architecture or conventions change
- **Focus on user experience** - This is a developer tool that should enhance workflow
- **Maintain backwards compatibility** when possible
- **Document breaking changes** clearly in changelog and migration guides
- **Test with real .hurl files** to ensure practical functionality
- **Consider integration** with other Neovim plugins and LSP servers
