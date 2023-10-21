.PHONY: help
help:
		@echo "install - install vusted"
		@echo "test    - run test"

.PHONY: install-cli
install-cli:
	brew install luarocks
	brew install lua@5.1

.PHONY: install
install:
	luarocks --lua-version=5.1 install vusted

.PHONY: test
test:
	vusted test
