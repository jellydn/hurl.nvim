.PHONY: help
help:
		@echo "install - install vusted"
		@echo "test    - run test"

.PHONY: install-cli
install-cli:
	brew install luarocks
	brew install lua

.PHONY: install
install:
	luarocks install vusted

.PHONY: test
test:
	vusted test

.PHONY: report
report:
	@echo "Generating report"
	rm -rf report
	hurl --test --report-html report --variables-file test/vars.env test/*.hurl
	bunx serve report
