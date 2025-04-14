SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

# Variables
IMAGE_NAME?=base-archlinux## The name of the image to build. Default: archlinux
DC_CONFIG?=./src/$(IMAGE_NAME)/.devcontainer/devcontainer.json## The path to the devcontainer configuration file.

# File variables
SCRIPTSDIR?=./scripts## The directory where the scripts are located.
LOCKFILE_SCRIPT=$(SCRIPTSDIR)/devcontainer-lock.sh## The script to lock the devcontainer configuration.

# Build variables
ifndef GITHUB_RUN_ID
BUILD_JOB_NUMBER=$(shell date +%s)
else
BUILD_JOB_NUMBER=$(shell echo ${GITHUB_RUN_ID})
endif
DATE_TAG := $(shell date +%Y%m%d)
NEXT_VERSION := $(shell echo ${DATE_TAG}.${BUILD_JOB_NUMBER})

# Devcontainer command
DC=devcontainer
DC_FLAGS=--workspace-folder ./src/$(IMAGE_NAME)

## Testing:
.PHONY: devcontainer/test
devcontainer/test: TEST_SCRIPT := test.sh
devcontainer/test: devcontainer/up ## Test the devcontainer
	$(DC) exec $(DC_FLAGS) /bin/bash -c '\
		set -e; \
		pwd; \
		ls -la; \
		cd ./test_project; \
		chmod +x $(TEST_SCRIPT); \
		./$(TEST_SCRIPT)'

## Build:
.PHONY: metadata/validate
metadata/validate: ## Validate the metadata file
	$(SCRIPTSDIR)/validate-metadata.sh $(IMAGE_NAME)

.PHONY: devcontainer/up
devcontainer/up: ## Start the devcontainer
	$(DC) up $(DC_FLAGS)

.PHONY: devcontainer/lock
devcontainer/lock: ## Upgrade the devcontainer lock file. Arguments: DC_CONFIG.
	$(LOCKFILE_SCRIPT) $(DC_CONFIG)

.PHONY: devcontainer/lock-all
devcontainer/lock-all: ## Upgrade all devcontainer lock files.
	find ./src -name devcontainer.json -exec $(LOCKFILE_SCRIPT) {} \;

.PHONY: devcontainer/build
devcontainer/build: ## Build the devcontainer
	$(SCRIPTSDIR)/build.sh $(IMAGE_NAME) $(NEXT_VERSION)

.PHONY: devcontainer/generate-readme
devcontainer/generate-readme: ## Generate the README file.
	$(SCRIPTSDIR)/generate-readme.sh $(IMAGE_NAME)

.PHONY: devcontainer/create-pr
devcontainer/create-pr: ## Create a pull request for the devcontainer.
	$(SCRIPTSDIR)/create-pr.sh $(IMAGE_NAME) $(NEXT_VERSION)

.PHONY: devcontainer/build-push
devcontainer/build-push: devcontainer/lock devcontainer/build devcontainer/generate-readme devcontainer/create-pr ## Build and push the devcontainer

## Help:
.PHONY: help
help: GREEN  := $(shell tput -Txterm setaf 2)
help: YELLOW := $(shell tput -Txterm setaf 3)
help: CYAN   := $(shell tput -Txterm setaf 6)
help: RESET  := $(shell tput -Txterm sgr0)
help: ## Show this help
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z0-9_\/-]+:.*?##.*$$/) {printf "    ${YELLOW}%-30s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)