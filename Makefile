### deadline container make file v1.0.0
.EXPORT_ALL_VARIABLES:



dev: # Start Deadline containers
	mkdir -p db repository
	docker compose up

setup: # Setup Deadline containers host
	sh setup.host.sh

down: # Stop Deadline containers
	docker compose down

repoclean: # Clean Repository and Client files
	sudo rm -rf ./repository/client
	sudo rm -rf ./repository/repository

webclean: # Clean Deadline Web App
	docker compose down --volumes --remove-orphans
	docker system prune -af
	sudo rm -rf ./db/*
	sudo rm -rf ./deadline-web-app*

webapp: # Download - Install Deadline Web App
	sh install/setup_deadline-web-app.sh

download: # Download Deadline installer
	sh install/download_deadline.sh

make sync: # Sync Deadline plugins
	@echo "Syncing custom plugins"
	@mv deadline_custom/* repository/repository/custom/

make all: ## Download Deadline, Clone Webapp, and Run all commands to start the Deadline containers
	make download
	make webapp
	make dev


# help
help: ## Display this help screen
	@echo "Makefile for working with Deadline containers"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "-------------------------"