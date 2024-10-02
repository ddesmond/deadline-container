dev:
	docker compose up

setup:
	sh setup.host.sh

down:
	docker compose down

cleanrepo:
	sudo rm -rf ./repository/client
	sudo rm -rf ./repository/repository

clean:
	docker compose down --volumes --remove-orphans
	docker system prune -af
	sudo rm -rf ./db/*
	sudo rm -rf ./deadline-web-app*

app:
	sh install/setup_deadline-web-app.sh
