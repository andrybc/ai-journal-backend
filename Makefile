.PHONY: start stop mongodb frontend backend dev

start: mongodb frontend backend

stop:
	docker compose down

mongodb:
	docker compose up -d mongodb

frontend:
	cd frontend && npm run dev

backend:
	cd backend && npm run dev

setup:
	@echo "Setting up environment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from template. Please update with your credentials."; \
	else \
		echo ".env file already exists."; \
	fi
	@echo "Installing backend dependencies..."
	cd backend && npm install
	@echo "Installing frontend dependencies..."
	cd frontend && npm install
	@echo "Setup complete!"

help:
	@echo "Available commands:"
	@echo "  make setup    - Setup environment and install dependencies"
	@echo "  make dev      - Start all services (MongoDB, backend, frontend)"
	@echo "  make mongodb  - Start MongoDB container only"
	@echo "  make backend  - Start backend server only"
	@echo "  make frontend - Start frontend dev server only"
	@echo "  make stop     - Stop all services"
