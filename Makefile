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

clean:
	docker compose down --volumes --remove-orphans
	docker system prune -af
	sudo rm -rf ./db/*
	sudo rm -rf ./deadline-web-app*

app:
	sh install/setup_deadline-web-app.sh

download:
	sh install/download_deadline.sh
