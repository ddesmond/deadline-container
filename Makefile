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

repoclean: ## Clean Repository and Client files
	sudo rm -rf ./repository/repository
	sudo rm -rf ./client

clean: ## Stop containers, remove volumes and DB files
	docker compose down --volumes --remove-orphans
	sudo rm -rf ./db/*
	sudo rm -rf ./repository/repository
	sudo rm -rf ./client

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
