.SHELL := /bin/bash
.SHELLFLAGS = -ec
.DEFAULT_GOAL := help

# Variables
IMAGE_NAME?=base-archlinux## The name of the image to build. Default: archlinux
TEST_SCRIPT?=test.sh## The name of the test script. Default: test.sh

# Devcontainer command
DEVCONTAINER=devcontainer
DEVCONTAINER_UP=$(DEVCONTAINER) up
DEVCONTAINER_EXEC=$(DEVCONTAINER) exec

# Devcontainer flags
DEVCONTAINER_UP_FLAGS=--workspace-folder ./src/$(IMAGE_NAME)
DEVCONTAINER_EXEC_FLAGS=--workspace-folder ./src/$(IMAGE_NAME)

# Config variables
CONFIG_SCHEMA=docs/schema.json
IMAGE_METADATA_PATH?=./src/$(IMAGE_NAME)/metadata.json

# Config Validation Command
AJV=npx ajv
AJV_VALIDATE=$(AJV) validate

# Config Validation Flags
AJV_VALIDATE_FLAGS=\
	-s $(CONFIG_SCHEMA) \
	-d $(IMAGE_METADATA_PATH) \
	-c ajv-formats \
	--verbose

.PHONY: up
up: ## Start the devcontainer
	@echo "Starting the devcontainer ($(IMAGE_NAME))..."
	$(DEVCONTAINER_UP) $(DEVCONTAINER_UP_FLAGS)

.PHONY: test
test: ## Test the devcontainer
	@echo "Testing the devcontainer ($(IMAGE_NAME))..."
	$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/bash -c '\
		set -e; \
		pwd; \
		ls -la; \
		cd ./test_project; \
		chmod +x $(TEST_SCRIPT); \
		./$(TEST_SCRIPT)'

validate: $(IMAGE_METADATA_PATH) $(CONFIG_SCHEMA) ## Validate the config file
	@echo "🚀 Validating the configuration file ($(IMAGE_METADATA_PATH))..."
	@$(AJV_VALIDATE) $(AJV_VALIDATE_FLAGS) || (echo "❌ Error. Config file is invalid." && exit 1)
	@echo "✅ OK. Config file is valid."

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m    %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)