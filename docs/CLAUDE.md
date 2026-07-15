# Three Big Things - Claude Code Guide

## Project Overview

A goal-tracking productivity app based on the "Rule of Three" — users track three daily and three weekly goals. Full-stack application with a React frontend and Rails 8 API backend.

## Architecture

```
three-big-things/
├── client/        # React 16 SPA (Create React App + Craco + Tailwind CSS)
├── server/        # Rails 8 API-only app + PostgreSQL
└── docker-compose.yml
```

## Running the Project

**Preferred: Make**

```bash
make          # starts everything (frontend + backend + postgres)
make backend  # starts only the Rails API + postgres
make frontend # starts only the React client
# Frontend: http://localhost:3000
# Backend:  http://localhost:8080
# Postgres: localhost:5432
```

**Manual (server)**

```bash
cd server
bundle install
bundle exec rails db:create db:migrate
bundle exec rails server -b 0.0.0.0 -p 8080
```

**Manual (client)**

```bash
cd client
npm install
npm start           # dev server on :3000
npm run build       # production build
```

## Tech Stack

| Layer           | Technology                                     |
| --------------- | ---------------------------------------------- |
| Legacy Frontend | React 16, React Router v5, Tailwind CSS, Craco |
| New Frontend    | iOS Native, Swift, SwiftUI                     |
| Backend         | Ruby 3.3, Rails 8 (API-only)                   |
| ORM             | ActiveRecord                                   |
| Database        | PostgreSQL 14                                  |
| Auth            | JWT + Google OAuth 2.0 (googleauth gem)        |
| Container       | Docker + Docker Compose                        |

## Database

**Schema:** `server/db/migrate/`

- `User` — id (UUID), name, email, password, refresh_token, timezone_offset, streak, last_login, timestamps
- `Goal` — id (int), name, content, period (DAILY|WEEKLY), status (IN_PROGRESS|COMPLETE|NOT_COMPLETED), archived, user_id, timestamps

**Migrations:**

```bash
cd server
bundle exec rails db:migrate        # apply pending migrations
bundle exec rails db:migrate:status # check migration status
```

**Docker Postgres credentials (dev only):**

- User: `jamesonknoll`, Password: `password`, DB: `three-big-things`

## API Endpoints

All protected routes require `x-access-token: <jwt>` header.

| Method | Path         | Auth | Description                   |
| ------ | ------------ | ---- | ----------------------------- |
| GET    | `/`          | No   | Health check                  |
| GET    | `/me`        | Yes  | Current user + refresh JWT    |
| POST   | `/users`     | No   | Register user                 |
| POST   | `/oauth`     | No   | Google OAuth login            |
| GET    | `/goals`     | Yes  | List goals (`?archived=true`) |
| POST   | `/goals`     | Yes  | Create goal                   |
| PUT    | `/goals/:id` | Yes  | Update goal                   |
| DELETE | `/goals/:id` | Yes  | Delete goal                   |

## Authentication Flow

1. Frontend sends Google ID token to `POST /oauth`
2. Backend verifies with `googleauth` gem (`Google::Auth::IDTokens.verify_oidc`)
3. Server upserts user and returns JWT; client stores in `localStorage`
4. Subsequent requests send JWT in `x-access-token` header
5. `authenticate!` before_action in `ApplicationController` validates protected routes

## Environment Variables

**Server** (`server/.env`):

```
DATABASE_URL=postgres://jamesonknoll:password@postgres:5432/three-big-things
JWT_SECRET_KEY=...
JWT_EXP_TIME=360000
GAPI_CLIENT_ID=...
RAILS_ENV=development

# Transactional email via Resend (evensong.jamesonknoll.com is verified)
RESEND_API_KEY=re_...
RESEND_FROM_EMAIL=Evensong <noreply@evensong.jamesonknoll.com>
APP_BASE_URL=http://localhost:8080
```

**Client** (`client/.env.development`):

```
REACT_APP_BASE_URL=http://localhost:8080
REACT_APP_GAPI_CLIENT_ID=...
REACT_APP_GAPI_CLIENT_SECRET=...
```

## Key Files

- `server/app/controllers/application_controller.rb` — JWT auth helpers (`authenticate!`, `generate_jwt`)
- `server/app/controllers/auth_controller.rb` — Google OAuth login
- `server/app/controllers/goals_controller.rb` — Goal CRUD
- `server/app/controllers/users_controller.rb` — User fetch + streak logic
- `server/app/models/user.rb` — User model (has_many goals)
- `server/app/models/goal.rb` — Goal model (belongs_to user)
- `server/config/routes.rb` — Route definitions
- `server/config/initializers/cors.rb` — CORS configuration
- `server/db/migrate/` — Database migrations
- `client/src/App.js` — Router + context providers
- `client/src/providers/AuthProvider.js` — Auth context (useReducer)
- `client/src/providers/DataProvider.js` — Goals state
- `client/src/services/DataService.js` — All API calls (Axios)

## Testing

No active tests are currently configured.

## Notes

- Email/password auth exists in the UI but is not implemented on the backend — only Google OAuth is active
- JWT expiry is set to 100 hours (JWT_EXP_TIME=360000 seconds)
- Timezone offset is stored per user and used for daily/weekly goal rollover and streak logic
- `GAPI_CLIENT_ID` must be set as a shell env var or in docker-compose for OAuth to work
