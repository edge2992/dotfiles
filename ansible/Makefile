launch:
	docker compose up -d

shell:
	echo "run `ansible-playbook playbooks/site.yml -i local`"
	docker compose exec ansible-controller bash

down:
	docker compose down