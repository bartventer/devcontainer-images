.SHELLFLAGS = -ec
.ONESHELL:

# Variables
IMAGE_NAME?=archlinux## The name of the image to build. Default: archlinux

# Devcontainer command
DEVCONTAINER=devcontainer

# Devcontainer flags
DEVCONTAINER_UP_FLAGS=up --id-label test-container=$(IMAGE_NAME) --workspace-folder src/$(IMAGE_NAME)/
DEVCONTAINER_EXEC_FLAGS=exec --workspace-folder src/$(IMAGE_NAME)/ --id-label test-container=$(IMAGE_NAME)

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m    %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the image
	@echo "IMAGE_NAME: $(IMAGE_NAME)"
	@echo "Building the image..."
	$(DEVCONTAINER) $(DEVCONTAINER_UP_FLAGS)

.PHONY: test
test: build ## Test the image
	@echo "Testing the image..."
	$(DEVCONTAINER) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
		set -e; \
		if [ -f "test_project/test.sh" ]; then \
			cd test_project; \
			if [ "$(id -u)" = "0" ]; then \
				chmod +x test.sh; \
			else \
				sudo chmod +x test.sh; \
			fi; \
			./test.sh; \
		else \
			ls -a; \
		fi'

.PHONY: clean
clean: ## Clean up the built image and containers
	@container_id=$$(docker ps -q -f ancestor=$(IMAGE_NAME)); \
	if [ -n "$$container_id" ]; then \
		docker stop $$container_id > /dev/null 2>&1; \
		docker rm $$container_id > /dev/null 2>&1; \
	fi
	@docker rmi $(IMAGE_NAME) > /dev/null 2>&1