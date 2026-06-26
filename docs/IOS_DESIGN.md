# Intention iOS — Design & Implementation Document

**Version:** 1.0
**Platform:** iOS 17+ · SwiftUI
**Status:** Ready for Implementation

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Visual Foundation](#2-visual-foundation)
3. [Motion System](#3-motion-system)
4. [Component Library](#4-component-library)
5. [Navigation Architecture](#5-navigation-architecture)
6. [Screen Specifications](#6-screen-specifications)
7. [State & API Integration](#7-state--api-integration)
8. [Onboarding Flow](#8-onboarding-flow)
9. [Accessibility](#9-accessibility)
10. [Dark Mode](#10-dark-mode)
11. [Notifications](#11-notifications)

---

## 1. Design Philosophy

Intention is not a productivity tool — it is a ritual container. The design must serve that distinction at every level.

### 1.1 The Three Principles

**Calm over clever.**
There are no confetti bursts, no streak flames, no animated badges. Visual feedback is quiet: a gentle color shift, a soft haptic, a brief tint. The app never competes for emotional bandwidth. It takes the smallest footprint consistent with being useful.

**Constraint as warmth.**
Three slots. Eight colors. One check-in per day. These limits are not technical compromises — they are the product. When the app communicates limits, it does so with warmth and without judgment. The user feels gently held, not blocked.

**Ritual over utility.**
Morning entry and evening check-in are ceremonies. They have a beginning, a middle, and an end. The UI reinforces this: a distinct entry flow, a settled read state, a closing moment. Opening the app at 8am should feel like sitting down with a notebook. It should never feel like opening a ticketing system.

### 1.2 What the App Does Not Do

The following are explicit design anti-patterns for Intention:

- No urgency signaling. No red. No countdown timers. No overdue badges.
- No social comparison. No leaderboards, no sharing, no public streaks.
- No noise. No upsell prompts, no "rate us" requests, no push beyond the two scheduled daily notifications.
- No punishment. A broken streak is acknowledged quietly and without drama. Yesterday is not an accusation.
- No complexity on the surface. The three-tier hierarchy (goal → milestone → project) is always available but never imposed.

---

## 2. Visual Foundation

### 2.1 Color System

The palette is small by design. Every color in the system has a specific role. Deviation from these roles should be treated as a bug.

#### 2.1.1 Semantic Colors

| Token | Light Mode | Dark Mode | Role |
|-------|-----------|-----------|------|
| `color.ink` | `#1C1C1E` | `#F2F2F7` | Primary text. Near-black to soften the harshness of pure black. |
| `color.slate` | `#3A3A3C` | `#D1D1D6` | Secondary text, subheadings, nav labels. |
| `color.stone` | `#6C6C70` | `#8E8E93` | Tertiary text, captions, disabled labels. |
| `color.fog` | `#AEAEB2` | `#636366` | Placeholder text, unset states, ghost elements. |
| `color.mist` | `#E5E5EA` | `#38383A` | Dividers, card borders, separator lines. |
| `color.canvas` | `#F2F2F7` | `#000000` | App background. iOS-native grouped background. |
| `color.surface` | `#FFFFFF` | `#1C1C1E` | Card surfaces, sheet backgrounds. |
| `color.sage` | `#4CAF7D` | `#3A9E6C` | **Primary accent only.** Completion states, the CTA button, the "Done" chip. Used in exactly these three contexts. |
| `color.amber` | `#D4845A` | `#C07248` | Carry-forward indicator, soft nudge copy, the "Partial" chip border. Never for errors. |
| `color.indigo` | `#5E6AD2` | `#7B85E0` | Metadata accent. In-progress milestone chips, links, informational callouts. |

> **Implementation note:** Define all tokens as `Color` extensions sourced from an asset catalog with Light/Dark appearances. Never hard-code hex values in views.

```swift
extension Color {
    static let ink    = Color("ink")
    static let slate  = Color("slate")
    static let stone  = Color("stone")
    static let fog    = Color("fog")
    static let mist   = Color("mist")
    static let canvas = Color("canvas")
    static let surface = Color("surface")
    static let sage   = Color("sage")
    static let amber  = Color("amber")
    static let indigo = Color("indigo")
}
```

#### 2.1.2 Project Palette

These eight colors are user-selectable for projects. They are mid-tone and muted — cohesive when multiple projects appear on screen simultaneously.

| Name | Hex | Dark Mode Hex |
|------|-----|---------------|
| Clay | `#B5694B` | `#C07855` |
| Rose | `#A85B6E` | `#B46A7D` |
| Fern | `#4A8C5C` | `#5A9E6E` |
| Gold | `#B89340` | `#C9A44A` |
| Dusk | `#5B6FA8` | `#6E82BF` |
| Teal | `#3D8A8A` | `#4A9E9E` |
| Slate | `#5F6B74` | `#7A8891` |
| Mauve | `#7A5B8A` | `#906EA0` |

```swift
enum ProjectColor: String, CaseIterable {
    case clay, rose, fern, gold, dusk, teal, slate, mauve

    var color: Color { Color("project.\(rawValue)") }
    var displayName: String { rawValue.capitalized }
}
```

#### 2.1.3 Status Color Mapping

| Status | Color Treatment |
|--------|----------------|
| `pending` | No color treatment — neutral card |
| `complete` | Sage dot indicator + sage chip background |
| `partial` | Amber dot indicator + amber chip border (not fill) |
| `carried_forward` | Amber curved-arrow badge |
| `expired` | Stone text, fog background chip |

---

### 2.2 Typography Scale

SF Pro throughout. No custom fonts. The system font has been crafted for legibility and responds correctly to Dynamic Type — leveraging it is the right choice both technically and aesthetically.

| Style Token | SwiftUI Style | Size | Weight | Line Height | Usage |
|-------------|--------------|------|--------|-------------|-------|
| `type.largeTitle` | `.largeTitle` | 34pt | Bold | 41pt | Screen greetings, top-level headers |
| `type.title1` | `.title` | 28pt | Semibold | 34pt | Project names in detail view |
| `type.title2` | `.title2` | 22pt | Semibold | 28pt | Card headers, section titles |
| `type.title3` | `.title3` | 20pt | Regular | 25pt | Sheet titles |
| `type.headline` | `.headline` | 17pt | Semibold | 22pt | Goal text in read state, milestone names |
| `type.body` | `.body` | 17pt | Regular | 22pt | Descriptions, note text |
| `type.callout` | `.callout` | 16pt | Regular | 21pt | Assignment pills, status chips, button labels |
| `type.subhead` | `.subheadline` | 15pt | Regular | 20pt | Project name (secondary), date labels |
| `type.footnote` | `.footnote` | 13pt | Regular | 18pt | Meta-streak ribbon, heat map labels, character counters |
| `type.caption` | `.caption` | 12pt | Regular | 16pt | Timestamps, auxiliary metadata |

**Rules:**

- Never use weight lighter than Regular for body text. Light weights feel delicate but read as anxious on small screens.
- Use sentence case everywhere. All-caps signals urgency. The app has none.
- The greeting header on Morning Entry pairs `.largeTitle` (date, e.g. "Tuesday") with `.subheadline` below it ("Good morning." or "What matters today?"). This contrast of weight and size creates warmth without fussiness.
- Respect Dynamic Type: all type styles must use the system TextStyle, not fixed sizes. Test at Accessibility Extra Large.

---

### 2.3 Spacing & Layout Grid

Base unit: **8pt**. All spacing values are multiples of 4pt.

| Token | Value | Usage |
|-------|-------|-------|
| `space.xs` | 4pt | Tight internal spacing (icon-to-label) |
| `space.sm` | 8pt | Within-component padding |
| `space.md` | 12pt | Stack spacing within sections |
| `space.lg` | 16pt | Card internal padding (horizontal) |
| `space.xl` | 20pt | Screen horizontal margins |
| `space.2xl` | 24pt | Section spacing between cards/groups |
| `space.3xl` | 32pt | Major section breaks |
| `space.4xl` | 48pt | Breathing room before CTAs |

**Card anatomy:**
- Horizontal padding: 16pt
- Vertical padding: 14pt (top), 14pt (bottom)
- Corner radius: 14pt — warm and approachable without being pill-shaped
- Shadow: `y: 2, blur: 8, opacity: 0.06` — barely visible. Depth is implied, not stated.
- Inter-card gap: 12pt

**Screen margins:**
- Leading/trailing: 20pt
- Safe area bottom for floating CTAs: 24pt above home indicator

---

### 2.4 Iconography

Use SF Symbols 5 throughout. Match symbol weight to adjacent text weight.

| Context | Symbol | Weight |
|---------|--------|--------|
| Today tab | `sun.max` | Regular |
| Projects tab | `folder` | Regular |
| Settings tab | `slider.horizontal.3` | Regular |
| Carry-forward badge | `arrow.uturn.right` | Regular |
| Completion checkmark | `checkmark` | Semibold |
| Assignment disclosure | `chevron.right` | Regular |
| Add action | `plus` | Regular |
| Archive | `archivebox` | Regular |
| Streak | `flame` (used subtly, no animation) | Regular |
| Milestone complete | `checkmark.circle.fill` | — |
| Milestone in progress | `circle` | — |
| Milestone skipped | `minus.circle` | — |

Do not use filled symbol variants for navigation icons — they imply state. Reserve fills for status indicators and confirmations.

---

## 3. Motion System

Animation in Intention exists to make transitions feel **settled**, not snappy. The governing metaphor is physical material that has weight: things don't pop in or out, they ease into place.

### 3.1 Animation Tokens

```swift
extension Animation {
    /// Slot card expansion on focus tap
    static let slotExpand = Animation.spring(response: 0.28, dampingFraction: 0.8)

    /// Sheet presentation and dismissal
    static let sheetRise  = Animation.easeOut(duration: 0.32)
    static let sheetFall  = Animation.easeIn(duration: 0.25)

    /// CTA tap feedback — cards compress and release
    static let intentionSet = Animation.spring(response: 0.30, dampingFraction: 0.75)

    /// Completion flash at EOD
    static let completionFlash = Animation.easeInOut(duration: 0.50)

    /// Carry-forward badge appear
    static let badgeAppear = Animation.easeOut(duration: 0.18)

    /// Tab switch
    static let tabSwitch = Animation.easeInOut(duration: 0.20)

    /// Generic state transitions
    static let standard = Animation.easeInOut(duration: 0.22)
}
```

### 3.2 Interaction → Animation Map

| Interaction | Duration | Curve | Effect |
|-------------|----------|-------|--------|
| Goal slot tap (focus) | 280ms | Spring (0.8 damping) | Active slot height +8pt, other slots -4pt. Feels like pressing into soft material. |
| Assignment sheet open | 320ms | Ease out | Sheet floats up. Never slams. |
| Assignment sheet close | 250ms | Ease in | Mirror of open. |
| "Set Intentions" tap | 300ms | Spring (0.75 damping) | Cards compress 4pt vertically and release. Paired with `.light` haptic. |
| Status chip select | 200ms | Standard | Chip background fills. Checkmark scales in from 0.7. |
| Completion flash | 500ms | Ease in/out | Sage overlay at 12% opacity fades in over 250ms, holds 0ms, fades out over 250ms. |
| Carry-forward badge | 180ms | Ease out | Scale from 0.6 + opacity 0→1. |
| Tab switch | 200ms | Standard | Cross-dissolve. Never slide — sliding implies urgency and direction. |
| Project card heat map | 300ms | Ease out | Squares fill left-to-right on appear, staggered 8ms per square. |

### 3.3 Haptics

Use sparingly. Every haptic should be noticed but not startling.

| Event | Feedback |
|-------|----------|
| "Set Intentions" confirm | `UIImpactFeedbackGenerator(.light)` |
| Status chip selection (Done/Partial/Not today) | `UIImpactFeedbackGenerator(.soft)` |
| Assignment selection (sheet dismiss) | `UIImpactFeedbackGenerator(.soft)` |
| "Complete check-in" confirm | `UIImpactFeedbackGenerator(.medium)` |
| Destructive confirmation (archive/delete) | `UINotificationFeedbackGenerator(.warning)` |

### 3.4 Reduce Motion

All animations must respect `@Environment(\.accessibilityReduceMotion)`. When active:
- Spring and scale animations become `.opacity` transitions at 150ms
- The completion flash becomes a 200ms opacity change without the sage overlay (a brief `.ink` tint at 4% instead)
- Sheet rise/fall becomes `.opacity` at 200ms

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .easeInOut(duration: 0.15) : .slotExpand
}
```

---

## 4. Component Library

### 4.1 Goal Card

The fundamental unit of the Today tab. Three states: **empty** (morning entry), **filled read-only** (today view), **check-in** (EOD).

```
╭──────────────────────────────────────╮  ← 14pt corner radius
│  ①                                   │  ← slot number, 12pt caption, stone
│                                      │
│  [Goal text field / goal text]       │  ← 17pt body (entry) / 17pt headline (read)
│                                      │
│  ● Project Name  ›  Milestone Name   │  ← assignment pill (see 4.2)
╰──────────────────────────────────────╯
```

**Empty state (Morning Entry):**
- Background: `color.surface` (white / near-black dark)
- Border: 1pt `color.mist`
- Placeholder text: "What will you move forward?" in `color.fog`
- Text field uses `.body` style, `color.ink` when typed
- Slot number (①②③) at top-left in `color.stone`, `.caption` size
- Character counter appears when within 20 chars of limit: stone until 100 chars, amber from 100–120

**Filled state (Today View):**
- Same card but text field replaced by Text view
- Goal text in `.headline` weight — slightly heavier to read as settled/committed
- No border — shadow provides depth
- If `carried_forward` is true: amber curved-arrow badge (`arrow.uturn.right`, 10pt) at top-right, with "Carried forward" tooltip on long press

**Check-in state (EOD):**
- Same card layout as filled state
- Below goal text: three status chips in a horizontal stack (see 4.4)
- Below chips: disclosure row "Add a reflection..." in `color.fog`, `.footnote`
- If "Not today" is selected AND not already a carry-forward: toggle row "Carry forward to tomorrow" appears below note row with a 180ms height animation

---

### 4.2 Assignment Pill

Lives below the goal text field. Single tappable row.

**Unset state:**
```
[ Assign to project  → ]
```
- Background: `color.canvas`
- Text: "Assign to project" in `color.stone`, `.callout`
- Trailing chevron in `color.fog`
- 8pt corner radius (smaller than card — it's a secondary element)

**Set state (project only):**
```
[ ● Clay  ]
```
- Filled project color dot (8pt diameter)
- Project name in `color.ink`, `.callout`

**Set state (project + milestone):**
```
[ ● Fern  ›  Core data model ]
```
- Dot, project name, stone separator `›`, milestone name in `color.stone`

Tapping always opens the Assignment Sheet (§6.2.3). The pill is never used for inline editing.

---

### 4.3 Project Card (List View)

```
╭──────────────────────────────────────────╮
│▌  Build the iOS app          Q1 2026     │  ← 4pt left accent bar in project color
│▌  ▬▬▬▬▬▬▬▬▬▬▬▬ heat map ▬▬▬▬▬▬▬▬▬▬▬▬  │  ← 30-day strip
╰──────────────────────────────────────────╯
```

- Left color bar: 4pt wide, full card height, project color, 14pt left corner radii only
- Project name: `.title3`, `color.ink`
- Quarter label: right-aligned, `.footnote`, `color.stone`
- Heat map strip: 30 squares in a single row below the name. Each square is 6×6pt with 2pt gap. Active days filled in project color, inactive days in `color.mist`.
- Card tap → Project Detail (push navigation)

**Archived state:**
- Same card, rendered at 60% opacity
- Left color bar uses a diagonal stripe pattern (SwiftUI `.strikethrough`-style fill, or a custom Shape) in the project color at 40% opacity

---

### 4.4 Status Chip

Used in EOD check-in and in Today View for completed goals.

**Selection chips (EOD, horizontal row):**

| Label | Selected State | Unselected State |
|-------|---------------|-----------------|
| Done | Sage fill, white text, checkmark leading icon | `color.mist` fill, `color.stone` text |
| Partial | Amber border (1.5pt), amber text, `minus` icon | `color.mist` fill, `color.stone` text |
| Not today | `color.mist` fill, `color.stone` text, `xmark` icon | Same (only darker on select) |

Chips: 32pt height, `.callout` label, 8pt corner radius, equal flexible width.

**Status badge chips (Today View, Project Detail):**

Small, read-only badges. 6pt corner radius. 20pt height.

| Status | Color | Label |
|--------|-------|-------|
| `pending` | Canvas bg, stone text | "Pending" |
| `complete` | Sage bg (15% opacity), sage text | "Done" |
| `partial` | Amber bg (12% opacity), amber text | "Partial" |
| `carried_forward` | Amber bg (12% opacity), amber text | "Carried" |
| `expired` | Fog bg, stone text | "Expired" |

---

### 4.5 Heat Map

Used in Project Card (compact) and Project Detail (expanded).

**Compact strip (Project Card):**
- 30 squares × (6pt size + 2pt gap) = ~238pt wide (fits within card)
- Most recent day at the right
- No labels in compact form

**Expanded view (Project Detail):**
- Same squares but 8×8pt with 2pt gap
- Week rows (Mon–Sun) with day labels in `.caption`, `color.stone` at left
- Month boundary labels below relevant columns
- On tap of a square: tooltip showing date, goals_set, goals_completed

Both views use the project color for active days. The opacity of each square encodes the completion rate:
- 0 goals set: `color.mist`
- 1–2 goals set, 0 complete: project color at 25% opacity
- 1–2 goals set, ≥1 complete: project color at 60% opacity
- 3 goals set, ≥1 complete: project color at 100%

This encoding shows both commitment (did you set goals?) and progress (did you finish?) without requiring numbers.

---

### 4.6 Meta-Streak Ribbon

A single line of text. Never more.

```
12-day streak  ·  best: 18
```

- `.footnote`, `color.stone`
- Centered or leading-aligned just below the greeting header
- If streak is 0: render as "Starting fresh." — no number display
- If streak equals longest: "14 days — your best." (and only for that day, after that it reads normally)
- No icon, no flame emoji, no animation. The number is the thing.

---

### 4.7 CTA Button (Primary)

```
╭─────────────────────────────────────────╮
│           Set Intentions                │  ← `.callout` semibold, white
╰─────────────────────────────────────────╯
```

- Background: `color.sage`
- Height: 52pt
- Corner radius: 14pt (matches card radius)
- Horizontal padding: fills available width minus 20pt each side (full-bleed feel)
- Disabled state: `color.fog` background, `color.surface` text — clearly unavailable but not alarming
- On press: scale to 0.97 over 100ms (spring), paired with `.light` haptic on release

Only one primary CTA visible at a time. There is never a reason to stack two sage buttons.

---

### 4.8 Milestone Row

Used within Project Detail.

```
  ○  Core data model                active
     Mar 1 – Mar 14
```

- Status icon at left (14pt SF Symbol): `circle` (active), `checkmark.circle.fill` in sage (complete), `minus.circle` in stone (skipped)
- Name: `.subheadline`, `color.ink`
- Status chip: right-aligned (see §4.4)
- Date range: `.footnote`, `color.stone`, below name
- Tap → Milestone Detail sheet

---

## 5. Navigation Architecture

### 5.1 Tab Bar

Three tabs. No more. The tab bar uses the standard `TabView` with `.tabViewStyle(.automatic)`.

| Tab | Label | Symbol | Symbol (selected) |
|-----|-------|--------|------------------|
| Today | "Today" | `sun.max` | `sun.max.fill` |
| Projects | "Projects" | `folder` | `folder.fill` |
| Settings | "Settings" | `slider.horizontal.3` | `slider.horizontal.3` (no fill variant) |

Tab bar background: always visible (not hidden). Uses system material (`.regularMaterial`) to blur content scrolling beneath.

Tab switching uses cross-dissolve, not slide. Implement via a custom `TabView` wrapper if needed to override the default behavior:

```swift
.transaction { tx in
    tx.animation = reduceMotion ? .none : .tabSwitch
}
```

### 5.2 Navigation Hierarchy

```
App
├── Today Tab
│   ├── Morning Entry  (root, conditional)
│   ├── Today View     (root, conditional)
│   └── Evening Check-in (root, conditional)
│
├── Projects Tab
│   ├── Project List   (root)
│   └── Project Detail (push)
│       └── Milestone Detail Sheet (bottom sheet)
│
└── Settings Tab
    ├── Settings Root  (root)
    └── Project Edit Sheet (bottom sheet)
```

**Rules:**
- No more than two levels of push navigation in any flow.
- Sheets are preferred to push navigation for contextual detail that doesn't need its own history (milestone detail, project edit, assignment picker).
- The Today tab has no navigation stack — it is always a single full-screen view that transitions contextually.

### 5.3 Sheet Presentation

All bottom sheets use `.presentationDetents` with `.medium` as default. Sheets that need more space specify `.large`. The assignment sheet uses a custom fraction (`.fraction(0.55)`).

```swift
.sheet(isPresented: $showAssignment) {
    AssignmentSheetView(...)
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
}
```

All sheets are dismissible by drag. Never disable drag dismissal — it is a source of calm. If unsaved data exists on drag dismiss, present a confirmation (`confirmationDialog`), not an alert.

---

## 6. Screen Specifications

### 6.1 Today Tab — Morning Entry

**Trigger condition:** Current local date has fewer than 3 goals set.

**Layout (top to bottom):**

```
[Navigation Bar]  "Tuesday, March 4"  (invisible nav bar background —
                   content floats beneath status bar)

[Top area, 40pt from safe top]
  Large Title: "Tuesday"           ← day name, .largeTitle, ink
  Subhead: "Good morning."         ← or "Good afternoon." / "Good evening."

[Streak ribbon, 8pt below greeting]
  "12-day streak · best: 18"       ← .footnote, stone, centered

[Goal cards, 24pt below ribbon]
  ╭─ Card 1 ────────────────────╮
  │ ①                           │
  │ [text field]                 │
  │ [assignment pill]            │
  ╰──────────────────────────────╯
  12pt gap
  ╭─ Card 2 ────────────────────╮  (same)
  ╰──────────────────────────────╯
  12pt gap
  ╭─ Card 3 ────────────────────╮  (same)
  ╰──────────────────────────────╯

[48pt spacer]

[CTA Button]  "Set Intentions"      ← full-width, 20pt insets, sage / fog (disabled)
[Safe area bottom]
```

**Carry-forward pre-population:**
If carry-forward goals exist from yesterday, they appear pre-populated in the earliest available slot(s). Each such slot shows the amber `arrow.uturn.right` badge at the card's top-right corner. Text is editable — the user may revise before submitting.

**Focus behavior:**
- On card tap, the card expands by +8pt in height (spring, 280ms).
- Other cards compress by -4pt (matching the spring).
- The assignment pill stays visible below the active field at all times — it does not disappear on focus.
- Keyboard opens with `.returnKeyType = .next` on slots 1 and 2, `.done` on slot 3.
- Return key advances focus: slot 1 → slot 2 → slot 3 → no-op (text is done; user taps the assignment pill manually to assign).

**"Set Intentions" enablement:**
- All three slots must have non-empty text AND a project assigned.
- Partial readiness: if 2 of 3 are complete, button remains disabled. No partial state shown.
- Tapping while disabled: no feedback. The button simply doesn't respond.

**On confirm:**
1. Disable button (prevent double-tap).
2. POST each goal to `/v1/goals` sequentially.
3. On first response: begin card compression animation.
4. On all responses: `.light` haptic. Transition to Today View.

---

### 6.2 Today Tab — Today View (Read State)

**Trigger condition:** 3 goals set for today AND current time before EOD window.

**Layout:**

```
[Navigation Bar]  transparent

[Top area]
  Large Title: "Tuesday"
  Subhead: "March 4, 2026"

[Streak ribbon]

[Goal cards — read-only]
  ╭─ Card 1 ────────────────────╮
  │ ①                           │
  │ Wire up the goal flow        │  ← .headline, ink
  │                              │
  │ ● Fern  ›  Core data model   │  ← project pill, read-only
  ╰──────────────────────────────╯
  (× 3)

[After 6pm — fade in over 2s]
  "Check in this evening →"       ← .footnote, stone, centered, non-tappable
```

No edit affordance. Goals are immutable after morning submission. This is intentional and should not feel like a bug — the visual locked state (text as label, not field; no edit button) communicates finality.

---

### 6.3 Today Tab — Evening Check-in

**Trigger condition:** 3 goals set for today AND current time ≥ EOD window AND check-in not yet complete.

**Layout:**

```
[Navigation Bar]  transparent

[Top area]
  Title 2: "How did today go?"    ← .title2, 22pt, semibold, ink

[Goal cards — check-in state]
  ╭─ Card 1 ────────────────────╮
  │ Wire up the goal flow        │
  │                              │
  │ [Done] [Partial] [Not today] │  ← status chips, equal width
  │                              │
  │ "Add a reflection..."        │  ← collapsed, .footnote, fog
  │ [if "Not today": toggle]     │  ← "Carry forward to tomorrow"
  ╰──────────────────────────────╯
  (× 3)

[48pt spacer]

[CTA Button]  "Complete check-in"  ← enabled when all 3 have a status
```

**Status chip interaction:**
- Tapping "Done" → chip fills sage, others clear. `.soft` haptic.
- Tapping "Partial" → amber border on chip, others clear.
- Tapping "Not today" → chip darkens (fog fill → mist fill), carry-forward toggle slides in below with 180ms height animation.

**Carry-forward toggle:**
- `Toggle("Carry forward to tomorrow", isOn: $carryForward)`
- Default: off. User must actively opt in.
- If the goal was already a carry-forward (`carry_forward_of != nil`), this toggle is not shown — a goal can only be carried once.
- Label uses `.subheadline`, `color.ink`. Toggle uses system style.

**Reflection note:**
- Collapsed by default: "Add a reflection..." in `.footnote`, `color.fog`
- Tapping expands to a `TextEditor`, 60pt height minimum, `.body` text, `color.ink`
- Character counter at bottom-right of field, `.caption`, `color.stone`
- Optional for all status values.

**On "Complete check-in":**
1. POST each goal's status to `/v1/checkin` (with optional `note_text`).
2. For goals with carry-forward toggled: POST `/v1/goals/:id/carry_forward`.
3. On success: sage full-screen tint (12% opacity, 500ms ease in/out) then cross-dissolve to Today View with statuses rendered.
4. On partial API failure: show `.alert` listing which goals failed. Do not use a sheet.

---

### 6.4 Today Tab — Stale Goals Resolution

**Trigger condition:** On app foreground, `GET /v1/goals?date={yesterday}` returns goals with `status: pending`.

This is a lightweight interstitial, not a full screen. It appears as a sheet that the user must dismiss before seeing today's Morning Entry.

```
╭────────────────────────────────────────────╮  ← sheet, .large detent
│ You have unresolved goals from yesterday.  │  ← .title3, ink
│                                            │
│  ╭─ Goal 1 ─────────────────────────────╮ │
│  │ Wire up the goal flow                │ │
│  │ [Done] [Partial] [Not today]         │ │
│  ╰──────────────────────────────────────╯ │
│  (for each pending stale goal)             │
│                                            │
│  [Resolve]    ← enabled when all have status
╰────────────────────────────────────────────╯
```

- Sheet is not drag-dismissible (`.interactiveDismissDisabled(true)`) — resolution is required, but the barrier is frictionless and clearly purposeful.
- If "Carry forward to tomorrow" is selected on a stale goal, that goal is queued for the POST after resolution, and its slot on today's Morning Entry will be pre-populated.
- After resolve: sheet dismisses, today's Morning Entry appears.

**Microcopy:**
"You have unresolved goals from yesterday." — not "You missed your check-in!" The difference matters.

---

### 6.5 Projects Tab — Project List

**Navigation bar:**
- Title: "Projects"
- Trailing: `+` button in `color.indigo`

**Layout:**

```
[Large title navigation bar]  "Projects"

[Active projects — no section header, starts immediately]
  ╭─ Project Card ─────────────────────────────────╮
  │▌ Build the iOS app              Q1 2026         │
  │▌ [▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪ heat map]   │
  ╰────────────────────────────────────────────────╯
  (repeating, 12pt gap)

[If 0 active projects]
  Empty state:
  "Add a project to begin setting goals."  ← .body, stone, centered
  [New Project button] ← sage, below

[Divider — thin, mist, 24pt vertical margin]

"Show archived projects  ›"               ← .subheadline, stone, tappable
  [if expanded: archived cards at 60% opacity]
```

**Reorder:** Long-press on a card enters reorder mode. Cards lift (shadow deepens to y:4, blur:12, opacity:12%), and a three-line grip handle (`line.3.horizontal`) appears at trailing edge. Drag to reorder. On drop: `POST /v1/projects/reorder`. Confirm with `.soft` haptic.

---

### 6.6 Projects Tab — Project Detail

**Navigation bar:**
- Title: project name (`.headline` weight)
- Trailing: "Edit" button → Project Edit sheet

**Layout:**

```
[Navigation bar with back button]  "Build the iOS app"  [Edit]

[Project header card]
╭────────────────────────────────────────────────╮
│▌ Build the iOS app                             │  ← .title1, project color bar
│▌ Ship Intention v1 to the App Store.           │  ← .body, stone (description)
│▌                            Q1 2026  [active]  │  ← quarter + status chip
╰────────────────────────────────────────────────╯

[Section: "Milestones" — .title3 header, 24pt top]
  ╭─ milestone rows ────────────────────────────╮
  │ ○  Core data model                [active]  │
  │    Mar 1 – Mar 14                           │
  │─────────────────────────────────────────────│
  │ ✓  API integration               [complete] │
  │    Mar 14 – Mar 21                          │
  │─────────────────────────────────────────────│
  │ +  Add milestone                            │  ← stone text, tap → sheet
  ╰─────────────────────────────────────────────╯

[Section: "Activity" — .title3 header, 24pt top]
  [Expanded heat map — full width, 5 week rows]
  [Month labels below]

[Section: "Recent Goals" — .title3 header, 24pt top]
  [Grouped by date, most recent first]
  ╭─ March 4, 2026 ─────────────────────────────╮
  │ [slot 1]  Wire up goal creation flow  [Done] │
  │ [slot 2]  Review milestone spec      [Done]  │
  │ [slot 3]  Write unit tests           [Partial]│
  ╰─────────────────────────────────────────────╯
  (repeating for 7 days)
```

**Archived project variant:**
- Amber banner at top of scrollable content: "Archived project — read only. Archived [date]."
- "Edit" button replaced by "Unarchive"
- No add milestone row
- All content is read-only

---

### 6.7 Projects Tab — Milestone Detail Sheet

Sheet height: `.medium` (approximately 55% of screen height).

```
╭────────────────────────────────────────────────╮
│  ⎯ [drag handle]                               │
│                                                │
│  Core data model                               │  ← .title2, ink
│  ● Fern  Build the iOS app                     │  ← project chip, .callout
│                                                │
│  [Mar 1] ────────────────────── [Mar 14]       │  ← date chip pair (tappable)
│  Start                          Target         │
│                                                │
│  Status                                        │  ← .subheadline header
│  [In Progress] [Complete] [Skipped]            │  ← segmented-style picker
│                                                │
│  Goals (7)                      ← .subheadline │
│  ───────────────────────────────────────────── │
│  Wire up goal creation flow   Mar 4  [Done]    │
│  Review milestone spec        Mar 4  [Done]    │
│  ...                                           │
│                                                │
│  ─────────────────────────────────────────────│
│  Delete milestone                              │  ← destructive, .subheadline, red
╰────────────────────────────────────────────────╯
```

**Date chips:**
- Render as `[Mar 1]` in a rounded rectangle, `color.canvas` background, `color.indigo` text, `.callout`
- Tap opens a compact inline `DatePicker` with `.graphical` style in a popover
- If no date is set: renders as `[Start date]` in `color.fog`

**Status picker:**
- Three-segment control: "In Progress" / "Complete" / "Skipped"
- Selecting "Complete" sets `completed_at` server-side and shows a subtle checkmark animation in the status control
- Selecting "In Progress" after "Complete" prompts: "Clear completion date?" (`.confirmationDialog`)

**Delete:**
- Tapping "Delete milestone" presents: "Delete this milestone? Goals linked to it will remain, but will no longer be associated with a milestone." — two options: "Delete" (destructive) and "Cancel".
- On confirm: `DELETE /v1/projects/:project_id/milestones/:id`, then dismiss sheet.

---

### 6.8 Projects Tab — Assignment Sheet

**Trigger:** tapping an assignment pill on a goal slot card.

Sheet height: `.fraction(0.55)`.

```
╭────────────────────────────────────────────────╮
│  ⎯                                              │
│                                                 │
│  [Amber nudge bar — if 4+ active projects]      │
│  "You have 4 active projects.                   │
│   Fewer tends to work better.  Manage ›"        │
│                                                 │
│  ● Clay   Build the Backend        Q1 2026  ›   │  ← project row
│  ● Fern   Build the iOS app        Q1 2026  ›   │
│    [if expanded:]                               │
│    ↳ Core data model              by Mar 14    │  ← milestone sub-row
│    ↳ API integration              by Mar 21    │
│    ↳ [Assign to project directly]              │  ← no milestone
│  ● Gold   Learn SwiftUI            Q2 2026  ›   │
╰────────────────────────────────────────────────╯
```

**Nudge bar:**
- Only shown when `projects.count >= 4`
- Amber text on a warm pale amber background (`color.amber` at 8% opacity)
- "Manage ›" routes to Projects tab (sheet dismisses first)
- `.footnote` text, 10pt vertical padding

**Project row:**
- `color.dot` (8pt) + project name (`.subheadline`, `color.ink`) + quarter label (`.footnote`, `color.stone`, right-aligned) + `chevron.right`
- Tap on the row (not the chevron): assigns goal directly to project (no milestone). Sheet dismisses.
- Tap on chevron: expands inline to show milestone sub-rows (180ms height animation).

**Milestone sub-row:**
- 20pt left indent, milestone name (`.footnote`, `color.ink`), target date label ("by Mar 14", `color.stone`)
- Plus a "Assign to project directly" option at bottom of the expanded list in `color.stone`

**Selection state:**
- Currently selected item (project or milestone) shows `checkmark` in `color.sage` at trailing edge
- On selection: `.soft` haptic, sheet dismisses after 150ms delay

---

### 6.9 Settings Tab

**Layout:**

```
[Large title navigation bar]  "Settings"

[Section: Active Projects]
  ╭─────────────────────────────────────────────╮
  │ ● Fern  Build the iOS app              ›    │
  │ ● Clay  Build the Backend              ›    │
  │─────────────────────────────────────────────│
  │ + New Project                               │  ← indigo text
  ╰─────────────────────────────────────────────╯

[Section: Notifications]
  ╭─────────────────────────────────────────────╮
  │ Morning reminder           [toggle]         │
  │ 8:00 AM                    › picker         │
  │─────────────────────────────────────────────│
  │ Evening check-in           [toggle]         │
  │ 8:00 PM                    › picker         │
  ╰─────────────────────────────────────────────╯

[Section: About]
  ╭─────────────────────────────────────────────╮
  │ Version  1.0.0                              │
  │ Send feedback              ›                │
  │─────────────────────────────────────────────│
  │ Intention helps you build a                 │
  │ purposeful morning practice by              │
  │ committing to three meaningful goals        │
  │ each day.                                   │  ← .footnote, stone, padded
  ╰─────────────────────────────────────────────╯
```

**Notification time picker:**
- Inline `.wheel` style `DatePicker` with `.hourAndMinute` display components
- Expands below the time row on tap (iOS-style inline expansion, 250ms)
- On change: update local `@AppStorage`, then `PATCH /v1/me` with new time string
- If toggle is off: time picker row is greyed out and non-interactive

---

### 6.10 Settings Tab — Project Create/Edit Sheet

**Trigger:** "New Project" row or project row in Settings → tapping a project row.

Sheet: `.large` detent (full height minus safe area top).

```
╭────────────────────────────────────────────────╮
│  ⎯                                              │
│  [Cancel]    New Project          [Save]        │  ← nav bar within sheet
│                                                 │
│  [Section: Basics]                              │
│  ╭──────────────────────────────────────────╮  │
│  │ Name                                     │  │
│  │ Build the iOS app                        │  │
│  │──────────────────────────────────────────│  │
│  │ Description (optional)                   │  │
│  │ Ship Intention v1 to the App Store.      │  │
│  │──────────────────────────────────────────│  │
│  │ Target Quarter (optional)                │  │
│  │ Q1 2026                                  │  │
│  ╰──────────────────────────────────────────╯  │
│                                                 │
│  [Section: Color]                               │
│  ╭──────────────────────────────────────────╮  │
│  │  ●  ●  ●  ●  ●  ●  ●  ●                 │  │
│  │ Clay Rose Fern Gold Dusk Teal Slate Mauve│  │  ← 8 swatches, 36pt each
│  ╰──────────────────────────────────────────╯  │
│                                                 │
│  [Edit mode only — Section: Danger Zone]        │
│  ╭──────────────────────────────────────────╮  │
│  │ Archive project                          │  │  ← amber text
│  ╰──────────────────────────────────────────╯  │
╰────────────────────────────────────────────────╯
```

**Color swatches:**
- 8 circles, 36pt diameter, 12pt gap between
- Selected swatch: `checkmark` at center in white, 1.5pt white ring around the outside
- Unselected: flat circle, project color fill
- Default selection for new projects: Clay (index 0)

**Soft limit nudge:**
When "New Project" is tapped and the user already has ≥ 3 active projects, show a `.confirmationDialog` before opening the sheet:

> "You have 3 active projects. Keeping focus on a smaller number tends to make daily goal-setting more meaningful."
>
> **Review active projects** | **Continue anyway** | Cancel

"Review active projects" dismisses to the Projects tab. "Continue anyway" opens the creation sheet.

**Save:**
- "Save" button in nav bar, disabled until Name field is non-empty
- Create: `POST /v1/projects`
- Edit: `PUT /v1/projects/:id`

**Archive:**
- Tapping "Archive project" shows `.confirmationDialog`:
  > "Archive this project? It will no longer appear in your active list. Goals you've set will still be preserved and viewable."
  > **Archive** (destructive) | Cancel
- On confirm: `POST /v1/projects/:id/archive`

---

## 7. State & API Integration

### 7.1 Architecture

MVVM. ViewModels hold API state and business logic. Views are declarative and dumb.

```
App
├── AuthViewModel       — JWT storage, user object, login/logout
├── TodayViewModel      — today's goals, stale goals, state machine
├── ProjectsViewModel   — project list, reorder, archive
└── SettingsViewModel   — notification prefs, PATCH /me
```

Sub-ViewModels created on demand and owned by parent Views (not global):
```
ProjectDetailViewModel(project: Project) — milestones, activity, recent goals
GoalCardViewModel(slot: Int)            — text, assignment, validation state
```

### 7.2 JWT Handling

- Store JWT in Keychain (not UserDefaults) via `KeychainAccess` or `Security` framework.
- On every `GET /v1/me` call, replace the stored token with the freshly returned one.
- On 401: clear keychain token, route user to login (Google Sign-In).
- Token expiry (100 hours) means tokens are long-lived. Refresh on app foreground.

```swift
actor TokenStore {
    static let shared = TokenStore()
    private let key = "intention.jwt"

    func set(_ token: String) throws { /* Keychain write */ }
    func get() throws -> String? { /* Keychain read */ }
    func clear() throws { /* Keychain delete */ }
}
```

### 7.3 Today Tab State Machine

```
enum TodayState {
    case loading
    case morningEntry(prefilledGoals: [CarryForwardGoal])
    case readView(goals: [Goal])
    case eodCheckIn(goals: [Goal])
    case complete(goals: [Goal])
    case staleResolution(staleGoals: [Goal], then: TodayState)
}
```

State is computed on app foreground, after `GET /v1/me` and `GET /v1/goals?date=today`:

```
1. Fetch today's goals
2. If count < 3:
   a. Fetch yesterday's goals (stale check)
   b. If any yesterday goal is `pending` → .staleResolution(..., then: .morningEntry)
   c. Else → .morningEntry(prefilledGoals: carryForwards from yesterday)
3. If count == 3:
   a. All goals have non-pending status AND current time before EOD → .complete
   b. Current time < EOD window time → .readView
   c. Current time >= EOD window time AND any goal is pending → .eodCheckIn
   d. All goals non-pending → .complete
```

### 7.4 API Error Handling

No generic error alerts. Errors should degrade gracefully:

| Failure | Response |
|---------|----------|
| Goal creation fails (slot taken) | Inline error below the card: "This slot is already taken for today." |
| Check-in fails | Toast (SwiftUI overlay) at bottom: "Couldn't save. Try again." — auto-dismisses 3s |
| Network unavailable | Soft banner at top of Today view: "No connection — showing last synced data." |
| 401 | Clear token, push to login screen |
| 500 | Toast: "Something went wrong. We've noted the error." |

Toasts are in `color.slate` background, `color.surface` text, 14pt corner radius, 12pt vertical padding, 20pt horizontal padding. They float above the tab bar and fade out.

---

## 8. Onboarding Flow

Shown only when `user.onboarding_done == false`.

### Screen 1 — Welcome

```
[Full-bleed canvas background]

[Centered, vertically positioned at 40% of screen]
  Large title: "Intention"              ← .largeTitle, ink
  Body: "A daily practice of focused,  ← .body, stone
         purposeful progress."

[Bottom area]
  [Get started]                         ← sage CTA button
  "Sign in with Google"                ← .subheadline, indigo, below button
```

No logo, no illustration. The name and the sentence do the work.

### Screen 2 — Create First Project

```
[Navigation: "Back" | "Your first project" | (no Save yet)]

"Start with something                  ← .title2, ink
 you're working toward."

[Inline project creation]
  Name field (required)
  Color swatches (8 options)

[Continue]  ← sage CTA, enabled when name is non-empty
```

Description and target quarter are hidden here — too much friction. They can be added later.

### Screen 3 — Notifications

```
"Intention works best
 with daily reminders."               ← .title2, ink

"A gentle prompt in the morning,      ← .body, stone
 and again in the evening."

[Morning reminder]
 8:00 AM         [time picker inline]

[Evening check-in]
 8:00 PM         [time picker inline]

[Enable reminders]   ← sage CTA
[Not now]            ← .subheadline, stone, below CTA
```

"Enable reminders" triggers `UNUserNotificationCenter.requestAuthorization`. If granted, schedule both notifications. If denied, store preference locally and do not re-prompt — Settings is always available.

### Screen 4 — First Morning Entry

Land directly on the Morning Entry screen. A single one-time tooltip appears near slot 1's assignment pill:

```
 ╭───────────────────────────────╮
 │  Assign each goal to a        │
 │  project or milestone.        │
 │                         [Got it] │
 ╰───────────────────────────────╯
 △ (pointer toward assignment pill)
```

Tooltip uses `.popover` style if available, otherwise a custom overlay with a triangle indicator. Dismiss on "Got it" or on assignment pill tap. Never show again.

After completing first Morning Entry: `PATCH /v1/me` with `{ "onboarding_done": true }`.

---

## 9. Accessibility

### 9.1 Dynamic Type

All text uses SwiftUI TextStyles, not fixed sizes. Test at:
- Default (xSmall through large): layout must be comfortable.
- Accessibility Extra Large: all content must remain functional without truncation on critical UI.

Goal card text fields must allow multiline wrapping. Do not clip text with `.lineLimit(1)` on any user-generated content.

### 9.2 VoiceOver

| Element | Accessibility Label | Hint |
|---------|-------------------|------|
| Goal slot 1 text field | "Goal 1, text field" | "Enter what you'll work on today" |
| Assignment pill (unset) | "Assign to project" | "Double tap to choose a project" |
| Assignment pill (set) | "Assigned to [project name], [milestone name]" | "Double tap to change" |
| Status chip (Done) | "Done" | "Double tap to mark this goal complete" |
| Project color swatch | "[Color name]" | "Double tap to select" |
| Heat map square | "[Date], [n] goals set, [m] completed" | — |
| Carry-forward badge | "Carried from yesterday" | — |

Group goal card elements with `.accessibilityElement(children: .contain)` to prevent VoiceOver from treating the slot number, text, and assignment pill as three separate navigation stops.

### 9.3 Contrast

All text must meet WCAG 2.1 AA (4.5:1 for body text, 3:1 for large text).

Verify in particular:
- Stone text on canvas background (passes at ~4.7:1)
- Fog text on surface (check at large type only — small fog text may need a tint boost)
- Amber on white (warm amber `#D4845A` on white is approximately 3.2:1 — use only for large type or as a colored border/dot, not for small body copy)

### 9.4 Reduce Transparency

Respect `@Environment(\.accessibilityReduceTransparency)`. If active, replace blurred sheet backgrounds with solid `color.surface`.

---

## 10. Dark Mode

The app uses iOS adaptive colors throughout. Key considerations beyond the color token table:

**Card shadows** become meaningless in dark mode (dark shadow on dark background). Switch to a `color.mist`-colored border (1pt) in dark mode to preserve card definition. Implement via `@Environment(\.colorScheme)`:

```swift
.overlay(
    RoundedRectangle(cornerRadius: 14)
        .stroke(colorScheme == .dark ? Color.mist : .clear, lineWidth: 1)
)
```

**Project color bars** in dark mode: use the slightly lightened dark-mode variant from the project palette. The lightening is subtle (about 10% lighter saturation) so colors remain muted and harmonious against the dark surface.

**Sage accent** in dark mode is slightly desaturated (`#3A9E6C`) to avoid the neon-green appearance that sage can develop against near-black backgrounds.

**Heat map squares**: active squares in dark mode should use the project color at 80% opacity max (not 100%) to prevent them feeling harsh against the dark canvas.

---

## 11. Notifications

### 11.1 Scheduling

Schedule notifications on:
- App launch (foreground)
- Any change to notification time in Settings
- Permission grant during onboarding

Use `UNCalendarNotificationTrigger` with the user's local timezone. Repeat daily.

```swift
func scheduleMorningReminder(at time: DateComponents) async {
    let content = UNMutableNotificationContent()
    content.title = "Set your intentions"
    content.body = "What are you moving forward today?"
    content.interruptionLevel = .timeSensitive

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: time, repeats: true
    )
    let request = UNNotificationRequest(
        identifier: "intention.morning",
        content: content,
        trigger: trigger
    )
    try? await UNUserNotificationCenter.current().add(request)
}
```

### 11.2 Suppression

Before scheduling, check whether the relevant action has already been taken today:
- Morning notification: suppress if `GET /v1/goals?date=today` returns 3 goals.
- EOD notification: suppress if all 3 goals have a non-pending status.

Implement by removing the pending notification after the action completes:

```swift
UNUserNotificationCenter.current()
    .removePendingNotificationRequests(withIdentifiers: ["intention.morning"])
```

Re-add it for tomorrow immediately after removal (the next daily fire will resume).

### 11.3 Notification Copy

| Notification | Title | Body |
|-------------|-------|------|
| Morning | "Set your intentions" | "What are you moving forward today?" |
| Evening | "How did today go?" | "Take a moment to reflect on your three goals." |

No emoji. No urgency words. The voice matches the app: calm, direct, brief.

### 11.4 Tapping a Notification

Deep-link handling:
- Tapping morning notification → opens app, Today tab, Morning Entry (if goals not yet set)
- Tapping evening notification → opens app, Today tab, Evening Check-in (if check-in not done)

Both use `UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:)` and set the `TodayViewModel` state directly, bypassing the normal foreground detection delay.

---

## Appendix A — API → UI Field Mapping

| API Field | Used In |
|-----------|---------|
| `user.meta_streak_current` | Meta-streak ribbon |
| `user.meta_streak_longest` | Meta-streak ribbon ("best: N") |
| `user.onboarding_done` | Onboarding flow gate |
| `user.morning_reminder_time` | Notification scheduling + Settings |
| `user.eod_reminder_time` | Notification scheduling + Settings, EOD window check |
| `project.color` | All project color bars, dots, heat map squares |
| `project.activity` | Heat map strip (30-day) |
| `project.milestone_count` | Project card (milestone pill count) |
| `daily_goal.slot` | Card position (1/2/3) |
| `daily_goal.carry_forward_of` | Carry-forward badge visibility |
| `daily_goal.carried_forward` | Carry-forward toggle eligibility in EOD |
| `daily_goal.project` | Assignment pill (from `goal_json` nested object) |
| `daily_goal.milestone` | Assignment pill secondary label |
| `milestone.completed_at` | Milestone status chip + completed date display |

---

## Appendix B — Microcopy Reference

| Context | Copy |
|---------|------|
| Morning greeting (before noon) | "Good morning." |
| Morning greeting (noon–5pm) | "Good afternoon." |
| Morning greeting (after 5pm) | "Good evening." |
| Streak: 0 days | "Starting fresh." |
| Streak: N days | "N-day streak · best: M" |
| Streak equals longest | "N days — your best." |
| Goal text placeholder | "What will you move forward?" |
| Assignment pill (unset) | "Assign to project →" |
| EOD header | "How did today go?" |
| Completion flash (silent, no copy) | — |
| Stale goals header | "You have unresolved goals from yesterday." |
| Carry-forward toggle label | "Carry forward to tomorrow" |
| Carry-forward badge tooltip | "Carried from yesterday" |
| 3 projects nudge | "You have 3 active projects. Fewer tends to work better." |
| Empty project list | "Add a project to begin setting goals." |
| Archive confirmation body | "Archived projects are read only but remain browsable." |
| Delete milestone body | "Goals linked to it will remain, but will no longer be associated with a milestone." |
| Notification: morning title | "Set your intentions" |
| Notification: morning body | "What are you moving forward today?" |
| Notification: evening title | "How did today go?" |
| Notification: evening body | "Take a moment to reflect on your three goals." |
