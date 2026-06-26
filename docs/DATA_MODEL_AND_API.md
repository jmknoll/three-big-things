# Intention — Data Model & API Design

**Version:** 0.2 · Draft
**Status:** For review

---

## 1. Scope & Conventions

The app is backed by the Rails API. All user data is server-side; there is no local database on device. The legacy React frontend endpoints (unversioned, at `/`) are deprecated and will be removed once the iOS client is the primary client. All new endpoints live under `/v1`.

**Auth header:** `x-access-token: <jwt>` on every request unless marked **public**.
**Body format:** JSON (`Content-Type: application/json`).
**Dates:** ISO 8601 — datetimes as `2026-03-04T08:00:00Z`, calendar dates as `2026-03-04`.
**Errors:** `{ "error": "human-readable message" }` with an appropriate HTTP status.

---

## 2. Data Model

### 2.1 Entity Relationships

```
User ─────────────┬──── Project ─────────── Milestone
                  │         │                    │
                  │         └──── DailyGoal ─────┘
                  │                   │
                  └───────────────────┘ (user_id)
```

Every `DailyGoal` belongs to a `User` and a `Project`. It optionally belongs to a `Milestone` of that same project. A `DailyGoal` may reference another `DailyGoal` via `carry_forward_of` (self-referential).

---

### 2.2 Users (extend existing table)

| Column                  | Type      | Constraints       | Notes                                      |
| ----------------------- | --------- | ----------------- | ------------------------------------------ |
| `id`                    | UUID      | PK                | Existing                                   |
| `email`                 | string    | unique, not null  | Existing                                   |
| `name`                  | string    |                   | Existing                                   |
| `password`              | string    |                   | Existing (unused for OAuth users)          |
| `timezone_offset`       | integer   |                   | Existing — minutes offset from UTC         |
| `meta_streak_current`   | integer   | default 0         | New — consecutive qualifying days          |
| `meta_streak_longest`   | integer   | default 0         | New — historical best                      |
| `streak_last_calc_date` | date      |                   | New — detects gap days on `/v1/me`         |
| `morning_reminder_time` | string    | default "08:00"   | New — HH:MM local time                     |
| `eod_reminder_time`     | string    | default "20:00"   | New — HH:MM local time                     |
| `notifications_enabled` | boolean   | default true      | New — master toggle                        |
| `onboarding_done`       | boolean   | default false     | New                                        |
| `created_at`            | datetime  | not null          | Existing                                   |
| `updated_at`            | datetime  | not null          | Existing                                   |

> The old `streak` and `last_login` columns are kept during the deprecation window but are no longer written by any new code paths.

---

### 2.3 Projects (new table)

| Column           | Type     | Constraints                | Notes                                              |
| ---------------- | -------- | -------------------------- | -------------------------------------------------- |
| `id`             | UUID     | PK                         |                                                    |
| `user_id`        | UUID     | FK → users, not null       |                                                    |
| `name`           | string   | not null, max 48           |                                                    |
| `color`          | string   | not null                   | Enum: `clay rose fern gold dusk teal slate mauve`  |
| `description`    | string   |                            | Max 200 chars                                      |
| `target_quarter` | string   |                            | Display label only, e.g. "Q2 2026"                 |
| `status`         | string   | not null, default "active" | Enum: `active archived`                            |
| `sort_order`     | integer  | not null, default 0        | User-defined ordering                              |
| `archived_at`    | datetime |                            | Null when active                                   |
| `created_at`     | datetime | not null                   |                                                    |
| `updated_at`     | datetime | not null                   |                                                    |

**Indexes:** `(user_id, status)`, `(user_id, sort_order)`

---

### 2.4 Milestones (new table)

| Column         | Type     | Constraints                | Notes                               |
| -------------- | -------- | -------------------------- | ----------------------------------- |
| `id`           | UUID     | PK                         |                                     |
| `project_id`   | UUID     | FK → projects, not null    |                                     |
| `name`         | string   | not null, max 72           |                                     |
| `description`  | string   |                            | Max 200 chars                       |
| `start_date`   | date     |                            | Display only, no enforcement        |
| `target_date`  | date     |                            | Soft target, freely editable        |
| `status`       | string   | not null, default "active" | Enum: `active complete skipped`     |
| `sort_order`   | integer  | not null, default 0        | Display order within project        |
| `completed_at` | datetime |                            | Set when user marks complete        |
| `created_at`   | datetime | not null                   |                                     |
| `updated_at`   | datetime | not null                   |                                     |

**Indexes:** `(project_id, sort_order)`, `(project_id, status)`

---

### 2.5 DailyGoals (new table)

| Column             | Type     | Constraints                 | Notes                                                         |
| ------------------ | -------- | --------------------------- | ------------------------------------------------------------- |
| `id`               | UUID     | PK                          |                                                               |
| `user_id`          | UUID     | FK → users, not null        |                                                               |
| `project_id`       | UUID     | FK → projects, not null     |                                                               |
| `milestone_id`     | UUID     | FK → milestones             | Nullable — direct-to-project goals have no milestone          |
| `carry_forward_of` | UUID     | FK → daily_goals (self)     | Nullable — set on the copy; original gets `carried_forward`   |
| `text`             | string   | not null, max 120           |                                                               |
| `date`             | date     | not null                    | Local calendar day (YYYY-MM-DD) — trusted from client         |
| `slot`             | integer  | not null                    | 1, 2, or 3                                                    |
| `status`           | string   | not null, default "pending" | Enum: `pending complete partial carried_forward expired`       |
| `carried_forward`  | boolean  | not null, default false     | True when this goal has been copied to the next day           |
| `note_text`        | string   |                             | EOD reflection, max 280 chars                                 |
| `completed_at`     | datetime |                             | Timestamp of status change to `complete` or `partial`         |
| `created_at`       | datetime | not null                    |                                                               |
| `updated_at`       | datetime | not null                    |                                                               |

**Indexes:** `(user_id, date)`, `(project_id, date)`, `(milestone_id)`, `(carry_forward_of)`

**Unique constraint:** `(user_id, date, slot)` — one goal per slot per day per user.

**Application-layer constraints:**
- `milestone_id` must belong to the same project as `project_id`.
- A goal with `carry_forward_of` set must have a different `date` than the original.
- A goal with `carried_forward = true` cannot be carried forward again (returns 422).

---

### 2.6 Carry-Forward Rules

1. A goal may only be carried forward once. `carry_forward_of` is set on the new goal; the original gets `carried_forward = true`.
2. The server never automatically expires goals. If prior-day goals remain `pending` at any point, the client detects them and presents a resolution prompt. The user explicitly chooses a status (`expired`, `complete`, `partial`, or `carried_forward`) for each one. The server accepts the update via `POST /v1/goals/:id/checkin`.
3. The text of a carry-forward goal is pre-filled from the original but is editable before morning submission.

---

## 3. API

### 3.1 Auth

#### `POST /v1/oauth` — Google Sign-In  _(public)_

**Request:**
```json
{ "token": "<google_id_token>", "tzOffset": -300 }
```
**Response `201`:**
```json
{
  "token": "<jwt>",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "Jamie",
    "timezone_offset": -300,
    "meta_streak_current": 0,
    "meta_streak_longest": 0,
    "morning_reminder_time": "08:00",
    "eod_reminder_time": "20:00",
    "notifications_enabled": true,
    "onboarding_done": false
  }
}
```

#### `GET /v1/me` — Refresh token + fetch user

Recalculates streak by comparing `streak_last_calc_date` to today. If a gap day is detected, resets `meta_streak_current` to 0.

**Response `200`:**
```json
{
  "token": "<refreshed_jwt>",
  "user": { ...same shape as above... }
}
```

#### `PATCH /v1/me` — Update user settings

**Request (any subset):**
```json
{
  "morning_reminder_time": "07:30",
  "eod_reminder_time": "21:00",
  "notifications_enabled": true,
  "onboarding_done": true,
  "timezone_offset": -300
}
```
**Response `200`:** updated user object (without token).

---

### 3.2 Projects

#### `GET /v1/projects`

**Query params:** `?status=active` (default) or `?status=archived`

**Response `200`:**
```json
[
  {
    "id": "uuid",
    "name": "Build the iOS app",
    "color": "fern",
    "description": "Ship Intention v1",
    "target_quarter": "Q1 2026",
    "status": "active",
    "sort_order": 1,
    "archived_at": null,
    "created_at": "2026-01-01T00:00:00Z",
    "milestone_count": 3,
    "activity": [
      { "date": "2026-03-01", "goals_set": 3, "goals_completed": 2 },
      { "date": "2026-03-02", "goals_set": 2, "goals_completed": 2 }
    ]
  }
]
```

`activity` covers the last 30 calendar days. Only days with at least one goal set are included. `goals_completed` counts goals with status `complete` or `partial`. This allows the client to render both fill density and a completion rate.

#### `POST /v1/projects`

**Request:**
```json
{
  "name": "Build the iOS app",
  "color": "fern",
  "description": "Ship Intention v1",
  "target_quarter": "Q1 2026"
}
```
**Response `201`:** project object (as above, `milestone_count: 0`, `activity: []`).

#### `GET /v1/projects/:id`

Includes milestones ordered by `sort_order` and the last 7 days of goals against this project.

**Response `200`:**
```json
{
  "id": "uuid",
  "name": "Build the iOS app",
  "color": "fern",
  "description": "Ship Intention v1",
  "target_quarter": "Q1 2026",
  "status": "active",
  "sort_order": 1,
  "archived_at": null,
  "created_at": "2026-01-01T00:00:00Z",
  "milestones": [
    {
      "id": "uuid",
      "name": "Core data model",
      "description": "Design and migrate schema",
      "start_date": "2026-03-01",
      "target_date": "2026-03-14",
      "status": "complete",
      "sort_order": 1,
      "completed_at": "2026-03-12T18:00:00Z"
    }
  ],
  "recent_goals": [
    {
      "id": "uuid",
      "text": "Wire up goal creation flow",
      "date": "2026-03-04",
      "slot": 1,
      "status": "complete",
      "milestone_id": "uuid"
    }
  ],
  "activity": [
    { "date": "2026-03-01", "goals_set": 3, "goals_completed": 3 },
    { "date": "2026-03-02", "goals_set": 3, "goals_completed": 1 }
  ]
}
```

#### `PUT /v1/projects/:id`

**Request (any subset of mutable fields):**
```json
{
  "name": "Build the iOS app",
  "color": "teal",
  "description": "Updated description",
  "target_quarter": "Q2 2026"
}
```
**Response `200`:** updated project object.

#### `POST /v1/projects/:id/archive`

Sets `status = "archived"`, `archived_at = now`. Returns 422 if already archived.

**Response `200`:** updated project object.

#### `POST /v1/projects/:id/unarchive`

Sets `status = "active"`, clears `archived_at`.

**Response `200`:** updated project object.

#### `POST /v1/projects/reorder`

**Request:**
```json
{ "order": ["uuid-1", "uuid-3", "uuid-2"] }
```
Sets `sort_order` to each ID's array index. Returns 422 if any ID doesn't belong to the current user.

**Response `200`:** `{ "ok": true }`

---

### 3.3 Milestones

All milestone routes are scoped under their project. The server validates that the project belongs to the authenticated user.

#### `GET /v1/projects/:project_id/milestones`

**Response `200`:** array of milestone objects ordered by `sort_order`.

```json
[
  {
    "id": "uuid",
    "project_id": "uuid",
    "name": "Core data model",
    "description": null,
    "start_date": "2026-03-01",
    "target_date": "2026-03-14",
    "status": "active",
    "sort_order": 1,
    "completed_at": null,
    "created_at": "2026-03-01T08:00:00Z"
  }
]
```

#### `POST /v1/projects/:project_id/milestones`

**Request:**
```json
{
  "name": "Core data model",
  "description": "Design and migrate schema",
  "start_date": "2026-03-01",
  "target_date": "2026-03-14"
}
```
**Response `201`:** milestone object.

#### `PUT /v1/projects/:project_id/milestones/:id`

**Request (any subset):**
```json
{
  "name": "Core data model",
  "target_date": "2026-03-21",
  "status": "complete"
}
```

Setting `status = "complete"` sets `completed_at = now` if not already set. Setting it back to `active` clears `completed_at`.

**Response `200`:** updated milestone object.

#### `DELETE /v1/projects/:project_id/milestones/:id`

Unlinks any `daily_goals` referencing this milestone (`milestone_id` set to null; goals remain attached to the project).

**Response `200`:** `{ "id": "uuid" }`

---

### 3.4 Daily Goals

#### `GET /v1/goals?date=YYYY-MM-DD`

Returns all goals for the requested date. The `date` parameter is required. The server trusts the client-supplied date without validation against `timezone_offset`.

Includes nested project and milestone summaries so the client needs no extra fetches to render the Today view.

**Response `200`:**
```json
[
  {
    "id": "uuid",
    "text": "Wire up goal creation flow",
    "date": "2026-03-04",
    "slot": 1,
    "status": "pending",
    "project": {
      "id": "uuid",
      "name": "Build the iOS app",
      "color": "fern"
    },
    "milestone": {
      "id": "uuid",
      "name": "Core data model"
    },
    "carry_forward_of": null,
    "carried_forward": false,
    "note_text": null,
    "completed_at": null,
    "created_at": "2026-03-04T07:45:00Z"
  }
]
```

`milestone` is `null` when the goal is assigned directly to a project.

#### `POST /v1/goals` — Create a goal (morning entry)

The client makes one call per slot. The server rejects a duplicate `(user_id, date, slot)` with 422.

**Request:**
```json
{
  "text": "Wire up goal creation flow",
  "date": "2026-03-04",
  "slot": 1,
  "project_id": "uuid",
  "milestone_id": "uuid"
}
```

`milestone_id` is optional. If provided, the server validates it belongs to `project_id`.

**Response `201`:** goal object (same shape as the item in `GET /v1/goals`).

#### `PUT /v1/goals/:id` — Update goal text or assignment

For edits during the morning entry window — text changes or reassigning the project/milestone. Enforcing the morning-only edit window is a client responsibility.

**Request (any subset):**
```json
{
  "text": "Wire up goal creation flow (revised)",
  "project_id": "uuid",
  "milestone_id": null
}
```
**Response `200`:** updated goal object.

#### `POST /v1/goals/:id/checkin` — Set final status (EOD or stale resolution)

Used for both the evening check-in flow and for resolving stale pending goals from prior days. The server does not automatically expire goals — this endpoint is the only path to setting `expired` status, and only after explicit user action.

**Request:**
```json
{
  "status": "complete",
  "note_text": "Felt good. Got it done by 3pm."
}
```

`status` must be one of: `complete`, `partial`, `carried_forward`, `expired`.

- `note_text` is optional for all statuses.
- Setting `carried_forward` does **not** create tomorrow's goal automatically — that requires a separate call to `POST /v1/goals/:id/carry_forward`.
- Once a non-`pending` status is set, re-submitting the same status is a no-op. Changing to a different status is accepted until the date is more than 7 days in the past (server returns 422 after that).

**Response `200`:** updated goal object.

#### `POST /v1/goals/:id/carry_forward` — Copy goal to tomorrow

Creates a new goal in the earliest available slot for the next calendar day, pre-filled with the original goal's text, `project_id`, and `milestone_id`. Sets `carry_forward_of` on the new goal and `carried_forward = true` on the original.

Returns 422 if:
- The original goal already has `carried_forward = true`
- All 3 slots for tomorrow are already occupied

**Response `201`:** the new goal object (for tomorrow's date).

---

### 3.5 Streak

Streak is recalculated as a side-effect of `GET /v1/me`. No separate endpoint.

**Qualification rule (PRD §9.3):** A day qualifies if all 3 slots were filled **and** at least 1 goal has status `complete` or `partial`. A day where check-in was never completed does not qualify and breaks the streak.

The server compares `streak_last_calc_date` to today on each `GET /v1/me` call. If a gap day is detected, `meta_streak_current` resets to 0. `meta_streak_longest` is updated whenever `meta_streak_current` exceeds it.

---

## 4. HTTP Status Codes

| Status | Meaning |
| ------ | ------- |
| `200` | OK |
| `201` | Created |
| `401` | Missing or invalid JWT |
| `403` | Authenticated but not authorised (wrong user's resource) |
| `404` | Resource not found |
| `422` | Validation failure (`{ "error": "..." }`) |
| `500` | Server error |

---

## 5. Endpoint Summary

| Method | Path | Auth | Description |
| ------ | ---- | ---- | ----------- |
| POST | `/v1/oauth` | Public | Google Sign-In |
| GET | `/v1/me` | ✓ | Refresh token, fetch user, recalc streak |
| PATCH | `/v1/me` | ✓ | Update settings |
| GET | `/v1/projects` | ✓ | List projects with activity |
| POST | `/v1/projects` | ✓ | Create project |
| GET | `/v1/projects/:id` | ✓ | Project detail with milestones + recent goals |
| PUT | `/v1/projects/:id` | ✓ | Update project |
| POST | `/v1/projects/:id/archive` | ✓ | Archive project |
| POST | `/v1/projects/:id/unarchive` | ✓ | Unarchive project |
| POST | `/v1/projects/reorder` | ✓ | Update sort order |
| GET | `/v1/projects/:project_id/milestones` | ✓ | List milestones |
| POST | `/v1/projects/:project_id/milestones` | ✓ | Create milestone |
| PUT | `/v1/projects/:project_id/milestones/:id` | ✓ | Update milestone |
| DELETE | `/v1/projects/:project_id/milestones/:id` | ✓ | Delete milestone |
| GET | `/v1/goals` | ✓ | Goals for a date (`?date=`) |
| POST | `/v1/goals` | ✓ | Create goal (one per slot) |
| PUT | `/v1/goals/:id` | ✓ | Update text or assignment |
| POST | `/v1/goals/:id/checkin` | ✓ | Set final status + note |
| POST | `/v1/goals/:id/carry_forward` | ✓ | Copy goal to tomorrow |
