.PHONY: build install uninstall clean run help

help: ## Show this help message
	@echo "Snappy - macOS Window Snapping Utility"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the release binary
	@echo "🔨 Building Snappy..."
	swift build -c release

install: ## Install Snappy system-wide with LaunchAgent
	@./scripts/install.sh

uninstall: ## Uninstall Snappy from the system
	@./scripts/uninstall.sh

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build

run: ## Run Snappy directly (for development)
	@echo "🚀 Running Snappy..."
	swift run

test: ## Run tests (if any)
	@echo "🧪 Running tests..."
	swift test

