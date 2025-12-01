.PHONY: install start dev clean reinstall check debug help fix-venv test lint format

.DEFAULT_GOAL := help

GREEN  := \033[0;32m
YELLOW := \033[1;33m
CYAN   := \033[0;36m
RED    := \033[0;31m
NC     := \033[0m

# Auto-detect package name
PACKAGE_NAME := $(shell find . -maxdepth 1 -type d -name "mcr_py_*" ! -name "*egg-info*" ! -name "*test*" -exec basename {} \; | head -n 1)
PACKAGE_NAME_HYPHEN := $(shell echo $(PACKAGE_NAME) | tr '_' '-')

help:
	@echo "$(CYAN)Available commands:$(NC)"
	@echo "  $(GREEN)install$(NC)     - Install package in editable mode"
	@echo "  $(GREEN)start$(NC)       - Start the application"
	@echo "  $(GREEN)dev$(NC)         - Development setup (first time)"
	@echo "  $(GREEN)clean$(NC)       - Clean cache and uninstall"
	@echo "  $(GREEN)reinstall$(NC)   - Clean and reinstall"
	@echo "  $(GREEN)check$(NC)       - Check installation status"
	@echo "  $(GREEN)debug$(NC)       - Run with verbose output"
	@echo "  $(GREEN)fix-venv$(NC)    - Fix corrupted virtual environment"
	@echo "  $(GREEN)docker-build$(NC)- Build docker image with SSH forwarding"
	@echo "  $(GREEN)docker-run$(NC)  - Run docker image with .env.local"

docker-build:
	@echo "$(GREEN)Building Docker image...$(NC)"
	@chmod +x build_docker.sh
	@./build_docker.sh

docker-run:
	@echo "$(GREEN)Running Docker container...$(NC)"
	@if [ -f .env.local ]; then \
		docker run -p 8080:8080 --env-file .env.local mcr_py_email_builder_service; \
	else \
		echo "$(YELLOW)Warning: .env.local not found. Running without env file...$(NC)"; \
		docker run -p 8080:8080 mcr_py_email_builder_service; \
	fi

install:
	@echo "$(GREEN)Installing $(PACKAGE_NAME) in editable mode...$(NC)"
	@python -m pip install --upgrade pip setuptools wheel 2>/dev/null || \
		(echo "$(RED)Pip is corrupted. Run 'make fix-venv' first$(NC)" && exit 1)
	@pip install -e .

start:
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)Error: Virtual environment not activated!$(NC)"; \
		echo "$(YELLOW)Run: source venv/bin/activate$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Starting $(PACKAGE_NAME)...$(NC)"
	@bash start.sh

dev:
	@if [ ! -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)Please deactivate venv first: deactivate$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Setting up development environment...$(NC)"
	@rm -rf venv
	@python3 -m venv venv
	@echo "$(GREEN)Upgrading pip...$(NC)"
	@./venv/bin/python -m pip install --upgrade pip setuptools wheel
	@echo "$(GREEN)Cleaning up...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Installing package...$(NC)"
	@./venv/bin/pip install -e .
	@echo ""
	@echo "$(GREEN)✓ Development environment ready!$(NC)"
	@echo "$(YELLOW)Activate venv with: $(CYAN)source venv/bin/activate$(NC)"
	@echo "$(YELLOW)Then run: $(CYAN)make start$(NC)"

clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-all: clean
	@echo "$(RED)Removing virtual environment...$(NC)"
	@rm -rf venv
	@echo "$(GREEN)Complete cleanup done!$(NC)"

reinstall: clean install
	@echo "$(GREEN)Package reinstalled successfully!$(NC)"

check:
	@echo "$(CYAN)Checking installation for $(PACKAGE_NAME)...$(NC)"
	@echo "Package name: $(YELLOW)$(PACKAGE_NAME)$(NC)"
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)Virtual environment: Not activated$(NC)"; \
	else \
		echo "$(GREEN)Virtual environment: $$VIRTUAL_ENV$(NC)"; \
	fi
	@echo ""
	@pip show $(PACKAGE_NAME_HYPHEN) 2>/dev/null || echo "$(YELLOW)Package not installed$(NC)"
	@echo ""
	@if pip show $(PACKAGE_NAME_HYPHEN) 2>/dev/null | grep -q "Editable project location"; then \
		echo "$(GREEN)✓ Package installed in editable mode$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Package not in editable mode$(NC)"; \
	fi

debug:
	@echo "$(YELLOW)Running in debug mode...$(NC)"
	@PYTHONPATH=$$(pwd):$$(pwd)/src python -v $(PACKAGE_NAME)/src/app.py

fix-venv:
	@if [ ! -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)Please deactivate venv first: deactivate$(NC)"; \
		exit 1; \
	fi
	@echo "$(RED)Fixing corrupted virtual environment...$(NC)"
	@rm -rf venv
	@echo "$(GREEN)Creating fresh virtual environment...$(NC)"
	@python3 -m venv venv
	@./venv/bin/python -m pip install --upgrade pip setuptools wheel
	@./venv/bin/pip install -e .
	@echo ""
	@echo "$(GREEN)✓ Virtual environment fixed!$(NC)"
	@echo "$(YELLOW)Activate with: $(CYAN)source venv/bin/activate$(NC)"
	@echo "$(YELLOW)Then run: $(CYAN)make start$(NC)"

info:
	@echo "$(CYAN)Service Information:$(NC)"
	@echo "Package name: $(GREEN)$(PACKAGE_NAME)$(NC)"
	@echo "Package name (pip): $(GREEN)$(PACKAGE_NAME_HYPHEN)$(NC)"
	@echo "App file: $(GREEN)$(PACKAGE_NAME)/src/app.py$(NC)"
	@echo "Working directory: $(GREEN)$$(pwd)$(NC)"

.SILENT: help