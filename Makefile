setup:
	docker-compose run web mix deps.get && \
	docker-compose run web mix ecto.create && \
	docker-compose run web mix ecto.migrate && \
	docker-compose up -d

up:
	docker-compose up

down:
	docker-compose down