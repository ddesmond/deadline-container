### deadline container make file v2.0.0
.EXPORT_ALL_VARIABLES:

-include .env

dev: ## Start Deadline containers
	mkdir -p db repository client
	docker compose up

setup: ## Setup Deadline containers host
	sh setup.host.sh

down: ## Stop Deadline containers
	docker compose down

download: ## Check for Deadline installer tarball
	sh install/download_deadline.sh

repoclean: ## Clean installed repository and client files (keeps placeholders)
	find ./repository -mindepth 1 -not -name '.deadlinerepo' -delete 2>/dev/null || true
	find ./client -mindepth 1 -delete 2>/dev/null || true

clean: ## Stop containers, remove named volumes, DB and installed files
	docker compose down --volumes --remove-orphans
	sudo rm -rf ./db/*
	find ./repository -mindepth 1 -not -name '.deadlinerepo' -delete 2>/dev/null || true
	find ./client -mindepth 1 -delete 2>/dev/null || true

sync: ## Sync custom Deadline plugins into the repository
	@echo "Syncing custom plugins"
	@mv deadline_custom/* repository/repository/custom/

all: ## Check installer and start all Deadline containers
	make download
	make dev

# help
help: ## Display this help screen
	@echo "Makefile for working with Deadline containers"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "-------------------------"
