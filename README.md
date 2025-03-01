# Journal Organizer

## Setup Instructions

1. Install:
- Node.js
- Docker Desktop

2. Clone the Repository
```bash
git clone git@github.com:SimHoZebs/journal-organizer.git
cd journal-organizer
```

3. Set Up Environment Variables
```bash
make setup
```
This will create a `.env` file from the template. Update it with your MongoDB credentials.

4. Start the Application
```bash
make dev
```
This will:
- Start MongoDB container on port 27017
- Start the backend server on port 3000
- Start the frontend development server on port 5173

5. Stop All Services
```bash
make stop
```

## Available Make Commands

- `make setup` - Setup environment and install dependencies
- `make dev` - Start all services (MongoDB, backend, frontend)
- `make mongodb` - Start MongoDB container only
- `make backend` - Start backend server only
- `make frontend` - Start frontend dev server only
- `make stop` - Stop all running services

## Project Structure

- `/backend` - Express.js API server
- `/frontend` - React + TypeScript frontend
- `docker-compose.yml` - MongoDB container configuration
