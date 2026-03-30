.PHONY: help setup setup-backend setup-frontend run run-backend run-frontend stop clean lint env check-env n8n n8n-stop

UV_CACHE_DIR ?= .uv-cache

# Default target
help: ## Show this help message
	@echo "LLM Council - Makefile Commands"
	@echo "================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ---------- Setup ----------

setup: setup-backend setup-frontend ## Install all dependencies (backend + frontend)
	@echo ""
	@echo "Setup complete! Run 'make run' to start the application."

setup-backend: ## Install Python backend dependencies via uv
	UV_CACHE_DIR=$(UV_CACHE_DIR) uv sync

setup-frontend: ## Install frontend npm dependencies
	cd frontend && npm install

# ---------- Environment ----------

env: ## Create .env file from template (interactive)
	@if [ -f .env ]; then \
		echo ".env already exists. Remove it first if you want to regenerate."; \
	else \
		read -p "Enter your OpenRouter API key: " key; \
		echo "OPENROUTER_API_KEY=$$key" > .env; \
		echo ".env created successfully."; \
	fi

check-env: ## Verify that the .env file and API key are set
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found. Run 'make env' to create it."; \
		exit 1; \
	fi
	@if ! grep -q "OPENROUTER_API_KEY=." .env; then \
		echo "ERROR: OPENROUTER_API_KEY is not set in .env"; \
		exit 1; \
	fi
	@echo "Environment OK."

# ---------- Run ----------

run: check-env ## Start both backend and frontend
	@echo "Starting LLM Council..."
	@echo ""
	@$(MAKE) run-backend &
	@sleep 2
	@$(MAKE) run-frontend
	@wait

run-backend: ## Start the FastAPI backend (port 8001)
	UV_CACHE_DIR=$(UV_CACHE_DIR) uv run python -m backend.main

run-frontend: ## Start the Vite frontend dev server (port 5173)
	cd frontend && npm run dev

stop: ## Stop all running LLM Council processes
	@echo "Stopping LLM Council..."
	@-pkill -f "backend.main" 2>/dev/null || true
	@-pkill -f "vite" 2>/dev/null || true
	@echo "Stopped."

# ---------- Build & Lint ----------

build: ## Build the frontend for production
	cd frontend && npm run build

lint: ## Run frontend linter
	cd frontend && npm run lint

# ---------- n8n Integration ----------

n8n: ## Start n8n workflow automation (via Docker)
	@echo "Starting n8n on http://localhost:5678 ..."
	docker compose -f docker-compose.n8n.yml up -d
	@echo ""
	@echo "n8n is running at http://localhost:5678"
	@echo "Import the workflow from n8n/llm-council-workflow.json"

n8n-stop: ## Stop n8n
	docker compose -f docker-compose.n8n.yml down

# ---------- Cleanup ----------

clean: stop ## Stop servers and remove generated files
	rm -rf frontend/node_modules frontend/dist
	rm -rf data/
	rm -rf __pycache__ backend/__pycache__
	@echo "Cleaned."
