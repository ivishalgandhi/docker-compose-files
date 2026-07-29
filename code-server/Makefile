.PHONY: help build up down restart logs shell health clean backup docker-build

help: ## Show this help message
	@echo "🚀 Code-Server Dev Environment"
	@echo "=============================="
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

docker-build: ## Build using 'docker build' directly (recommended)
	@./docker-build.sh

build: ## Build and start the container (uses docker-compose)
	@./build.sh

up: ## Start the container
	@echo "🚀 Starting container..."
	@docker-compose up -d
	@echo "✅ Container started!"
	@echo "🌐 Access at: http://localhost:$$(grep '^PORT=' .env | cut -d'=' -f2)"

down: ## Stop the container
	@echo "🛑 Stopping container..."
	@docker-compose down
	@echo "✅ Container stopped!"

restart: ## Restart the container
	@echo "🔄 Restarting container..."
	@docker-compose restart
	@echo "✅ Container restarted!"

logs: ## View container logs
	@docker-compose logs -f

shell: ## Enter container shell (zsh)
	@docker-compose exec code-server-dev zsh

bash: ## Enter container shell (bash)
	@docker-compose exec code-server-dev bash

health: ## Run health check
	@./health-check.sh

status: ## Show container status
	@docker-compose ps

rebuild: ## Rebuild container from scratch
	@echo "🔨 Rebuilding container..."
	@docker-compose down
	@docker-compose up -d --build
	@echo "✅ Rebuild complete!"

clean: ## Remove container and volumes (CAUTION: deletes data!)
	@echo "⚠️  WARNING: This will delete all data!"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		rm -rf data/ workspace/; \
		echo "✅ Cleaned up!"; \
	else \
		echo "❌ Cancelled"; \
	fi

backup: ## Backup data and workspace
	@echo "💾 Creating backup..."
	@tar -czf backup-$$(date +%Y%m%d-%H%M%S).tar.gz data/ workspace/ .env
	@echo "✅ Backup created: backup-$$(date +%Y%m%d-%H%M%S).tar.gz"

stats: ## Show container resource usage
	@docker stats --no-stream $$(docker-compose ps -q)

install-ext: ## Install VS Code extension (usage: make install-ext EXT=publisher.extension)
	@docker-compose exec code-server-dev code-server --install-extension $(EXT)

list-ext: ## List installed VS Code extensions
	@docker-compose exec code-server-dev code-server --list-extensions

update: ## Update to latest versions
	@echo "📦 Pulling latest images..."
	@docker-compose pull
	@echo "🔨 Rebuilding..."
	@docker-compose up -d --build
	@echo "✅ Update complete!"

test-tools: ## Test if all tools are installed correctly
	@echo "🧪 Testing tools..."
	@docker-compose exec code-server-dev bash -c '\
		echo "Python: $$(python3 --version)"; \
		echo "Node.js: $$(node --version)"; \
		echo "npm: $$(npm --version)"; \
		echo "Go: $$(go version)"; \
		echo "Rust: $$(rustc --version)"; \
		echo "UV: $$(uv --version)"; \
		echo "FZF: $$(fzf --version)"; \
		echo "Ripgrep: $$(rg --version | head -n1)"; \
		echo "Bat: $$(bat --version | head -n1)"; \
		echo "Glow: $$(glow --version)"; \
		echo "DuckDB: $$(duckdb --version)"; \
		echo "Neovim: $$(nvim --version | head -n1)"; \
		echo "Docker: $$(docker --version)"; \
		echo "Git: $$(git --version)"; \
		echo "Ollama: $$(ollama --version)"; \
		echo ""; \
		echo "🤖 Ollama service:"; \
		if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then \
			echo "  Status: ✅ Running"; \
			echo "  Models: $$(curl -s http://localhost:11434/api/tags | grep -o \"name\":\"[^\"]*\" | cut -d: -f2 | tr -d \" | wc -l)"; \
		else \
			echo "  Status: ❌ Not running"; \
		fi; \
		echo "GitHub CLI: $$(gh --version | head -n1)"; \
		echo "Markitdown: installed"; \
	'
	@echo "✅ Tool test complete!"

port: ## Show the port code-server is running on
	@echo "🌐 Port: $$(grep '^PORT=' .env | cut -d'=' -f2)"
	@echo "🔗 URL: http://localhost:$$(grep '^PORT=' .env | cut -d'=' -f2)"

config: ## Show current configuration
	@echo "⚙️  Current Configuration:"
	@echo "========================"
	@grep -E '^[A-Z_]+=' .env

quick: ## Quick start for first time users
	@echo "🚀 Quick Start"
	@echo "============="
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env file..."; \
		cp .env.example .env; \
		echo "✅ Created .env"; \
		echo "⚠️  IMPORTANT: Edit .env and change PASSWORD"; \
		echo ""; \
		read -p "Press Enter after editing .env..."; \
	fi
	@echo "🔨 Building and starting..."
	@docker-compose up -d --build
	@echo ""
	@echo "✅ Setup complete!"
	@echo "🌐 Access at: http://localhost:$$(grep '^PORT=' .env | cut -d'=' -f2)"
	@echo "📝 View logs: make logs"
