.PHONY: mirror help
.DEFAULT_GOAL := help

FILE_MIRROR_LIST=etc/mirror.list

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

mirror: ## start apt-mirror with local config
	apt-mirror ${FILE_MIRROR_LIST}

gpg-keys: ## searching for GPG public keys
	bash ./var/gpg-keys.sh

http-server: ## start local mirror server
	cd ./mirror && python3 -m http.server 8000

