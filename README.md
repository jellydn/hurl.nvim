<h1 align="center">Welcome to hurl.nvim 👋</h1>
<p>
  <strong>Hurl.nvim</strong> is a Neovim plugin that brings the power of the Hurl command line tool into your editor. Designed to run HTTP requests from `.hurl` files, this plugin simplifies the API development process, making it both efficient and versatile.
</p>

## Table of Contents

<!--toc:start-->
- [Table of Contents](#table-of-contents)
- [Features](#features)
- [Usage](#usage)
- [Default Key Mappings](#default-key-mappings)
- [Credits](#credits)
- [Author](#author)
- [Show your support](#show-your-support)
<!--toc:end-->

## Features

- 🚀 Execute HTTP requests directly from `.hurl` files.
- 👁‍🗨 Multiple display modes for API response: popup or quickfix.
- 🌈 Highly customizable through Neovim settings.

## Usage

Add the following configuration to your Neovim setup:

```lua
  {
    "jellydn/hurl.nvim",
    ft = "hurl",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "HurlRun" },
    opts = {
      -- Show debugging info
      debug = true,
      -- Show response in popup or in quick list
      -- popup | quickfix
      mode = "popup", --
    },
    keys = {
      -- Run API request
      { "<leader>ra", "<cmd>HurlRun<CR>", desc = "Run API requests" },
      -- Run API request in visual mode
      { "<leader>cr", ":HurlRun<CR>", desc = "Run API request", mode = "v" },
    },
  }
}
```

## Default Key Mappings

`hurl.nvim` comes with some default key mappings to streamline your workflow:

- `q`: Close the current popup window.
- `<C-n>`: Switch to the next popup window.
- `<C-p>`: Switch to the previous popup window.

These key mappings are active within the popup windows that `hurl.nvim` displays.

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
