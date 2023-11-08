<h1 align="center">Welcome to hurl.nvim 👋</h1>
<p>
  <strong>Hurl.nvim</strong> is a Neovim plugin designed to run HTTP requests directly from `.hurl` files. Elevate your API development workflow by executing and viewing responses without leaving your editor.
</p>

[![IT Man - Effortless APIs with Hurl.nvim: A Developer&#39;s Guide to Neovim Tooling [Vietnamese]](https://i.ytimg.com/vi/nr_RbHvnnwk/hqdefault.jpg)](https://www.youtube.com/watch?v=nr_RbHvnnwk)

## Features

- 🚀 Execute HTTP requests directly from `.hurl` files.
- 👁‍🗨 Multiple display modes for API response: popup or split.
- 🌈 Highly customizable through Neovim settings.

## Usage

Add the following configuration to your Neovim setup:

```lua
  {
    "jellydn/hurl.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "HurlRunner", "HurlRunnerAt", "HurlRunnerToEntry" },
    opts = {
      -- Show debugging info
      debug = false,
      -- Show response in popup or split
      mode = "popup",
    },
    keys = {
      -- Run API request
      { "<leader>A", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
      { "<leader>a", "<cmd>HurlRunnerAt<CR>", desc = "Run Api request" },
      { "<leader>te", "<cmd>HurlRunnerToEntry<CR>", desc = "Run Api request to entry" },
      -- Run Hurl request in visual mode
      { "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
    },
  }
}
```

## Env File Support: vars.env

`hurl.nvim` offers seamless integration with `vars.env` files to manage environment variables for your HTTP requests.

### File Location

The plugin looks for a `vars.env` file in the following directories:

- Current file's directory
- src/
- test/
- tests/
- server/
- src/tests/
- server/tests/

This makes it convenient to specify environment-specific variables that your HTTP requests may use.
## Demo

Check out the following demos to see `hurl.nvim` in action:

### Run a File

Run the entire file by pressing `<leader>A` or run `HurlRunner` command.

[![Run a file](https://i.gyazo.com/e554e81788aad910848ff991c9369d7b.gif)](https://gyazo.com/e554e81788aad910848ff991c9369d7b)

### Run a Selection

Select a range of lines and press `<leader>h` to execute the request or run `HurlRunner` command.

[![Selection](https://i.gyazo.com/1a44dbbf165006fb5744c8f10883bb69.gif)](https://gyazo.com/1a44dbbf165006fb5744c8f10883bb69)

### Run at current line

Place your cursor on the line you want to run and press `<leader>a` or run `HurlRunnerAt` command to execute the request. It need be one of the HTTP methods listed: GET, POST, PUT, DELETE, PATCH.

[![Run at current line](https://i.gyazo.com/20efd2cf3f73238bd57e79fc662208b1.gif)](https://gyazo.com/20efd2cf3f73238bd57e79fc662208b1)

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
  debug = false, -- If true, logs will be saved at ~/.cache/nvim/hurl.nvim.log

  -- Set the display mode for the response: 'split' or 'popup'
  mode = 'split',
  split_position = "right",
  split_size = "50%",

  -- Default environment file name
  env_file = 'vars.env',

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
  env_file = 'vars.env', -- Change this to use a different environment file name
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

Logs are saved at `~/.cache/nvim/hurl.nvim.log` on macOS.

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
