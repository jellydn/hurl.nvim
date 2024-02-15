# Changelog

## 1.0.0 (2024-02-15)


### Features

* add custom file type for split ([61ccf1f](https://github.com/jellydn/hurl.nvim/commit/61ccf1f40d0aa42bb7b8fd0a9955854d03f620df))
* add default option for popup mode ([d47c320](https://github.com/jellydn/hurl.nvim/commit/d47c320593e87f0dea4da4704bd29740a80ad49b))
* add health check ([2a0d40b](https://github.com/jellydn/hurl.nvim/commit/2a0d40b019bf73f01d13fb5d3cc15c0e9bb42a2a))
* add HurlToggleMode command ([3063bba](https://github.com/jellydn/hurl.nvim/commit/3063bba232a4055e3c74c87ab76f35cee4890181))
* add new command for run hurl in verbose mode ([460b9f3](https://github.com/jellydn/hurl.nvim/commit/460b9f3223f6c3872ff1565020be3961aec02de4))
* add new command for show debug info ([321305e](https://github.com/jellydn/hurl.nvim/commit/321305efbd6f6d3077918c36d6c71abe27a393e1))
* add new command to change the env file ([a6f0f6d](https://github.com/jellydn/hurl.nvim/commit/a6f0f6dc418892a28a6981c9a0f344c5dd150d33))
* add new option for auto close on lost focus ([2e27b93](https://github.com/jellydn/hurl.nvim/commit/2e27b93e695790761c8490b6a05f6c6441433137))
* add run to entry command ([9d6fdff](https://github.com/jellydn/hurl.nvim/commit/9d6fdffee0a4b805a025650a8be9bd9ee34e6e74))
* bind `q` to quit for split mode ([b449389](https://github.com/jellydn/hurl.nvim/commit/b4493893f8884feea8fad960589ea9f99d521f07))
* clear previous response if buffer still open ([6be36b6](https://github.com/jellydn/hurl.nvim/commit/6be36b6faaafd95def4de0dc7e9baaa8764c63a4))
* enable folding for popup mode ([2a9bf8f](https://github.com/jellydn/hurl.nvim/commit/2a9bf8fa408c72b2c228f59191559a4e73556376))
* init hurl.nvim plugin ([f3f615a](https://github.com/jellydn/hurl.nvim/commit/f3f615a5f674bd1a7aaaad24efbf4fc6140cd2dd))
* init project ([0207117](https://github.com/jellydn/hurl.nvim/commit/020711770e2951b7fe0cf3798e91b8d2b72b7227))
* introduce new config for env file ([2cef196](https://github.com/jellydn/hurl.nvim/commit/2cef1967d96b0c3184333cf19e183bcf24341c6e))
* Make env search maintain provided order ([#69](https://github.com/jellydn/hurl.nvim/issues/69)) ([275368b](https://github.com/jellydn/hurl.nvim/commit/275368ba1d47d594b58a759e2da99938b16d6527))
* notify when hurl is running ([12a5804](https://github.com/jellydn/hurl.nvim/commit/12a5804a2db188a45b3e292bbd8e13cd841191eb))
* only set buffer option on nightly builds ([c3a4311](https://github.com/jellydn/hurl.nvim/commit/c3a4311567c7dee1ea36e305c2a7bbddb030a9b6))
* open quickfix if has any error ([029f784](https://github.com/jellydn/hurl.nvim/commit/029f7843123d79960db584fc5124559a079d2f40))
* port hurl plugin from ray-x/web-tools.nvim ([888bd0f](https://github.com/jellydn/hurl.nvim/commit/888bd0fc18057ba0a4f207895c1bfe9828a65071))
* send tmp file to quicklist on hurl request ([#11](https://github.com/jellydn/hurl.nvim/issues/11)) ([464f28e](https://github.com/jellydn/hurl.nvim/commit/464f28e60665897f3d320166e5fe025183f83b32))
* show content on popup ([0ae2711](https://github.com/jellydn/hurl.nvim/commit/0ae2711d86c28dff390bcfdb6439be3b807bdfb3))
* show error message on qflist ([5d977a2](https://github.com/jellydn/hurl.nvim/commit/5d977a2f33a83eab0eb95e6de8c61fe1841b2319))
* show response header on popup ([ba04d85](https://github.com/jellydn/hurl.nvim/commit/ba04d8585aca917f2e093c213c2fdc70df8dbd62))
* support PATCH method ([fba0251](https://github.com/jellydn/hurl.nvim/commit/fba0251e2421d23c70978678d46a9cc764593c0b))
* support PUT and DELETE method ([2c1b7d2](https://github.com/jellydn/hurl.nvim/commit/2c1b7d2063a47c54c7f30b33af6bf9cce8e8c828))
* support read vars.env file from test folder ([aea1ca5](https://github.com/jellydn/hurl.nvim/commit/aea1ca53ccdf29deab4c2a840f076ef828404b96))


### Bug Fixes

* **ci:** rename secret token for publish doc ([ebd7486](https://github.com/jellydn/hurl.nvim/commit/ebd748605d8a6251a12385fd56b65533d64f29e4))
* **ci:** setup release version ([c4d1447](https://github.com/jellydn/hurl.nvim/commit/c4d144716f6269e9ab7e45089b38179e6d2e085a))
* **ci:** upgrade checkout v4 ([c4d1447](https://github.com/jellydn/hurl.nvim/commit/c4d144716f6269e9ab7e45089b38179e6d2e085a))
* display popup position base on editor ([6951948](https://github.com/jellydn/hurl.nvim/commit/69519488a96e74da67ae3fefc17619a65c1c8c00))
* remove toc ([b810790](https://github.com/jellydn/hurl.nvim/commit/b8107903944d062d9822cef41b4a4491b2cdea97))
* send error to qlist and skip showing the result ([6799811](https://github.com/jellydn/hurl.nvim/commit/679981165305a5494ced10016348f703a57bd5db))
* set highlight for neovim stable ([8317978](https://github.com/jellydn/hurl.nvim/commit/8317978aa439e2506d0f6b2a87c8b674c2bb9ac5))
* simplify the check for json content type ([e8ad1e5](https://github.com/jellydn/hurl.nvim/commit/e8ad1e50e88e698e3a3a57cbe614a0b510587a1b))
* support load multi env files ([9443adc](https://github.com/jellydn/hurl.nvim/commit/9443adc0fa54e04fb9e2e35872022a4efa89dea0))
* support no response on body ([ec4262d](https://github.com/jellydn/hurl.nvim/commit/ec4262d6b6e9169ece39a8cd28405c95d0cb0380))
* **test:** check command exist ([7b4b23d](https://github.com/jellydn/hurl.nvim/commit/7b4b23d32cabf3a5de777266fa4ea24eb0d499da))
