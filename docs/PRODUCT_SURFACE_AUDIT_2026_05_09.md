# Product Surface Audit — Off-Table Screens
Date: 2026-05-09
Scope: All non-table learner-facing screens in Act0 shell
Sources: Live product review + code analysis of Act0 shell implementation

---

## Overall Verdict

The product base is already stronger and cleaner than the previous state.
The premium dark language is holding across screens.
The main remaining gap is not "things are broken" — it is **hierarchy and density**.
Some surfaces already feel expensive; the product does not yet feel like one coherent premium app everywhere.

Code-level confirmation: the architecture supports the direction. The risks are structural
patterns already baked in, not individual bugs.

---

## Cross-Screen Systemic Issues

These four issues appear on every screen and are the highest-EV targets.

### 1. Too many equally-weighted containers
The single biggest cross-screen issue.
Almost every screen has multiple good panels with no strict priority between them.
This is not a visual opinion — it is literal in the code.
`Act0HomeShellV1` renders `_DailyGoalCardV1`, `_HomeStreakStripV1`, `_SharkyHomeCardV1`,
handoff panel, and achievements strip in a single `ListView` with no hierarchy weight.

### 2. Explanatory density is too high
The product sometimes explains more than needed.
Premium feeling comes when the primary meaning is clear immediately and secondary detail
surfaces quietly. Several screens duplicate intent across title, subtitle, and card body.

### 3. Insufficient chapter ownership
World / lesson / task hierarchy reads logically but not visually.
The intended mental model (world = chapter, lesson = step, task = beat) is in the data
model — `Act0WorldCardV1`, `Act0LessonCardV1`, `Act0LessonTaskV1` all exist — but the
visual presentation does not reflect the same depth difference between layers.

### 4. Utility chrome too visible
Badges, pills, secondary labels, and micro-panels compete with primary content.
`FractionallySizedBox(widthFactor: 0.78)` on zigzag path cards leaves thin margin at
screen edges, reinforcing a dense rather than breathing feel.

---

## Code-Specific Structural Risks

These are not from subjective review — they are direct findings from the implementation.

### Archived map screen ships in production
`lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` is 6080 lines, 14 widget classes,
marked as archived reference-only in AGENTS.md, but is still compiled into every build.
This is dead code in the production APK, risks accidental future references, and inflates
app size.

### Single 5238-line StatefulWidget owns all shell state
`lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` manages all state in one widget:
`_showWorldMenu`, `_learnDetailWorldId`, `_learnDetailLessonId`, `_selectedOptionId`,
`_blockCompletionSummary`, and ~20 more fields.
Every `setState` rebuilds the full tree. This directly affects how transitions feel —
larger rebuild scope = less calm, less responsive screen changes.

### Sharky disappears on unfilled states
`Act0SharkyGuideCardV1` renders inside `if ((sharkyGuideLine ?? '').trim().isNotEmpty)`.
On states where the guide text is not populated, the product character simply vanishes.
This is the structural cause of Sharky feeling like an "occasional insert" rather than
a consistent companion. It is not a design problem — it is a conditional rendering gap.

### `lockedSummary` strings are hardcoded in state
Strings like `'Clear Action words first, then unlock the no-bet read.'` are written
directly inside `act0_shell_state_v1.dart`.
Any editorial or tone-of-voice pass will require code changes instead of content edits.
This is a low-severity issue now, but becomes a friction point when copy polish waves land.

### Zigzag widthFactor has no breathing room budget
`FractionallySizedBox(widthFactor: 0.78)` on both even and odd path cards.
The "more breathing room" note from the product review has a literal fix target here.

---

## Per-Screen Analysis

### Home

**Strengths**
- Good candidate for a premium home surface.
- Daily goal, streak, Sharky card, and main CTA are logically placed.
- Has a clear primary focus area.

**Problems**
- Hero card, handoff panel, daily goal, Sharky card, and streak strip all render at the
  same visual weight — confirmed in code as a flat `ListView` with no dominant block.
- Feels like "several almost equally important panels" rather than "one strong next action".

**Max-EV improvements**
- One truly dominant hero block.
- Merge Sharky card and handoff panel into one smarter companion block.
- Make streak and daily goal visually lighter — utility layer, not primary layer.
- Reduce number of border-heavy containers per screen.

---

### Learn

**Strengths**
- Vertical zigzag path is a good direction.
- Current lesson-open flow is closer to right after recent fixes.
- Has genuine course-like logic.

**Problems**
- Most complex screen in the product.
- World selector, lesson path, active lesson, Sharky guide, and detail hub all compete
  for attention in the same vertical stack.
- `_WorldMenuOverlayV1` is a `Positioned.fill` with a flat list — no depth or elevation
  animation, no chapter-like presentation.

**Max-EV improvements**
- Make Learn more editorial: world as chapter, lesson as node, detail as calm focus surface.
- Reduce visual noise in step-cards inside lesson hub.
- Make spacing and depth more predictable.
- `widthFactor: 0.78` → increase breathing room budget.

---

### Levels / World Menu Overlay

**Strengths**
- Structure is clear.
- Sticky selected node header is useful.
- World progression is readable.

**Problems**
- Currently a "functional sheet", not a premium navigation experience.
- Too many equally styled pills and cards.
- Weak chapter-progression feeling — active, locked, and cleared worlds do not read
  in under one second.

**Max-EV improvements**
- Strengthen active world as chapter owner visually.
- Reduce weight of secondary world nodes.
- Fewer badge and pill elements per row.
- `Act0WorldStateV1 { completed, current, locked }` already exists in the model —
  visual differentiation should match the enum's intent more strongly.

---

### Play

**Strengths**
- Screen is clear and navigable.
- Recommended card works.
- Quick picks and drill sets are logically separated.

**Problems**
- Safest-looking screen — reads more like a polished admin surface than a desirable
  action space.
- Missing tension and reward feeling.

**Max-EV improvements**
- Make recommended card more desirable, not just informative.
- Reduce copy density.
- Stronger visual distinction between: quick action, repair, drill set.
- Add rhythm through hierarchy, not new colors.

---

### Review

**Strengths**
- Smart underlying structure: board / stats / deep leaks / quick fixes is a strong
  product system.
- Good functional logic.

**Problems**
- Feels most "system-heavy" of all screens.
- Risk of internal taxonomy feeling — many similar-looking sections.
- Premium component is weakened by section proliferation.

**Max-EV improvements**
- Reduce visible categories to a primary + secondary split.
- One strong "what to do now" layer at the top.
- Remaining buckets presented quieter and smaller.
- Strong spots and fixed items presented as lighter, more airy elements.

---

### Profile / You

**Strengths**
- Already much better than a typical placeholder profile.
- Recommended focus is useful.
- Stats and skill areas are clear.

**Problems**
- Too symmetrically blocky — feels "correct" but not "memorable".
- Personality is weaker here than on Home.
- All stat cards carry equal visual weight — no hierarchy.

**Max-EV improvements**
- Give Profile a more distinct mood.
- Make identity area more aspirational.
- Reduce equal weighting of all stat cards.
- Recommended focus could be the primary meaning block of the whole screen.

---

### Placement

**Strengths**
- Flow is functionally solid.
- Questions before app shell is the right product decision.
- Reads as product, not diagnostic wizard.

**Problems**
- Effective but not yet emotionally polished.
- Intro / question / action rhythm is not tight enough for a premium first impression.

**Max-EV improvements**
- Tighter pacing control.
- Cleaner completion and handoff into app shell.

---

## Recommended Wave Order

### Wave 1 — Home Simplification Pass
**Highest immediate EV. Simplest diff.**
Home has the most first impressions per day and the simplest architecture to change.
One dominant hero block, merged Sharky+handoff companion, streak/daily as utility layer.
This produces visible premium lift for minimal code surface.

### Wave 2 — Learn + Levels Premium Chapter Pass
**Most important product screen after the table.**
World/chapter hierarchy cleaner, active lesson calmer, Levels overlay more elegant.
Requires touching world menu overlay, scroll behavior, and task popup — larger surface
than Wave 1, so comes second.

### Wave 3 — Global Hierarchy Pass
Apply the one-dominant / one-supporting / rest-secondary rule consistently across all
remaining screens. Not a redesign — a single constraint applied uniformly.

### Wave 4 — Review De-taxonomization Pass
Remove the "sections for sections' sake" feeling. Review should feel like a coached
recovery board, not a structured backlog.

---

## Note on Wave Order Disagreement with Source Audit

The source audit placed Learn/Levels as Wave 2 and Home Simplification as Wave 3.
The code evidence suggests swapping them: Home changes are contained inside
`Act0HomeShellV1` with no cross-screen state dependencies. Learn + Levels touches
`_WorldMenuOverlayV1`, scroll position management, and `_SelectedLessonPopupV1`
simultaneously. Home first gives faster visible product-quality return per hour of work.
