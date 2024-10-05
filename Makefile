launch:
	docker compose up -d

shell:
	docker compose exec ansible-controller bash

down:
	docker compose down