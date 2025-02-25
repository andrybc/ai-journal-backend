# journal-organizer





Below is a step‐by‐step guide for =developers to set up their local PC so they can run the entire backend environment—from installing Node.js to using Docker Desktop and connecting to MongoDB as an admin. This guide assumes a Windows environment (using Git Bash or PowerShell), but it can be adapted for other operating systems.

---

## **1. Install Node.js and npm**

- **Download and Install:**  
  Visit the [Node.js website](https://nodejs.org/) and download the latest LTS installer.  
  Run the installer and follow the prompts.

- **Verify Installation:**  
  Open a terminal (Git Bash or PowerShell) and run:
  ```bash
  node -v
  npm -v
  ```
  You should see the version numbers for both.

---

## **2. Set Up Git and Create an SSH Key (if you don’t already have one)**

- **Check for Existing SSH Key:**  
  Open Git Bash and run:
  ```bash
  ls ~/.ssh
  ```
  Look for files like `id_rsa` and `id_rsa.pub`. If they exist, you already have a key.

- **Create an SSH Key (if needed):**  
  If you don’t have an SSH key, generate one:
  ```bash
  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  ```
  Accept the defaults (press Enter) and optionally add a passphrase.

- **Add Your SSH Key to GitHub:**  
  - Copy the public key:
    ```bash
    cat ~/.ssh/id_rsa.pub
    ```
  - Log in to GitHub, go to **Settings > SSH and GPG keys**, click **New SSH key**, paste your key, and save.

---

## **3. Clone the Repository Using SSH**

- **Clone the Repo:**  
  Open Git Bash, navigate to your desired working directory, and clone:
  ```bash
  git clone git@github.com:SimHoZebs/journal-organizer.git
  ```
- **Checkout the Appropriate Branch:**  
  If you are working on a specific branch (e.g., `potential_setup`), navigate into the repo and run:
  ```bash
  cd journal-organizer
  git checkout potential_setup
  ```

---

## **4. Set Up Environment Variables**

- **Create a .env File:**  
  In the backend directory (or the repository root if that’s where your code loads it), create a file named `.env` with the required variables. For example:
  ```dotenv
  # For MongoDB initialization (admin credentials)
  MONGO_INITDB_ROOT_USERNAME==
  MONGO_INITDB_ROOT_PASSWORD==
  MONGO_INITDB_DATABASE==

  # If using these for application user (if applicable)
  APP_MONGO_DB==
  APP_MONGO_USER=
  APP_MONGO_PASS=
  # Application port and JWT secret
  PORT==
  JWT_SECRET==

  # MongoDB connection URI (for backend to connect)
  MONGO_URI==
  ```
  **Note:**  
  Ensure your `.env` is listed in `.gitignore` so it isn’t committed.

---

## **5. Install Docker Desktop**

- **Download and Install Docker Desktop:**  
  Visit [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) and follow the installation instructions.  
  Once installed, launch Docker Desktop and verify that it’s running.

---

## **6. Set Up and Run the MongoDB Container**

- **Navigate to the Docker Directory:**  
  In your repository, you should have a `docker` folder (or the appropriate location for your Docker files).  
  If your `start-mongodb.sh` script is in that directory, navigate there:
  ```bash
  cd docker
  ```

- **Ensure Environment Variables Are Loaded:**  
  Your `start-mongodb.sh` script should load variables from the `.env` file.

- **Run the start-mongodb.sh Script:**  
  In Git Bash or a similar terminal, run:
  ```bash
  ./start-mongodb.sh
  ```
  This script does the following:
  - Loads your environment variables.
  - Dynamically generates the `init-mongo.js` file with your app credentials.
  - Creates (or reuses) a `docker-compose.yml` that sets up a MongoDB container.
  - Starts the MongoDB container with the correct port mapping and initialization script.

- **Verify the Container is Running:**  
  Use:
  ```bash
  docker compose ps
  docker logs journal-mongodb
  ```
  Check for debug messages from `init-mongo.js` (if reinitialization occurs) or confirm that the container is up.

- **Test MongoDB Connection (Optional):**  
  Connect to MongoDB as an admin:
  ```bash
  docker exec -it journal-mongodb mongosh -u adminUser -p adminPassword --authenticationDatabase admin
  ```
  Or, if you want to test with the application user (if reinitialized):
  ```bash
  docker exec -it journal-mongodb mongosh -u dbUser -p dbUserPass --authenticationDatabase journaldb
  ```

---

## **7. Install Backend Dependencies and Run the Server**

- **Navigate to the Backend Directory:**  
  ```bash
  cd ../backend
  ```
- **Install Dependencies:**  
  Run:
  ```bash
  npm install
  ```
- **Start Your Backend Server:**  
  You can start the server directly:
  ```bash
  node server.js
  ```


