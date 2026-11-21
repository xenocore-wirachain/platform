COMPOSE := docker compose -f wirachain-docker/docker-compose.yml

.PHONY: help init update status env up down restart logs ps clean dev-backend dev-frontend dev-contracts test-backend test-frontend

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

init: ## Fetch and check out all git submodules
	git submodule update --init --recursive

update: ## Advance all submodules to the latest commit on their default branch
	git submodule update --remote --recursive

status: ## Show submodule commits and working tree status
	@git submodule status
	@git status --short

env: ## Create wirachain-docker/.env from the template (does not overwrite)
	@test -f wirachain-docker/.env || cp wirachain-docker/.env.template wirachain-docker/.env
	@echo "wirachain-docker/.env is ready - review it before running 'make up'."

up: env ## Build and start the full stack in the background
	$(COMPOSE) up -d --build

down: ## Stop and remove the containers
	$(COMPOSE) down

restart: ## Restart all containers
	$(COMPOSE) restart

logs: ## Follow logs of all services
	$(COMPOSE) logs -f

ps: ## Show the status of all services
	$(COMPOSE) ps

clean: ## Stop the stack and delete volumes (removes database data)
	$(COMPOSE) down -v

dev-backend: ## Run the .NET backend locally
	cd wirachain-backend && dotnet restore && dotnet run

dev-frontend: ## Run the React frontend locally
	cd wirachain-frontend && npm install && npm run dev

dev-contracts: ## Build the smart-contract toolkit locally
	cd wirachain-smart-contract-deployment && npm install && npm run build

test-backend: ## Run backend tests
	cd wirachain-backend && dotnet test

test-frontend: ## Run frontend tests
	cd wirachain-frontend && npm test
