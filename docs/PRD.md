# Intention — Goal Tracking App

### Product Requirements Document · v1.0

|              |                       |
| ------------ | --------------------- |
| **Version**  | 1.0 — Initial Release |
| **Platform** | iOS (SwiftUI)         |
| **Status**   | In Development        |

**Purpose:** Intention helps you build a purposeful morning practice by committing to three meaningful goals each day, always anchored to the larger projects that matter most to you. It is not a task manager. It is a daily ritual for focused, incremental progress.

---

## Table of Contents

1. [Product Vision](#1-product-vision)
2. [Scope — v1](#2-scope--v1)
3. [Data Model](#3-data-model)
4. [Information Architecture](#4-information-architecture)
5. [Screens & Interactions](#5-screens--interactions)
6. [Design Language](#6-design-language)
7. [Notifications](#7-notifications)
8. [Microcopy & Voice](#8-microcopy--voice)
9. [Engineering Notes](#9-engineering-notes)
10. [Open Questions](#10-open-questions-for-v1)
11. [Success Metrics](#11-success-metrics)

---

## 1. Product Vision

Intention is a daily goal-setting app built around one deceptively simple constraint: every morning, you set three goals. No more. Each goal must belong to an active project, anchoring the small and immediate to the large and meaningful. At the end of the day, you check in. Over time, a quiet record of effort accumulates.

The central design philosophy is **calm intentionality**. The app should feel closer to a paper journal than a productivity suite — unhurried, focused, and free of noise. Every interaction is designed to reinforce the morning ritual rather than compete with it.

### Design Principles

- **Calm over clever** — no gamification, no badge noise, no anxiety loops. Quiet visual feedback only.
- **Constraint as feature** — three goals, ~three projects. Limits are intentional and communicated with warmth, not error states.
- **Ritual over utility** — the morning entry and evening check-in are ceremonies. The app should feel like sitting down with a notebook, not opening a ticketing system.
- **Depth without complexity** — the hierarchy of daily goal → milestone → project is always present but never intrusive. Simple use is simple. Structure is available when needed.
- **Progress is visible** — patterns of effort, not just completion counts, are the measure of success.

---

## 2. Scope — v1

### In Scope

- ✅ Morning entry flow (3 goal slots)
- ✅ Project creation, editing, archiving
- ✅ Milestone creation with flexible date ranges
- ✅ Goal assignment to project or milestone
- ✅ Carry-forward mechanic (once per goal)
- ✅ Evening check-in flow
- ✅ Meta-streak tracker (days with all 3 goals set)
- ✅ Project detail view with milestone list
- ✅ Archived projects (browsable, read-only)
- ✅ Push notifications (morning + EOD)
- ⬜ Soft nudge when exceeding 3 active projects — partial (nudge bar in Assignment Sheet exists; nudge sheet on new-project creation is a stub)

### Out of Scope (v2+)

- Gantt / timeline milestone view
- Statistics & analytics dashboard
- Collaboration or sharing
- Calendar integrations
- Widget / lock screen presence
- Web / Android version
- Goal templates or recurrence
- Tags or custom categorisation

---

## 3. Data Model

The data hierarchy is intentionally shallow. Three entities, cleanly nested.

```
Project (quarterly)  ->  Milestone (weekly)  ->  Daily Goal
```

A daily goal may attach directly to a Project (skipping a milestone), or through a Milestone. Both attachment modes are first-class.

### 3.1 Project

| Field           | Type   | Notes                                                       |
| --------------- | ------ | ----------------------------------------------------------- |
| `id`            | UUID   | Primary key                                                 |
| `name`          | String | Max 48 chars                                                |
| `color`         | Enum   | One of 8 curated palette options (see Design Language 6.3)  |
| `description`   | String | Optional. Max 200 chars. Context for the quarter-level goal |
| `targetQuarter` | String | e.g. "Q2 2025" — display label only, not a hard deadline    |
| `status`        | Enum   | `active` or `archived`                                      |
| `sortOrder`     | Int    | User-defined ordering of active projects                    |
| `createdAt`     | Date   |                                                             |
| `archivedAt`    | Date?  | Null if active                                              |

### 3.2 Milestone

| Field         | Type   | Notes                                       |
| ------------- | ------ | ------------------------------------------- |
| `id`          | UUID   | Primary key                                 |
| `projectId`   | UUID   | Foreign key -> Project                      |
| `name`        | String | Max 72 chars                                |
| `description` | String | Optional. Max 200 chars                     |
| `startDate`   | Date?  | Optional. Display only — no enforcement     |
| `targetDate`  | Date?  | Optional. Soft target. Can be edited freely |
| `status`      | Enum   | `active`, `complete`, or `skipped`          |
| `sortOrder`   | Int    | Display order within project                |
| `createdAt`   | Date   |                                             |
| `completedAt` | Date?  | Set when user marks milestone complete      |

### 3.3 Daily Goal

| Field            | Type    | Notes                                                             |
| ---------------- | ------- | ----------------------------------------------------------------- |
| `id`             | UUID    | Primary key                                                       |
| `text`           | String  | Max 120 chars                                                     |
| `date`           | Date    | The calendar day this goal belongs to (local time)                |
| `projectId`      | UUID    | Always required — every goal belongs to a project                 |
| `milestoneId`    | UUID?   | Optional. If set, must be a milestone of the same project         |
| `status`         | Enum    | `pending`, `complete`, `partial`, `carried_forward`, or `expired` |
| `carryForwardOf` | UUID?   | ID of the original goal if this is a carry-forward copy           |
| `carriedForward` | Bool    | True if this goal was carried forward to tomorrow                 |
| `noteText`       | String? | Optional EOD reflection note, max 280 chars                       |
| `slot`           | Int     | 1, 2, or 3 — position in the day's three slots                    |
| `createdAt`      | Date    |                                                                   |
| `completedAt`    | Date?   | Timestamp of status change to complete/partial                    |

> **Carry-Forward Rules**
>
> - A goal may only be carried forward once. `carryForwardOf` is set on the new goal; the original goal's `carriedForward` flag is set to true.
> - If the carried-forward goal is not completed, its status becomes `expired`. A new goal must be created manually — no automatic re-carry.
> - Carrying forward pre-fills the text into tomorrow's morning slot. The text is editable before submission.

### 3.4 App State

| Field                  | Type | Notes                                                                    |
| ---------------------- | ---- | ------------------------------------------------------------------------ |
| `metaStreakCurrent`    | Int  | Consecutive days where all 3 goals were set AND at least 1 was completed |
| `metaStreakLongest`    | Int  | Historical best streak                                                   |
| `onboardingDone`       | Bool | Whether onboarding flow has been completed                               |
| `morningReminderTime`  | Time | User-configured, default 08:00 local                                     |
| `eodReminderTime`      | Time | User-configured, default 20:00 local                                     |
| `notificationsEnabled` | Bool | Master toggle                                                            |

---

## 4. Information Architecture

The app has three primary tabs and no nested navigation beyond two levels. Any screen is reachable in at most two taps from anywhere.

| Tab          | Icon (SF Symbols)     | Screens contained                                      |
| ------------ | --------------------- | ------------------------------------------------------ |
| **Today**    | `sun.max`             | Morning Entry, Today View (read), Evening Check-in     |
| **Projects** | `folder`              | Project List, Project Detail, Milestone Detail (sheet) |
| **Settings** | `slider.horizontal.3` | Create/Edit Project, Notification Prefs, About         |

---

## 5. Screens & Interactions

### 5.1 Today Tab

The Today tab is the soul of the app. Its state changes contextually across the day: morning entry before goals are set, read-only view during the day, and evening check-in at EOD.

---

#### 5.1.1 Morning Entry

_Displayed when the app is opened and no goals have been set for today._

- Greeting header: warm, time-aware text (e.g. "Good morning, Tuesday") in large, light-weight type
- Meta-streak ribbon: a single subtle line showing current streak — e.g. "12-day streak · keep going" in small caption text. Not prominent. Never alarming.
- Three goal slots stacked vertically. Each slot is a rounded card with a soft shadow and an empty text field. Slots are numbered 1, 2, 3 with small ordinal indicators.
- Each slot has a project/milestone assignment pill below the text input — tapping opens the Assignment Sheet (see 5.1.3).
- If a carry-forward goal exists, it pre-populates a slot with the goal text and a small amber curved-arrow indicator (carry arrow) in the corner. Text is editable.
- A single **"Set Intentions"** CTA button appears below the three slots, disabled until all three slots have both text and a project assigned.
- Tapping "Set Intentions" triggers a subtle haptic and brief animation (cards gently settle) before transitioning to Today View.

> **Interaction Detail — Slot Entry**
>
> - Tapping a slot's text field opens the keyboard. The slot expands gently (spring animation, ~0.3s). Other slots compress slightly to maintain visual breathing room.
> - Character counter appears when within 20 characters of the 120-char limit. Counter uses amber at 100 chars; does not hard-stop entry but shows a gentle overflow state.
> - Return key advances focus to the next slot's text field, not to the assignment pill. This keeps the writing flow uninterrupted.
> - Assignment pill is always visible below the active slot's text. It reads "Assign to project →" in stone color when unset, and shows the project color dot + name when set.

> **TODO:** Slot expand/compress animation on focus is not yet implemented — all three slots remain the same size regardless of which is active. Return key focus chaining between the three goal text fields is also missing.

---

#### 5.1.2 Today View (Read State)

_Displayed after goals are set, until the EOD check-in window opens (default: 8pm)._

- Same three-slot layout as morning entry, now read-only. Cards are rendered at full opacity.
- Each card shows: goal text (primary), project color dot + name + optional milestone name (secondary, smaller).
- Carry-forward indicator visible on applicable cards.
- Meta-streak ribbon persists at the top.
- A soft "Check in this evening →" label appears in stone color at the bottom, non-interactive, fading in after 6pm.
- No edit capability from this screen. Goals are intentionally locked after morning submission.

---

#### 5.1.3 Project / Milestone Assignment Sheet

_A bottom sheet, triggered from a goal slot's assignment pill._

- Sheet rises to approximately 55% of screen height. Drag handle visible at top.
- Each active project is shown as a row: color dot, project name (bold), quarter label (caption, right-aligned).
- Projects with milestones have a disclosure chevron. Tapping expands inline to show milestones as indented sub-rows.
- Milestones show: name + soft target date label (e.g. "by Mar 28") in fog color.
- Tapping a project row (not expanded) assigns the goal directly to the project — no milestone.
- Tapping a milestone row assigns the goal to that milestone (and implicitly its parent project).
- Selected state: the chosen row shows the sage accent color and a checkmark. Sheet dismisses automatically after selection with a brief haptic.
- If the user has 4+ active projects, a soft amber nudge bar appears at the top of the sheet: _"You have 4 active projects. Fewer tends to work better."_ with a "Manage" link.

> **TODO:** The nudge bar appears but the "Manage" link is not implemented — it does not navigate to the project list.

---

#### 5.1.4 Evening Check-in

_Displayed when the app is opened after 8pm and the check-in hasn't been completed, or when launched from the EOD push notification._

- Header: "How did today go?" in calm, medium-weight type.
- Each of the three goals presented as a card. Below the goal text, three status chips: **Done** (sage), **Partial** (amber), **Not today** (stone).
- Tapping a status chip selects it. "Done" triggers a subtle checkmark animation on the card.
- Below each goal, a collapsed note field: "Add a reflection..." in fog. Tapping expands it to a small textarea (max 280 chars). Optional.
- If status is "Not today" and the goal is not already a carry-forward, a toggle appears: **"Carry forward to tomorrow"**. Default off. The user must deliberately opt in.
- A single **"Complete check-in"** CTA at the bottom, enabled once all three goals have a status selected.
- After submission: a brief, quiet completion moment — a soft full-screen sage tint fades in and out over 0.5s — then the screen transitions to Today View (now showing statuses).

---

### 5.2 Projects Tab

#### 5.2.1 Project List

- Active projects shown as stacked cards. Each card: left color bar (project color), project name, quarter label, a small completion heat-map strip (last 30 days).
- Heat map strip: 30 tiny squares in a row. Days with at least 1 goal set against the project are filled in the project color. Empty days are mist. Density view — no numbers.
- A `+` button in the nav bar creates a new project (routes to Project Edit sheet).
- At the bottom of the list, below a thin divider: "Show archived projects" in stone text with a chevron. Tapping expands the archived section inline. Archived project cards are rendered at 60% opacity.
- Tapping a project card opens Project Detail.

---

#### 5.2.2 Project Detail

- Nav bar: project name as title, "Edit" button (top right).
- Project header card: color accent bar, name, description (if set), quarter label, status badge.
- **Milestones section** — bullet list. Each milestone row: name (bold), date range label (e.g. "Mar 10 – Mar 28"), status chip.
  - Status chips: "In progress" (indigo tint), "Complete" (sage tint), "Skipped" (stone).
  - An "Add milestone" row at the bottom of the list — inline tap that presents the Milestone Creation sheet.
  - Tapping a milestone row opens the Milestone Detail sheet.
- **Activity section** — the same 30-day heat map, expanded to a full-width view showing month labels.
- **Recent goals section** — last 7 days of goals set against this project, grouped by date, showing goal text + status indicator.
- For archived projects: a banner at the top reads "Archived project — read only" and the Edit button is replaced by "Unarchive".

---

#### 5.2.3 Milestone Detail Sheet

_Bottom sheet — approximately half height._

- Milestone name (large), parent project chip (color dot + name).
- Date range: two tappable date chips ("Start" and "Target"). Tapping opens a minimal date picker inline. Dates are soft — no enforcement, no overdue states.
- Status toggle: three options (In Progress / Complete / Skipped). Selecting Complete sets `completedAt`.
- Associated goals: a compact list of daily goals linked to this milestone, most recent first. Tapping a goal is read-only.
- A "Delete milestone" option in a destructive action row at the bottom, requiring confirmation.

---

### 5.3 Settings Tab

- **Active Projects** section — shows active projects as tappable rows leading to Project Edit. Includes a "New Project" row.
- **Notifications** section — Morning reminder toggle + time picker. Evening check-in toggle + time picker. Both default on.
- **About** section — app version, brief mission statement, feedback link.

---

#### 5.3.1 Project Edit / Create Sheet

- Fields: Name (required), Description (optional), Color picker (8 swatches), Target Quarter (text input with format hint).
- Color picker is a row of 8 circular swatches. Selected swatch has a checkmark.
- For existing projects: an "Archive project" option at the bottom in amber, with a confirmation sheet explaining that archived projects are read-only but browsable.
- No hard delete in v1. Archive is the only removal action.
- Save button in nav bar (top right), disabled until name is entered.

> **Soft Limit Nudge — 4+ Active Projects**
>
> When the user taps "New Project" and already has 3 or more active projects, a friendly bottom sheet appears before the creation form:
>
> _"You have 3 active projects right now. Keeping focus on a smaller number tends to make daily goal-setting more meaningful. Want to archive one first, or continue adding a new project?"_
>
> Two options: **"Review active projects"** (opens project list) and **"Continue anyway"** (opens project creation form). No blocking. This is a gentle reminder, not a gate.

> **TODO:** The soft limit confirmation sheet is not yet implemented. The condition (3+ active projects) is detected in `SettingsView` but the sheet does not appear — currently a stub comment.

---

## 6. Design Language

Intention should feel like a calm, well-worn object. The visual language draws from Scandinavian minimalism and analogue journaling: restrained color, generous whitespace, unhurried type, and purposeful use of warmth and contrast.

### 6.1 Typography

Use **SF Pro** (system font) throughout the iOS app for native rendering quality.

| Role        | Size | Weight   | Usage                                         |
| ----------- | ---- | -------- | --------------------------------------------- |
| Large Title | 34pt | Bold     | Screen headers, greetings                     |
| Title 1     | 28pt | Semibold | Section headers, project names in detail view |
| Title 2     | 22pt | Semibold | Card headers, milestone names                 |
| Headline    | 17pt | Semibold | Goal text in Today View                       |
| Body        | 17pt | Regular  | Primary copy, descriptions                    |
| Callout     | 16pt | Regular  | Assignment pills, status chips                |
| Subhead     | 15pt | Regular  | Project name secondary, milestone date labels |
| Footnote    | 13pt | Regular  | Caption, meta-streak ribbon, heat map labels  |
| Caption 1   | 12pt | Regular  | Timestamps, character counters                |

**Typography Rules:**

- Line height: 1.4x for body copy, 1.2x for headings. Let the text breathe.
- Never use light weights (< Regular) for body text — they undermine calmness on small screens.
- The greeting on Morning Entry should use Large Title + a lighter greeting phrase in Subhead below it. Warmth through contrast of weight.
- Avoid all-caps. Use sentence case everywhere except the app name.

---

### 6.2 Color System

The palette is small and intentional. Color carries meaning — it is not decorative.

| Role       | Hex       | Usage & Meaning                                                       |
| ---------- | --------- | --------------------------------------------------------------------- |
| Ink        | `#1C1C1E` | Primary text. Near-black to avoid harshness of pure #000              |
| Slate      | `#3A3A3C` | Secondary text, subheadings                                           |
| Stone      | `#6C6C70` | Tertiary text, captions, labels                                       |
| Fog        | `#AEAEB2` | Placeholder text, disabled states                                     |
| Mist       | `#E5E5EA` | Dividers, card borders                                                |
| Canvas     | `#F2F2F7` | App background, section fills                                         |
| White      | `#FFFFFF` | Card surfaces                                                         |
| **Sage**   | `#4CAF7D` | Primary accent. Completion, success, active states. Used sparingly.   |
| **Amber**  | `#D4845A` | Carry-forward indicator, soft warnings, nudges. Warm, not alarming.   |
| **Indigo** | `#5E6AD2` | Metadata, links, in-progress milestone chips. Calm and informational. |

**Color Rules:**

- Sage appears in the UI in exactly three places: the "Done" status chip, the completion moment animation, and the CTA button. Nowhere else. Its scarcity gives it meaning.
- Amber is never used for errors — only for carry-forwards and soft nudges. This keeps the emotional register warm rather than alarming.
- **No red in the core UI.** Deadline pressure and urgency are antithetical to the app's philosophy. Red may only appear in standard iOS destructive actions (e.g. swipe-to-delete confirmations).
- Dark mode: invert the canvas/white/mist hierarchy using iOS adaptive colors. Sage, Amber, and Indigo should be slightly desaturated in dark mode to avoid harshness.

---

### 6.3 Project Color Palette

When creating a project, users choose from 8 curated colors. These are distinct enough to differentiate projects at a glance but harmonious enough to coexist on screen. All are muted, mid-tone — no neons.

| Name  | Hex       | Name  | Hex       |
| ----- | --------- | ----- | --------- |
| Clay  | `#B5694B` | Rose  | `#A85B6E` |
| Fern  | `#4A8C5C` | Gold  | `#B89340` |
| Dusk  | `#5B6FA8` | Teal  | `#3D8A8A` |
| Slate | `#5F6B74` | Mauve | `#7A5B8A` |

---

### 6.4 Motion & Animation

Animation in Intention serves one purpose: to make transitions feel settled, not snappy. Nothing should feel rushed.

| Interaction                | Duration | Curve / Notes                                                    |
| -------------------------- | -------- | ---------------------------------------------------------------- |
| Slot expand on tap         | 280ms    | Spring, damping 0.8. Feels like pressing into soft material.     |
| Assignment sheet rise      | 320ms    | Ease out. Sheet floats up, doesn't slam.                         |
| Set Intentions tap         | 300ms    | Cards gently compress and release. Brief soft haptic (`.light`). |
| Completion flash (EOD)     | 500ms    | Sage tint full-screen opacity 0 -> 0.12 -> 0. Silent but felt.   |
| Tab switch                 | 200ms    | Standard cross-dissolve. Do not use slide — it implies urgency.  |
| Sheet dismiss              | 250ms    | Ease in. Mirror of the rise.                                     |
| Carry-forward badge appear | 180ms    | Scale from 0.6 + fade in. Draws the eye softly.                  |

> **Reduce Motion:** Always respect the iOS Reduce Motion accessibility setting. All spring/scale animations should fall back to simple cross-dissolves at 150ms or less. The app must feel calm even without animation.

---

### 6.5 Layout & Spacing

The spacing system uses a base unit of 8pt. All margins, paddings, and gaps are multiples of 4pt (minimum) or 8pt (preferred).

- Screen horizontal margins: **20pt** (matches iOS HIG standard)
- Card internal padding: **16pt** horizontal, **14pt** vertical
- Card corner radius: **14pt** (warm, not pill-shaped, not boxy)
- Card shadow: y:2pt, blur:8pt, opacity:6% black. Barely-there depth.
- Section spacing (between cards or sections): **24pt**
- Stack spacing within a section: **12pt**
- Bottom sheet handle: 4pt x 36pt, fog color, 8pt top inset

> _Whitespace is content. Resist the urge to fill empty space. The breathing room between cards is what makes the interface feel calm. If a screen feels sparse, that is intentional._

---

## 7. Notifications

Notifications are gentle invitations, not demands. Their copy matches the app's calm, personal voice.

| Type             | Default Time | Title                 | Body                                            |
| ---------------- | ------------ | --------------------- | ----------------------------------------------- |
| Morning reminder | 8:00 AM      | "Set your intentions" | "What are you moving forward today?"            |
| EOD check-in     | 8:00 PM      | "How did today go?"   | "Take a moment to reflect on your three goals." |

- Notifications are suppressed if the relevant action has already been taken that day.
- Both notifications are individually toggleable with custom times in Settings.
- Use `UNUserNotificationCenter` with `.timeSensitive` category to ensure delivery even in Focus modes — but do **not** use critical alerts (which require Apple entitlement review and are philosophically inconsistent with the app's ethos).

---

## 8. Microcopy & Voice

The app's voice is a calm, warm, and direct friend — not a life coach. It never exhorts, never guilt-trips, never congratulates excessively. It speaks in the second person, uses short sentences, and trusts the user.

| Context           | Avoid                                       | Use instead                                               |
| ----------------- | ------------------------------------------- | --------------------------------------------------------- |
| Morning greeting  | "Let's crush it today!"                     | "Good morning. What matters today?"                       |
| Completion moment | "Amazing work! You're on fire!"             | "Done. Good work today."                                  |
| Streak milestone  | "You're unstoppable! 30-day streak!"        | "30 days. That's real."                                   |
| Broken streak     | "Oh no! Your streak is broken."             | "Starting fresh. That's fine."                            |
| Carry-forward     | "You didn't finish this yesterday!"         | "Carried from yesterday"                                  |
| Project nudge     | "Warning: Too many projects!"               | "You have 3 active projects. Fewer tends to work better." |
| Empty state       | "Get started by adding your first project!" | "Add a project to begin setting goals."                   |

---

## 9. Engineering Notes

### 9.1 Architecture Recommendations

- **SwiftUI** throughout. Target iOS 17+.
- **API-backed persistence** via the Rails backend. All user data lives server-side; the app has no local database.
- **MVVM pattern.** ViewModels own business logic and API calls; Views own layout. Keep Views dumb.
- Use `@AppStorage` for lightweight UI-only state that does not need to sync (e.g. last-used EOD reminder time before a network call updates it).
- Notification scheduling via `UNUserNotificationCenter`. Re-schedule on every settings change and every app foreground. Notification times are fetched from the API on launch and stored locally only for scheduling purposes.
- **Auth:** Email/password sign-up and sign-in are implemented on both iOS and the Rails backend (this was added beyond the original Google-OAuth-only spec). Google Sign-In is scaffolded on the backend (`POST /v1/oauth`) but commented out on the iOS side pending re-enablement.

> **TODO:** Re-enable Google Sign-In on iOS (`AuthViewModel` and `LoginView` have the implementation commented out). Add password reset and email confirmation flows — currently the signup endpoint creates an account and issues a JWT with no verification step.

---

### 9.2 State Transitions

The Today tab has three distinct states driven by time-of-day and data presence:

1. On app foreground: check if today has 3 goals set.
2. If **not** — show Morning Entry (regardless of time).
3. If **yes** AND current time is before EOD window (default 8pm) — show Today View.
4. If **yes** AND current time is at/after EOD window AND check-in not completed — show EOD Check-in.
5. If check-in is complete — show Today View with statuses rendered.

> **Edge case — stale pending goals:** If the user opens the app and prior-day goals are still `pending` (check-in was never completed), the app fetches those goals and presents a lightweight resolution prompt before showing today's Morning Entry. The user explicitly marks each stale goal as expired, carries it forward, or marks it complete/partial. No automatic state transitions happen without user confirmation. The server accepts the resulting status updates via the check-in endpoint.

---

### 9.3 Meta-Streak Calculation

- A day counts toward the streak if: all 3 goal slots were filled by end of day **and** at least 1 goal was marked `complete` or `partial` at check-in.
- A day where check-in was never completed does not count and breaks the streak.
- The streak is recalculated on each EOD check-in completion and on each app launch (to handle missed days).
- Store `streakLastCalculatedDate` alongside the streak values to detect gap days.

---

### 9.4 Onboarding

1. **Welcome screen:** app name, one-line purpose statement, "Get started" button.
2. **Create your first project:** inline project creation (name + color only — keep it simple).
3. **Notification permission request:** framed as "Intention works best with morning and evening reminders. Enable them?" with time selectors pre-set to defaults. Skip option available.
4. **First morning entry:** land directly on the Morning Entry screen with a single-use tooltip pointing at the project assignment pill.

> **TODO:** Step 1 (welcome screen) is not yet implemented. `OnboardingFlow` begins directly at step 2 (project creation). The auth/sign-in screen (`LoginView`) already shows the app name and purpose tagline, so this may be combined or reconsidered during polish.

---

## 10. Open Questions for v1

| #   | Question                                                       | Notes                                                                                     |
| --- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| 1   | Can users edit goals after morning submission?                 | Currently locked post-submission. Is this too rigid? Consider a 1-hour grace edit window. |
| 2   | EOD check-in time: fixed 8pm or adaptive?                      | Could learn from user behavior. v1 may keep it simple with a fixed user-set time.         |
| 3   | Should the heat-map strip count goals set, or goals completed? | Currently: goals set. Completed may be more honest but also more punishing.               |
| 4   | App name: "Intention" is working title.                        | Conduct trademark search. Alternatives: Groundwork, Tether, Ritual, Grain.                |
| 5   | Should milestone completion be manual or auto-detected?        | Auto (when all linked goals are done) risks being inaccurate. Manual is safer for v1.     |

---

## 11. Success Metrics

v1 success is defined by habit formation, not growth. A user who opens the app every morning for 30 days is the product succeeding.

- D7 retention >= 45%
- Morning entry completion rate >= 70% of days active users have the app installed
- EOD check-in completion rate >= 50% of days goals were set
- Average meta-streak length >= 5 days within first 30 days of use
- Project creation: >= 80% of users create at least 1 project within their first session
- Milestone creation: >= 40% of users create at least 1 milestone within their first week

---

## Appendix — Revision History

| Version | Date      | Summary                                                                                                                         |
| ------- | --------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1.0     | March 2026 | Initial draft. Covers product vision, data model, all v1 screens, design language, motion, microcopy, and engineering guidance. |
| 1.1     | June 2026 | Build status audit. Marked completed items in §2 scope list. Added TODO callouts in §5.1.1 (slot animation + focus chaining), §5.1.3 (Assignment Sheet "Manage" link), §5.3.1 (soft limit nudge sheet), §9.1 (Google Sign-In + email auth note), §9.4 (onboarding welcome screen). Status updated to In Development. |
