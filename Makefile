.PHONY: help build run dev lint format migrate-up migrate-down docs-generate docker-up docker-down graph-generate

help:
	@echo "Available commands:"
	@echo "  make build          - Build the application"
	@echo "  make run            - Run the application"
	@echo "  make dev            - Run the application in development mode"
	@echo "  make lint           - Run linter on the codebase"
	@echo "  make format         - Format the code and re-arrange imports"
	@echo "  make migrate-up     - Apply database migrations"
	@echo "  make migrate-down   - Rollback database migrations"
	@echo "  make docs-generate  - Generate Swagger documentation"
	@echo "  make docker-up      - Start Docker services"
	@echo "  make docker-down    - Stop Docker services"
	@echo "  make graph-generate - Generate GraphQL code"

build:
	@echo "Building all binaries...."
	@mkdir -p bin
	@for cmd in cmd/*/; do \
		if [ -d "$$cmd" ]; then \
			binary=$$(basename $$cmd); \
			echo "Building $$binary..."; \
			go build -o bin/$$binary ./$$cmd; \
		fi \
	done

run:
	go run ./cmd/api

dev:
	go run ./cmd/api

lint: format
	golangci-lint run ./...

format:
	@gofmt -s -w .
	@goimports -w .

docs-generate:
	@mkdir -p docs
	@swag init -g cmd/api/main.go -o docs --parseDependency --parseInternal --exclude .git,docs,docker,db

migrate-up:
	@set -a; . ./.env; set +a; \
	migrate -path db/migrations -database "$$DB_URL_POSTGRES" up

migrate-down:
	@set -a; . ./.env; set +a; \
	migrate -path db/migrations -database "$$DB_URL_POSTGRES" down

docker-up:
	docker compose -f docker/docker-compose.yml up -d

docker-down:
	docker compose -f docker/docker-compose.yml down

graph-generate:
	@go get github.com/99designs/gqlgen@v0.17.78
	@go run github.com/99designs/gqlgen generate
