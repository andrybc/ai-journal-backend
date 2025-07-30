# AI-Powered Journal with Automatic Profile Generation

This is a forked version of a full-stack journaling and relationship profiling platform originally created as a team project. The system uses OpenAI to analyze journal content and generate detailed structured profiles automatically. It includes user authentication, notebook and profile CRUD functionality, mobile support, and robust API testing.
---
## Original Repository

This project is a fork of [https://github.com/journal-organizer/journal-organizer], shared with permission. All backend OpenAI integration and the contributions listed above were developed during the collaborative development period.
Link to Original Repo's contributor graph (andrybc):

[https://github.com/journal-organizer/journal-organizer/graphs/contributors] 

---

## Project Overview

The application enables users to create and manage journal entries, while an AI backend analyzes those entries and automatically generates structured profiles of individuals, places, and topics mentioned. These profiles evolve dynamically based on new journal content and are linked to specific notebooks in the database.

Features include:
- OpenAI GPT-4o-mini integration for natural language understanding
- JWT-secured authentication
- MongoDB with Mongoose for database schema management
- Mobile frontend support
- SwaggerHub API documentation
- Docker and PM2 deployment setup

---

## My Contributions

### Full OpenAI Backend Development and Integration
I was solely responsible for designing, developing, and integrating the OpenAI-powered profile generation system within the backend. This includes:
- Creating `openaiService.js` to wrap the OpenAI Node.js SDK
- Defining `extractTags`, `buildProfilePrompt`, and `createProfile` functions
- Using the GPT-4o-mini model with Zod schemas to produce structured JSON
- Implementing profile automation:
  - Profiles are created, updated, or deleted in response to notebook activity
  - Profiles are validated and linked to their source notebooks

### Backend Development (Node.js / Express / MongoDB)
- Built and secured backend API routes for:
  - Authentication (register, login, email verification, password reset)
  - Notebooks (create, update, delete, read)
  - Profiles (manual and AI-generated CRUD)
- Defined and implemented Mongoose schemas for `User`, `Notebook`, and `Profile`
- Integrated `.env` configuration and managed secure keys

### API Testing and Debugging
- Wrote and executed test scripts using `curl`
- Validated and debugged JSON payloads, escaping, and formatting
- Ensured consistent behavior across manual and AI-triggered CRUD operations

### Deployment and Documentation
- Configured Docker Compose for local MongoDB service
- Deployed the backend with PM2 in a production environment
- Authored and updated SwaggerHub documentation for new routes and models
- Structured the backend codebase using Express controllers and services

### Frontend and Team Collaboration
- Developed mobile-friendly UI components in Flutter
- Added frontend token-based auth handling and fetch integration
- Participated in team presentations and sprint check-ins
- Contributed to Git workflow, pull request documentation, and progress tracking

---

## Tech Stack

- Node.js, Express.js
- MongoDB, Mongoose
- OpenAI GPT-4o-mini + Zod
- JWT Authentication
- Docker, PM2
- SwaggerHub for API documentation
- Flutter (mobile frontend)




