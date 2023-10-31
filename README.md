<h1 align="center">Welcome to hurl.nvim 👋</h1>
<p>
  <strong>Hurl.nvim</strong> is a Neovim plugin designed to run HTTP requests directly from `.hurl` files. Elevate your API development workflow by executing and viewing responses without leaving your editor.
</p>

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
    cmd = { "HurlRunner", "HurlRunnerAt" },
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
      -- Run Hurl request in visual mode
      { "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
    },
  },

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

## Tips

Enable debug mode with `debug = true` for detailed logs. Logs are saved at `~/.cache/nvim/hurl.nvim.log` on macOS.

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
## Tips

Enable debug mode with `debug = true` for detailed logs. Logs are saved at `~/.cache/nvim/hurl.nvim.log` on macOS.
```
