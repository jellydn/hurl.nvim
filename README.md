# nvim-plugin-template
neovim plugin template integration test and doc publish

## Usage

1. click `use this template` button generate a repo on your github.
2. clone your plugin repo.open terminal then cd plugin directory.
3. run `python3 rename.py your-plugin-name` this will replace all `nvim-plugin-template` to your `pluing-name`. 
   then it will prompt you input `y` or `n` to remove example codes in `init.lua` and
   `test/plugin_spec.lua`. if you are familiar this repo just input y. if you are first look at this
   template I suggest you look at them first. after these step the `rename.py` will also auto
   remove.

now you have a clean plugin env . enjoy!

## Format

format use `stylua` and provide `.stylua.toml`.

## Test
use vusted for test install by using `luarocks --lua-version=5.1 install vusted` then run `vusted test`
for your test cases.

create test case in test folder file rule is `foo_spec.lua` with `_spec` more usage please check
[busted usage](https://lunarmodules.github.io/busted/)

## Ci
Ci support auto generate doc from README and integration test and lint check by `stylua`.


## More
Other usage you can look at my plugins

## License MIT
