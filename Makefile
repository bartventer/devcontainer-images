SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

# Variables
IMAGE_NAME?=base-archlinux## The name of the image to build. Default: archlinux
TEST_SCRIPT?=test.sh## The name of the test script. Default: test.sh

# Devcontainer command
DC=devcontainer
DC_UP=$(DC) up
DC_EXEC=$(DC) exec

# Devcontainer flags
DC_UP_FLAGS=--workspace-folder ./src/$(IMAGE_NAME)
DC_EXEC_FLAGS=--workspace-folder ./src/$(IMAGE_NAME)

# Config variables
CONFIG_SCHEMA=docs/schema.json
IMAGE_METADATA_PATH?=./src/$(IMAGE_NAME)/metadata.json

.PHONY: metadata/validate
metadata/validate: ## Validate the metadata file
	@echo "🚀 Validating the configuration file ($(IMAGE_METADATA_PATH))..."
	@yarn ajv validate \
		-s $(CONFIG_SCHEMA) \
		-d $(IMAGE_METADATA_PATH) \
		-c ajv-formats \
		--verbose || (echo "❌ Error. Config file is invalid." && exit 1)
	@echo "✅ OK. Config file is valid."

.PHONY: devcontainer/up
devcontainer/up: ## Start the devcontainer
	@echo "Starting the devcontainer ($(IMAGE_NAME))..."
	$(DC_UP) $(DC_UP_FLAGS)

.PHONY: devcontainer/test
devcontainer/test: devcontainer/up ## Test the devcontainer
	@echo "Testing the devcontainer ($(IMAGE_NAME))..."
	$(DC_EXEC) $(DC_EXEC_FLAGS) /bin/bash -c '\
		set -e; \
		pwd; \
		ls -la; \
		cd ./test_project; \
		chmod +x $(TEST_SCRIPT); \
		./$(TEST_SCRIPT)'

.PHONY: devcontainer/upgrade
devcontainer/upgrade: ## Upgrade the devcontainer lockfiles
	./scripts/devcontainer-upgrade.sh

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_\/-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m    %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)