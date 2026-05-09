# Content Design Spec - SSOT (Phase 6.4)

## 1) Purpose
Protect format stability for learning content so UX and engine behavior remain deterministic across releases. This spec governs structure and runtime rules, not pedagogy style.

## 2) Unit of learning
- A unit is a deterministic training item represented by existing artifacts (theory/drills/quiz/recap) and consumed inside an existing session flow.
- Inputs are content payloads from current schemas; outcomes are correct/incorrect resolved by existing runtime logic.

## 3) Interaction types (by category)
- Theory injection: short context before first decisions.
- Practice ladder: seed rep plus deterministic iso reps.
- Summary/result: existing post-session surface with next-step guidance.
- Review loop: existing focus label and due-review prioritization.

## 4) Error handling and reactions (system-level)
- Feedback remains factual and minimal.
- Instruction overlay is allowed before first action on seed rep.
- Reactive hints remain silent-until-error and must stay deterministic.

## 5) Format and DSL boundaries
- Canonical schemas and formats remain authoritative:
  - `CONTENT_SCHEMAS.md`
  - `docs/training_pack_template_schema.md`
  - `docs/_archive/misc/STYLE_GUIDE_CONTENT.md`
  - `docs/content/LIVE_CONTENT_SCAFFOLD.md`
  - `docs/content/LIVE_PACKING.md`
- This spec does not introduce new file types.
- Markdown usage stays inside existing theory/recap surfaces.

## 6) Versioning and evolution rules
- Schemas are append-only.
- New fields must be backward compatible and safely ignored by older builds.
- Same input plus same event sequence must produce same output.

## 7) Non-goals / drift guards
- No new content engines, formats, telemetry schemas, or routes.
- No UI redesign in this spec.
- No adaptive branching beyond existing deterministic flows.

## 8) World1 Training Format v1 (release-path SSOT)
### 8.1 Module anatomy
- `ModuleSummary -> TheorySession -> Practice ladder -> SessionResult -> Review scheduling`.
- Theory is injection only: enough context to start first decisions.

### 8.2 Theory injection rules
- Keep theory short, table-first, and directly tied to the next decision task.
- Do not front-load long explanations before first rep.

### 8.3 Practice ladder rules
- Seed rep may include:
  - `instruction_text`
  - `goal_text`
  - `guided_scope` (`seats` | `cards` | `actions`)
  - `iso_group`
- Iso reps in same `iso_group`:
  - no instruction overlay
  - no guided scope hint
  - same `expected_action_kind` and `street_context` for structural consistency
- Required minimum fields per drill entry for this format:
  - `id`, `kind`, `hero_action`, `villain_action`, `goal`, `explanation`, `iso_group`
  - plus `expected_action_kind`, `street_context` for iso-structure checks

### 8.4 Review rule
- If mistakes exist at session end:
  - map to focus label via existing mapper
  - schedule next review via existing spaced-review seam
  - Today Plan prioritizes review when due

### 8.5 Viral artifacts rule
- Skill card and duel code are optional secondary actions.
- They must not displace the primary continuation action.

### 8.6 Session constraints
- Keep microtask sessions short: target 20-60 seconds.
- Use 3-5 deterministic decisions per microtask ladder.
