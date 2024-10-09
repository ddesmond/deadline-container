dev:
	mkdir -p db repository
	docker compose up

setup:
	sh setup.host.sh

down:
	docker compose down

repoclean:
	sudo rm -rf ./repository/client
	sudo rm -rf ./repository/repository

webclean:
	docker compose down --volumes --remove-orphans
	docker system prune -af
	sudo rm -rf ./db/*
	sudo rm -rf ./deadline-web-app*

webapp:
	sh install/setup_deadline-web-app.sh

download:
	sh install/download_deadline.sh


make sync:
	@echo "Syncing custom plugins"
	@mv deadline_custom/* repository/repository/custom/
