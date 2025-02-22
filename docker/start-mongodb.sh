
# This script sets up and starts the MongoDB container for the Journal Organizer project.

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker from: https://docs.docker.com/engine/install/"
  exit 1
fi

# Check if docker-compose is installed
if ! command -v docker compose &> /dev/null; then
  echo "docker-compose is not installed. Please install docker-compose from: https://docs.docker.com/engine/install/"
  exit 1
fi

# Define the docker-compose file name
COMPOSE_FILE="docker-compose.yml"

# Create docker-compose.yml if it doesn't exist
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Creating $COMPOSE_FILE..."
  cat << 'EOF' > "$COMPOSE_FILE"
version: "3.8"

services:
  mongodb:
    image: mongo:6.0
    container_name: journal-mongodb
    restart: always
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_INITDB_DATABASE}
    volumes:
      - ./data/mongo:/data/db
      - ./init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro
EOF
  echo "$COMPOSE_FILE created."
else
  echo "$COMPOSE_FILE already exists. Using existing file."
fi

# Start MongoDB container in detached mode
echo "Starting MongoDB container..."
docker compose up -d

# Display the status of the container
docker compose ps

echo "MongoDB container is up and running!"
