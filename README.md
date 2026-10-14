# AI Journal with Automatic Profile Generation

A journaling platform that reads your entries and maintains structured profiles of the people in them. Write about a friend across five notebooks, and the system keeps one profile for that friend, rebuilt from everything you have written about them.

This is a fork of a team project, published with permission. The original repository is [journal-organizer/journal-organizer](https://github.com/journal-organizer/journal-organizer); contributions are visible on its [contributor graph](https://github.com/journal-organizer/journal-organizer/graphs/contributors) under `andrybc`.

## What I built

| Area | Files | Scope |
|---|---|---|
| OpenAI integration | `backend/services/openaiService.js` | Entire file. Zod `ProfileSchema`, `extractTags`, `buildProfilePrompt`, `createProfile`, structured-output wiring |
| Profile lifecycle | `backend/services/profileService.js` | Entire file. Notebook-to-profile regeneration, dedup, case-insensitive user-scoped lookup, delete cascade |
| Notebook hooks | `backend/routes/journal.js` | Calls into the profile service on create, update, and delete |
| Profile routes | `backend/routes/profile.js` | Manual and AI-driven profile CRUD |
| Auth routes | `backend/routes/auth.js` | Register, login, email verification, password reset |
| Schemas | `backend/models/` | `User`, `Notebook`, `Summary` (profile) |
| Deployment | `docker-compose.yml`, PM2 config | Local MongoDB, backend process management |
| Documentation | SwaggerHub / OpenAPI | Auth and notebook endpoints |

Work done on the `openai-api` branch of the original repository. The React
frontend and parts of the Flutter client were built by other team members.
---

## The problem

Naive version: send a journal entry to an LLM, get a profile back, store it. This breaks in three ways.

1. **Profiles drift.** Entry two contradicts entry one. Appending summaries compounds the error.
2. **Model output is not a contract.** An LLM asked for JSON returns JSON most of the time. Code that trusts it crashes in production.
3. **Deletes corrupt state.** Remove a notebook and any profile built from it now contains information with no source.

## The approach

**Profiles are derived state, never accumulated state.** A profile is not updated incrementally — it is regenerated from the full set of notebooks currently linked to it. Any notebook change triggers a rebuild from scratch. This makes the operation idempotent: the profile is always a pure function of its current sources, so contradictions resolve and deletes cannot leave orphaned claims behind.

**Model output is schema-enforced, not parsed hopefully.** Profile generation uses OpenAI structured outputs with a Zod schema (`zodResponseFormat` + `openai.beta.chat.completions.parse`), so a 24-field profile object either validates or fails loudly. There is no string parsing in the happy path.

**The prompts are constrained against hallucination.** Tag extraction asks only for primary subjects described in detail, explicitly ignoring passing mentions, so a one-line reference to a coworker does not spawn a profile. Profile generation instructs the model to use only the supplied notes and never to guess at missing fields, with unknown values returned as `null` or an empty array rather than invented.

---

## Architecture

```
Notebook CRUD (create / update / delete)
            |
            v
   profileService.updateProfilesForNotebook(notebook, operation)
            |
   +--------+--------------------------+
   |                                   |
 create / update                     delete
   |                                   |
   v                                   v
extractTags(content)            remove notebook._id from
   |  -> ["Mary", "John"]        every linked profile
   v                                   |
dedupe (normalized Set)          +-----+-----+
   |                             |           |
   v                        no sources    sources remain
find-or-create Profile       -> delete    -> rebuild from
 (case-insensitive title,                    remaining notebooks
  scoped to userId)
   |
   v
gather ALL linked notebooks
   |
   v
createProfile(name, contents)
   |  -> Zod-validated object
   v
format and persist
```

### Why the lookup is case-insensitive and user-scoped

A profile is found by regex match on `profileTitle` anchored and case-insensitive, filtered by `userId`. "mary" and "Mary" across two entries are the same person; "Mary" in two different users' journals are not. A per-run `Set` of normalized names prevents a subject mentioned twice in one entry from being processed twice.

### Delete semantics

Deleting a notebook removes its ID from every profile that referenced it. Profiles with zero remaining sources are deleted outright — a profile with no evidence should not exist. Profiles with sources left are rebuilt from those, so the deleted entry's contribution disappears cleanly rather than lingering in prose.

---

## Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js, Express |
| Database | MongoDB, Mongoose |
| AI | OpenAI `gpt-4o-mini-2024-07-18`, structured outputs |
| Validation | Zod |
| Auth | JWT, bcrypt |
| Email | SendGrid |
| Frontend | React (Vite, Tailwind), Flutter mobile client |
| Infra | Docker Compose, PM2 |
| Tooling | npm workspaces, Biome |

## API

| Method | Route | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Create account |
| POST | `/api/auth/login` | Authenticate, returns JWT |
| POST | `/api/auth/verify-email` | Email verification |
| POST | `/api/auth/reset-password` | Password reset |
| GET/POST/PUT/DELETE | `/api/journal` | Notebook CRUD; writes trigger profile updates |
| GET/POST/PUT/DELETE | `/api/profile` | Profile CRUD |
| GET | `/api/users` | User records |
| GET | `/api/test` | Health check |

---

## Running locally

Requires Node.js 18+, Docker, and an OpenAI API key.

```bash
git clone https://github.com/andrybc/ai-journal-backend.git
cd ai-journal-backend
npm run setup          # copies .env.example to .env, installs workspaces
```

Edit `.env`:

```
PORT=3001
JWT_SECRET=any_long_random_string
MONGO_URI=mongodb://admin:admin@localhost:27017/jo
OPENAI_API_KEY=sk-...
VITE_API_URL=http://localhost:3001/api
SENDGRID_API_KEY=
```

Start MongoDB and the backend:

```bash
npm run mongodb        # docker compose up -d mongodb
npm run dev:backend    # nodemon from backend/
```

Verify:

```bash
curl http://localhost:3001/api/test
# {"message":"Hello from the API!"}
```

`npm run dev` runs the backend and React frontend together. The Flutter client runs separately with `npm run flutter`.

Email verification requires a SendGrid key. Without one, registration still writes the user but the verification mail does not send.

---

## Known limitations

- Profile regeneration is synchronous inside the notebook request. A notebook linked to many profiles makes a slow write; this belongs in a job queue.
- Every notebook write costs two model calls per subject (extract, then generate). There is no caching for unchanged content.
- `extractTags` returns `[]` on any failure rather than surfacing the error, so an API outage silently produces no profiles.
- Name matching is string-based. Two different people with the same first name collapse into one profile.
- No automated test suite. Routes were verified with `curl` scripts during development.
