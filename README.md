<h1 align="center">Welcome to hurl.nvim 👋</h1>
<p>
  TBD
</p>

## Usage

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

## Credits

Inspired by [ray-x/web-tools.nvim: Neovim plugin for web developers](https://github.com/ray-x/web-tools.nvim)
## Show your support

Give a ⭐️ if this project helped you!
