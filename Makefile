.PHONY: all frontend backend

all:
	docker-compose up

frontend:
	docker-compose up client

backend:
	docker-compose up api

