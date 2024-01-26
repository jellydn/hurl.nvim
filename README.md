<h1 align="center">Welcome to hurl.nvim 👋</h1>
<p>
  <strong>Hurl.nvim</strong> is a Neovim plugin designed to run HTTP requests directly from `.hurl` files. Elevate your API development workflow by executing and viewing responses without leaving your editor.
</p>

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![IT Man - Effortless APIs with Hurl.nvim: A Developer's Guide to Neovim Tooling [Vietnamese]](https://i.ytimg.com/vi/nr_RbHvnnwk/hqdefault.jpg)](https://www.youtube.com/watch?v=nr_RbHvnnwk)

## Features

- 🚀 Execute HTTP requests directly from `.hurl` files.
- 👁‍🗨 Multiple display modes for API response: popup or split.
- 🌈 Highly customizable through settings.

## Usage

Add the following configuration to your Neovim setup with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jellydn/hurl.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  ft = "hurl",
  opts = {
    -- Show debugging info
    debug = false,
    -- Show response in popup or split
    mode = "split",
    -- Default formatter
    formatters = {
      json = { 'jq' }, -- Make sure you have install jq in your system, e.g: brew install jq
      html = {
        'prettier', -- Make sure you have install prettier in your system, e.g: npm install -g prettier
        '--parser',
        'html',
      },
    },
  },
  keys = {
    -- Run API request
    { "<leader>A", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
    { "<leader>a", "<cmd>HurlRunnerAt<CR>", desc = "Run Api request" },
    { "<leader>te", "<cmd>HurlRunnerToEntry<CR>", desc = "Run Api request to entry" },
    { "<leader>tm", "<cmd>HurlToggleMode<CR>", desc = "Hurl Toggle Mode" },
    { "<leader>tv", "<cmd>HurlVerbose<CR>", desc = "Run Api in verbose mode" },
    -- Run Hurl request in visual mode
    { "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
  },
}
```

Simple demo in split mode:

[![Show in split mode](https://i.gyazo.com/19492e8b5366cec3f22d5fd97a63f37a.gif)](https://gyazo.com/19492e8b5366cec3f22d5fd97a63f37a)

> [!NOTE]
> I frequently utilize the nightly version of Neovim, so if you encounter any issues, I recommend trying that version first. I may not have the time to address problems in the stable version. Your contributions via pull requests are always welcome.

## Env File Support: vars.env

`hurl.nvim` seamlessly integrates with environment files named `vars.env` to manage environment variables for your HTTP requests. These environment variables are essential for customizing your requests with dynamic data such as API keys, base URLs, and other configuration values.

### Customization

You can specify the name of the environment file in your `hurl.nvim` configuration. By default, `hurl.nvim` looks for a file named `vars.env`, but you can customize this to any file name that fits your project's structure.

Here's how to set a custom environment file name in your `hurl.nvim` setup:

```lua
require('hurl').setup({
  -- Specify your custom environment file name here
  env_file = {
      'hurl.env',
  },
  -- Other configuration options...
})
```

### File Location

The plugin searches for a `vars.env` (env_file config) in multiple locations to accommodate various project structures and ensure that environment-specific variables for your HTTP requests are easily accessible. The search occurs in the following order:

1. **Current File's Directory:** The directory where the current file is located. This is particularly useful for projects where environment variables are specific to a particular module or component.

2. **Specific Directories in Project:** The plugin scans predefined directories within the project, which are commonly used for organizing different aspects of a project:

   - `src/`: The source code directory.
   - `test/` and `tests/`: Directories typically used for test scripts.
   - `server/`: If your project includes a server component, this directory is checked.
   - `src/tests/` and `server/tests/`: These are checked for environment variables specific to tests within the respective `src` and `server` directories.

3. **Intermediate Directories from Git Root to Current File:** If the project is a git repository, the plugin identifies the root of the repository and then searches for `vars.env` in every directory on the path from this root to the current file's directory. This feature is particularly useful in monorepo setups or large projects, where different modules or packages may have their own environment variables.

By checking these locations, the plugin ensures a comprehensive search for environment variables, catering to a wide range of project structures and setups.

### Swappable environment

To change the environment file name, use the `HurlSetEnvFile` command followed by the new file name. You can have multiple variable files by having comma-seperated values.

#### Notes

- Ensure that the new environment file exists in the directories where the plugin searches for it, as outlined in the [File Location](#file-location) section.
- This change will apply globally for the current session of Neovim. If you restart Neovim, it will revert to the default `vars.env` unless you change it again.

## Demo

Check out the following demos to see `hurl.nvim` in action:

### Run a File

Run the entire file by pressing `<leader>A` or run `HurlRunner` command.

[![Run a file in popup mode](https://i.gyazo.com/e554e81788aad910848ff991c9369d7b.gif)](https://gyazo.com/e554e81788aad910848ff991c9369d7b)

### Run a Selection

Select a range of lines and press `<leader>h` to execute the request or run `HurlRunner` command.

[![Run a selection in popup mode](https://i.gyazo.com/1a44dbbf165006fb5744c8f10883bb69.gif)](https://gyazo.com/1a44dbbf165006fb5744c8f10883bb69)

### Run at current line

Place your cursor on the line you want to run and press `<leader>a` or run `HurlRunnerAt` command to execute the request. It need be one of the HTTP methods listed: GET, POST, PUT, DELETE, PATCH.

[![Run at current line in popup mode](https://i.gyazo.com/20efd2cf3f73238bd57e79fc662208b1.gif)](https://gyazo.com/20efd2cf3f73238bd57e79fc662208b1)

#### Verbose mode

Run `HurlVerbose` command to execute the request in verbose mode. The response will be displayed in QuickFix window. This is useful for debugging purposes or getting the curl command from hurl file.

[![Run at current line in verbose mode](https://i.gyazo.com/7d0f709e2db53f8c9e05655347f11bc9.gif)](https://gyazo.com/7d0f709e2db53f8c9e05655347f11bc9)

### Run to entry

Place your cursor on the line you want to run to that entry and press `<leader>te` or run `HurlRunnerToEntry` command to execute the request. It need be one of the HTTP methods listed: GET, POST, PUT, DELETE, PATCH.

[![Run to entry in split mode](https://i.gyazo.com/14d47adbfcab9e945f89e020b83328a9.gif)](https://gyazo.com/14d47adbfcab9e945f89e020b83328a9)

Note: it's running to that entry and ignore the remaining of the file. It is useful for debugging purposes.

### Toggle Mode

Run `HurlToggleMode` command to toggle between split and popup mode.

[![Toggle mode](https://i.gyazo.com/b36b19ab76524b95015eafe4c6e1c81f.gif)](https://gyazo.com/b36b19ab76524b95015eafe4c6e1c81f)

## Default Key Mappings

`hurl.nvim` comes with some default key mappings to streamline your workflow:

- `q`: Close the current popup window.
- `<C-n>`: Switch to the next popup window.
- `<C-p>`: Switch to the previous popup window.

These key mappings are active within the popup windows that `hurl.nvim` displays.

## Configuration

`hurl.nvim` can be customized with the following default configurations:

```lua
local default_config = {
  -- Toggle debugging information
  debug = false, -- If true, logs will be saved at ~/.local/state/nvim/hurl.nvim.log

  -- Set the display mode for the response: 'split' or 'popup'
  mode = 'split',

  -- Split settings
  split_position = "right",
  split_size = "50%",

  -- Popup settings
  popup_position = '50%',
  popup_size = {
    width = 80,
    height = 40,
  },

  -- Default environment file name
  env_file = {
      'vars.env',
  },

  -- Specify formatters for different response types
  formatters = {
    json = { 'jq' },  -- Uses jq to format JSON responses
    html = {
      'prettier',     -- Uses prettier to format HTML responses
      '--parser',
      'html',
    },
  },
}
```

To apply these configurations, include them in your Neovim setup like this:

```lua
require('hurl').setup({
  debug = true,          -- Enable to show detailed logs
  mode = 'popup',        -- Change to 'popup' to display responses in a popup window
  env_file = { 'vars.env' }, -- Change this to use a different environment file name
  formatters = {
    json = { 'jq' },    -- Customize the JSON formatter command
    html = {
      'prettier',       -- Customize the HTML formatter command
      '--parser',
      'html',
    },
  },
})
```

Adjust the settings as per your needs to enhance your development experience with `hurl.nvim`.

### Tips

- Enable debug mode with `debug = true` for detailed logs. Logs are saved at `~/.local/state/nvim/hurl.nvim.log` on macOS.
- **Split Mode with Edgy:** `hurl.nvim` can be used with [edgy.nvim](https://github.com/folke/edgy.nvim) to manage layout when using the split mode.

```lua
right = {
  { title = "Hurl Nvim", size = { width = 0.5 }, ft = "hurl-nvim" },
}
```

## Resources

[![IT Man - Building and Testing a #Hapi Server with #Hurl: A Step-By-Step Demo [Vietnamese]](https://i.ytimg.com/vi/LP_RXe8cM_s/mqdefault.jpg)](https://www.youtube.com/watch?v=LP_RXe8cM_s)

## Credits

- [Hurl - Run and Test HTTP Requests](https://hurl.dev/)
- Inspired by [ray-x/web-tools.nvim: Neovim plugin for web developers](https://github.com/ray-x/web-tools.nvim)
- Utilize [MunifTanjim/nui.nvim: UI components for Neovim plugins and configurations](https://github.com/MunifTanjim/nui.nvim)

## Author

👤 **Huynh Duc Dung**

- Website: https://productsway.com/
- Twitter: [@jellydn](https://twitter.com/jellydn)
- Github: [@jellydn](https://github.com/jellydn)

## Show your support

If this guide has been helpful, please give it a ⭐️.

[![kofi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/dunghd)
[![paypal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/dunghd)
[![buymeacoffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dunghd)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://productsway.com/"><img src="https://avatars.githubusercontent.com/u/870029?v=4?s=100" width="100px;" alt="Dung Duc Huynh (Kaka)"/><br /><sub><b>Dung Duc Huynh (Kaka)</b></sub></a><br /><a href="https://github.com/jellydn/hurl.nvim/commits?author=jellydn" title="Code">💻</a> <a href="https://github.com/jellydn/hurl.nvim/commits?author=jellydn" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cenk.kilic.dev/"><img src="https://avatars.githubusercontent.com/u/26881592?v=4?s=100" width="100px;" alt="Cenk Kılıç"/><br /><sub><b>Cenk Kılıç</b></sub></a><br /><a href="https://github.com/jellydn/hurl.nvim/commits?author=cenk1cenk2" title="Code">💻</a> <a href="https://github.com/jellydn/hurl.nvim/commits?author=cenk1cenk2" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.andrevdm.com"><img src="https://avatars.githubusercontent.com/u/74154?v=4?s=100" width="100px;" alt="Andre Van Der Merwe"/><br /><sub><b>Andre Van Der Merwe</b></sub></a><br /><a href="https://github.com/jellydn/hurl.nvim/commits?author=andrevdm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/skoch13"><img src="https://avatars.githubusercontent.com/u/29177689?v=4?s=100" width="100px;" alt="Sergey Kochetkov"/><br /><sub><b>Sergey Kochetkov</b></sub></a><br /><a href="https://github.com/jellydn/hurl.nvim/commits?author=skoch13" title="Documentation">📖</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <img src="https://raw.githubusercontent.com/all-contributors/all-contributors-cli/1b8533af435da9854653492b1327a23a4dbd0a10/assets/logo-small.svg">
          <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
        </img>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
