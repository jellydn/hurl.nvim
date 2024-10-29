# Changelog

## [1.8.0](https://github.com/jellydn/hurl.nvim/compare/v1.7.1...v1.8.0) (2024-10-29)

### Features

- add new command to from current entry to end ([3b81a31](https://github.com/jellydn/hurl.nvim/commit/3b81a317516e683213c1e1eb7c14b4b1b6deb0b8))
- **config:** add file_root directory configuration option ([c502953](https://github.com/jellydn/hurl.nvim/commit/c502953b531de04c19fcb8003d8eb18718b6a61e)), closes [#195](https://github.com/jellydn/hurl.nvim/issues/195)

### Bug Fixes

- **utils:** improve error logging and notifications ([807b6ff](https://github.com/jellydn/hurl.nvim/commit/807b6ff480626d91ec46ca86092b530082c7400c))

## [1.7.1](https://github.com/jellydn/hurl.nvim/compare/v1.7.0...v1.7.1) (2024-08-24)

### Bug Fixes

- error when closing the result buffer and trying to reopen it ([#188](https://github.com/jellydn/hurl.nvim/issues/188)) ([ddce6f8](https://github.com/jellydn/hurl.nvim/commit/ddce6f8496cc01465cf2ce2b17733e38e422d2d8))
- **split:** remove redundant buffer name setting ([88dd2ff](https://github.com/jellydn/hurl.nvim/commit/88dd2ffdf40e2778e9277dcb167224bf1447a5da))

## [1.7.0](https://github.com/jellydn/hurl.nvim/compare/v1.6.0...v1.7.0) (2024-08-01)

### Features

- add response time calculation to hurl requests ([9cd1fd0](https://github.com/jellydn/hurl.nvim/commit/9cd1fd09c0619df91cd65c71f866fcc2a9050d6e))
- **hurl.nvim:** add support for fixture variables ([993c640](https://github.com/jellydn/hurl.nvim/commit/993c640f3282686699e8fc50d6aef2b5a45531aa))
- show response time on virtual text ([043a7de](https://github.com/jellydn/hurl.nvim/commit/043a7de69afe698d37795e7c9f157cf0630f6d20)), closes [#153](https://github.com/jellydn/hurl.nvim/issues/153)
- support --json flag for display response time ([f5874ea](https://github.com/jellydn/hurl.nvim/commit/f5874ea4cd7d6a40d4f97bedab0f84ac770e7b51))

### Bug Fixes

- **popup:** show popup after content population for proper alignment ([809891e](https://github.com/jellydn/hurl.nvim/commit/809891ee248fea594699e1dfdf195c7a23ab9259))

## [1.6.0](https://github.com/jellydn/hurl.nvim/compare/v1.5.2...v1.6.0) (2024-07-11)

### Features

- add xml type for response formatting and highlight ([#181](https://github.com/jellydn/hurl.nvim/issues/181)) ([f9edcfb](https://github.com/jellydn/hurl.nvim/commit/f9edcfbe80b45866528124c11e5ff0ed8586facc))

## [1.5.2](https://github.com/jellydn/hurl.nvim/compare/v1.5.1...v1.5.2) (2024-06-25)

### Bug Fixes

- **spinner:** use global config for show_notification ([#175](https://github.com/jellydn/hurl.nvim/issues/175)) ([e54b5a4](https://github.com/jellydn/hurl.nvim/commit/e54b5a421fa91d5c30c8d2238360fbce765d4af2))

## [1.5.1](https://github.com/jellydn/hurl.nvim/compare/v1.5.0...v1.5.1) (2024-06-10)

### Bug Fixes

- **split:** no fold find if foldexpr setup ([#166](https://github.com/jellydn/hurl.nvim/issues/166)) ([42df991](https://github.com/jellydn/hurl.nvim/commit/42df991fc28f0099e1965f2fedbfa96f8d00a73b))

## [1.5.0](https://github.com/jellydn/hurl.nvim/compare/v1.4.0...v1.5.0) (2024-05-28)

### Features

- **hurl:** add buffer name for split response window ([#163](https://github.com/jellydn/hurl.nvim/issues/163)) ([fbc1377](https://github.com/jellydn/hurl.nvim/commit/fbc1377ace478936bb4c425e48cd34af3ffc81c0))
- **hurl:** use global config for finding environment files ([6d40061](https://github.com/jellydn/hurl.nvim/commit/6d400613c92c2395471ca7f3de7991d7e8c488d9))

### Bug Fixes

- **history:** add early return for missing response headers ([29af39b](https://github.com/jellydn/hurl.nvim/commit/29af39ba93a5f56b706991a081480b5738b53eb3))

## [1.4.0](https://github.com/jellydn/hurl.nvim/compare/v1.3.1...v1.4.0) (2024-05-02)

### Features

- add HurlShowLastResponse command to show last request response ([1075110](https://github.com/jellydn/hurl.nvim/commit/1075110f334a1ae8fb10554611befa4b58caabdf))
- **hurl.nvim:** add variable editing functionality in HurlManageVariable buffer ([7e56e3f](https://github.com/jellydn/hurl.nvim/commit/7e56e3f9249dde6e18a52f01779fa702044bced9))

## [1.3.1](https://github.com/jellydn/hurl.nvim/compare/v1.3.0...v1.3.1) (2024-03-28)

### Bug Fixes

- update the implementation method of obtaining the git root direc… ([#146](https://github.com/jellydn/hurl.nvim/issues/146)) ([c16f7f6](https://github.com/jellydn/hurl.nvim/commit/c16f7f60a4df043cd3b136aa5fb519de668c6148))

## [1.3.0](https://github.com/jellydn/hurl.nvim/compare/v1.2.1...v1.3.0) (2024-03-19)

### Features

- **http_utils:** add support for finding HTTP verbs in buffer for stable neovim ([c10a905](https://github.com/jellydn/hurl.nvim/commit/c10a9053d51fe96c94f1be8eee4df582bc705708))
- **hurl.nvim:** improve treesitter parser detection and warnings ([00d76db](https://github.com/jellydn/hurl.nvim/commit/00d76db0a668767b2dd4da6cebe499ba21a354ee))
- **hurl:** add support for global variables ([d67e972](https://github.com/jellydn/hurl.nvim/commit/d67e9721e9902b2a01cf87b2d994f6956061668b))
- **popup:** add show_text function and refactor commands ([4408df9](https://github.com/jellydn/hurl.nvim/commit/4408df92de8410b59205784832b06fdb2994c092))

## [1.2.1](https://github.com/jellydn/hurl.nvim/compare/v1.2.0...v1.2.1) (2024-03-14)

### Bug Fixes

- add case-insensitive content-type header detection ([89ea4d4](https://github.com/jellydn/hurl.nvim/commit/89ea4d49371b836dc9e1451dab084576a4f063a9))
- **hurl:** Improve HurlRunnerToEntry command and remove unnecessary log ([4d4e4ff](https://github.com/jellydn/hurl.nvim/commit/4d4e4ff9df020522dca8a6dc9ea7fd3dfa25069d))

## [1.2.0](https://github.com/jellydn/hurl.nvim/compare/v1.1.3...v1.2.0) (2024-03-14)

### Features

- **hurl:** add spinner to indicate request progress ([0e307f3](https://github.com/jellydn/hurl.nvim/commit/0e307f327201ad08817118c5819650c86c6253a0))

### Bug Fixes

- HurlRunnterToEntry using treesitter ([8885e2f](https://github.com/jellydn/hurl.nvim/commit/8885e2f216d0bdd8b24a2de494342bd4d80de02c))

## [1.1.3](https://github.com/jellydn/hurl.nvim/compare/v1.1.2...v1.1.3) (2024-03-13)

### Reverts

- revert to find verb instead of treesitter parser ([1bb1106](https://github.com/jellydn/hurl.nvim/commit/1bb1106b0357eb2ce6117a4e2fa5196592db9d12))

## [1.1.2](https://github.com/jellydn/hurl.nvim/compare/v1.1.1...v1.1.2) (2024-03-13)

### Bug Fixes

- add body state handling for payload is too big ([c596962](https://github.com/jellydn/hurl.nvim/commit/c596962d952bef76dd3c34580e54c803069e84ef))

## [1.1.1](https://github.com/jellydn/hurl.nvim/compare/v1.1.0...v1.1.1) (2024-03-09)

### Reverts

- add find http verb position util ([f77a52f](https://github.com/jellydn/hurl.nvim/commit/f77a52f30629091d2d0032ee2edb63703d7d407d))

## [1.1.0](https://github.com/jellydn/hurl.nvim/compare/v1.0.1...v1.1.0) (2024-03-09)

### Features

- Add treesitter support ([#103](https://github.com/jellydn/hurl.nvim/issues/103)) ([6a16d4f](https://github.com/jellydn/hurl.nvim/commit/6a16d4f9d8b6bc488f9a6bfdf62c204dd80fed8c))

## [1.0.1](https://github.com/jellydn/hurl.nvim/compare/v1.0.0...v1.0.1) (2024-03-01)

### Bug Fixes

- add null check for result before call save log ([b1c4516](https://github.com/jellydn/hurl.nvim/commit/b1c4516c7dbd45fb8cc80e1c87d088155d1b53eb)), closes [#89](https://github.com/jellydn/hurl.nvim/issues/89)

## 1.0.0 (2024-02-15)

### Features

- add custom file type for split ([61ccf1f](https://github.com/jellydn/hurl.nvim/commit/61ccf1f40d0aa42bb7b8fd0a9955854d03f620df))
- add default option for popup mode ([d47c320](https://github.com/jellydn/hurl.nvim/commit/d47c320593e87f0dea4da4704bd29740a80ad49b))
- add health check ([2a0d40b](https://github.com/jellydn/hurl.nvim/commit/2a0d40b019bf73f01d13fb5d3cc15c0e9bb42a2a))
- add HurlToggleMode command ([3063bba](https://github.com/jellydn/hurl.nvim/commit/3063bba232a4055e3c74c87ab76f35cee4890181))
- add new command for run hurl in verbose mode ([460b9f3](https://github.com/jellydn/hurl.nvim/commit/460b9f3223f6c3872ff1565020be3961aec02de4))
- add new command for show debug info ([321305e](https://github.com/jellydn/hurl.nvim/commit/321305efbd6f6d3077918c36d6c71abe27a393e1))
- add new command to change the env file ([a6f0f6d](https://github.com/jellydn/hurl.nvim/commit/a6f0f6dc418892a28a6981c9a0f344c5dd150d33))
- add new option for auto close on lost focus ([2e27b93](https://github.com/jellydn/hurl.nvim/commit/2e27b93e695790761c8490b6a05f6c6441433137))
- add run to entry command ([9d6fdff](https://github.com/jellydn/hurl.nvim/commit/9d6fdffee0a4b805a025650a8be9bd9ee34e6e74))
- bind `q` to quit for split mode ([b449389](https://github.com/jellydn/hurl.nvim/commit/b4493893f8884feea8fad960589ea9f99d521f07))
- clear previous response if buffer still open ([6be36b6](https://github.com/jellydn/hurl.nvim/commit/6be36b6faaafd95def4de0dc7e9baaa8764c63a4))
- enable folding for popup mode ([2a9bf8f](https://github.com/jellydn/hurl.nvim/commit/2a9bf8fa408c72b2c228f59191559a4e73556376))
- init hurl.nvim plugin ([f3f615a](https://github.com/jellydn/hurl.nvim/commit/f3f615a5f674bd1a7aaaad24efbf4fc6140cd2dd))
- init project ([0207117](https://github.com/jellydn/hurl.nvim/commit/020711770e2951b7fe0cf3798e91b8d2b72b7227))
- introduce new config for env file ([2cef196](https://github.com/jellydn/hurl.nvim/commit/2cef1967d96b0c3184333cf19e183bcf24341c6e))
- Make env search maintain provided order ([#69](https://github.com/jellydn/hurl.nvim/issues/69)) ([275368b](https://github.com/jellydn/hurl.nvim/commit/275368ba1d47d594b58a759e2da99938b16d6527))
- notify when hurl is running ([12a5804](https://github.com/jellydn/hurl.nvim/commit/12a5804a2db188a45b3e292bbd8e13cd841191eb))
- only set buffer option on nightly builds ([c3a4311](https://github.com/jellydn/hurl.nvim/commit/c3a4311567c7dee1ea36e305c2a7bbddb030a9b6))
- open quickfix if has any error ([029f784](https://github.com/jellydn/hurl.nvim/commit/029f7843123d79960db584fc5124559a079d2f40))
- port hurl plugin from ray-x/web-tools.nvim ([888bd0f](https://github.com/jellydn/hurl.nvim/commit/888bd0fc18057ba0a4f207895c1bfe9828a65071))
- send tmp file to quicklist on hurl request ([#11](https://github.com/jellydn/hurl.nvim/issues/11)) ([464f28e](https://github.com/jellydn/hurl.nvim/commit/464f28e60665897f3d320166e5fe025183f83b32))
- show content on popup ([0ae2711](https://github.com/jellydn/hurl.nvim/commit/0ae2711d86c28dff390bcfdb6439be3b807bdfb3))
- show error message on qflist ([5d977a2](https://github.com/jellydn/hurl.nvim/commit/5d977a2f33a83eab0eb95e6de8c61fe1841b2319))
- show response header on popup ([ba04d85](https://github.com/jellydn/hurl.nvim/commit/ba04d8585aca917f2e093c213c2fdc70df8dbd62))
- support PATCH method ([fba0251](https://github.com/jellydn/hurl.nvim/commit/fba0251e2421d23c70978678d46a9cc764593c0b))
- support PUT and DELETE method ([2c1b7d2](https://github.com/jellydn/hurl.nvim/commit/2c1b7d2063a47c54c7f30b33af6bf9cce8e8c828))
- support read vars.env file from test folder ([aea1ca5](https://github.com/jellydn/hurl.nvim/commit/aea1ca53ccdf29deab4c2a840f076ef828404b96))

### Bug Fixes

- **ci:** rename secret token for publish doc ([ebd7486](https://github.com/jellydn/hurl.nvim/commit/ebd748605d8a6251a12385fd56b65533d64f29e4))
- **ci:** setup release version ([c4d1447](https://github.com/jellydn/hurl.nvim/commit/c4d144716f6269e9ab7e45089b38179e6d2e085a))
- **ci:** upgrade checkout v4 ([c4d1447](https://github.com/jellydn/hurl.nvim/commit/c4d144716f6269e9ab7e45089b38179e6d2e085a))
- display popup position base on editor ([6951948](https://github.com/jellydn/hurl.nvim/commit/69519488a96e74da67ae3fefc17619a65c1c8c00))
- remove toc ([b810790](https://github.com/jellydn/hurl.nvim/commit/b8107903944d062d9822cef41b4a4491b2cdea97))
- send error to qlist and skip showing the result ([6799811](https://github.com/jellydn/hurl.nvim/commit/679981165305a5494ced10016348f703a57bd5db))
- set highlight for neovim stable ([8317978](https://github.com/jellydn/hurl.nvim/commit/8317978aa439e2506d0f6b2a87c8b674c2bb9ac5))
- simplify the check for json content type ([e8ad1e5](https://github.com/jellydn/hurl.nvim/commit/e8ad1e50e88e698e3a3a57cbe614a0b510587a1b))
- support load multi env files ([9443adc](https://github.com/jellydn/hurl.nvim/commit/9443adc0fa54e04fb9e2e35872022a4efa89dea0))
- support no response on body ([ec4262d](https://github.com/jellydn/hurl.nvim/commit/ec4262d6b6e9169ece39a8cd28405c95d0cb0380))
- **test:** check command exist ([7b4b23d](https://github.com/jellydn/hurl.nvim/commit/7b4b23d32cabf3a5de777266fa4ea24eb0d499da))
