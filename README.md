# AI-Powered Journal with Automatic Profile Generation

This is a **forked version** of a full-stack journaling and relationship profiling platform originally created as a team project. The system uses OpenAI to analyze journal content and automatically generate detailed, structured profiles. The platform includes:

- User authentication
- Notebook and profile CRUD functionality
- Mobile support
- Robust API testing and documentation

---

## 🔗 Original Repository

This project is a fork of the original repository:  
**[journal-organizer/journal-organizer](https://github.com/journal-organizer/journal-organizer)**  
Forked and showcased with permission.

See contributor graph (including contributions under `andrybc`):  
**[GitHub Contributor Graph](https://github.com/journal-organizer/journal-organizer/graphs/contributors)**

---

## 📌 Project Overview

The application allows users to create and manage journal entries. An integrated OpenAI backend analyzes each entry and automatically generates structured profiles for individuals, places, and topics mentioned. These profiles evolve as the user adds more entries, and are linked to specific notebooks in the system.

### Key Features:
- GPT-4o-mini integration for journal analysis and profile creation
- Secure authentication with JWT
- MongoDB + Mongoose schema-driven data modeling
- Dockerized MongoDB setup with PM2 deployment
- Mobile-friendly frontend (Flutter)
- Documented APIs with SwaggerHub

---

## 🛠️ My Contributions

### 🧠 Full OpenAI Backend Development & Integration
- Designed and implemented the full OpenAI integration system
- Created `openaiService.js` to handle GPT requests and structured output
- Defined `extractTags`, `buildProfilePrompt`, and `createProfile` functions
- Used Zod for schema validation of AI-generated profile JSON
- Enabled automatic profile creation/updates on notebook changes

### 💻 Backend Development (Node.js / Express / MongoDB)
- Built secure API routes for:
  - Authentication: register, login, email verification, reset password
  - Notebooks: create, update, delete, read
  - Profiles: manual and AI-driven CRUD
- Defined Mongoose schemas: `User`, `Notebook`, `Profile`
- Managed `.env` key integration for secure config

### 🧪 API Testing & Debugging
- Developed and executed `curl` test scripts
- Debugged JSON parsing, escaping, and formatting issues
- Ensured proper operation of manual and automated CRUD routes

### 🚀 Deployment & Documentation
- Configured Docker Compose for local MongoDB deployment
- Used PM2 for backend deployment and logging
- Created and maintained SwaggerHub docs for the backend API
- Structured backend code using modular Express controllers and services

### 📱 Frontend Integration & Team Collaboration
- Developed mobile functionality using Flutter
- Integrated token-based auth into frontend fetch requests
- Participated in team meetings and sprint presentations
- Helped manage Git workflow, PR documentation, and task tracking

---

## 🧰 Tech Stack

**Backend:**
- Node.js
- Express.js
- MongoDB + Mongoose
- OpenAI (GPT-4o-mini)
- Zod
- JWT Authentication
- PM2
- Docker

**Frontend:**
- Flutter (mobile interface)

**Tooling & Documentation:**
- SwaggerHub
- `curl` for API testing
- GitHub Projects for task management
