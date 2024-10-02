dev:
	docker compose up

down:
	docker compose down

clean:
	docker compose down --volumes --remove-orphans
	docker system prune -af
	sudo rm -rf ./db/*