# World 1 Campaign SSOT (Foundations)

## 1) Status + Goal
- Status: DRAFT (until content is generated + validated)
- Goal: Minimum Lovable Product World 1 shipped to store with best-in-class clarity and polish.

## 2) Non-goals (Hard Freeze)
- No AI, no new telemetry, no economy logic beyond existing XP display, no new screens.
- No new training engine behavior; content only.

## 3) World Map Contract (What a “Level” is)
- A Level = one module (existing module manifest) shown as L1..L7 in Progress Map V2.
- Linear unlock rule: Level N unlocks only when Level N-1 is completed (already implemented).
- Launch rule: 1 Level MUST map to exactly 1 module (no splitting).

## 4) Launch Scope (Levels)
Baseline = reuse existing intro and core modules from `lib/content/release_content_plan.dart`.

- L1 Intro Welcome + how sessions work
  - Modules: intro_welcome
  - Target: 5–8 drills, 2–3 quiz items
  - Objective: orient player to learning flow and expectation of accuracy
  - Pass condition: existing session completion

- L2 Game Types + flow basics
  - Module: intro_game_types
  - Target: 5–8 drills, 2–3 quiz items
  - Objective: establish game variants and their structure
  - Pass condition: existing session completion

- L3 Actions
  - Module: intro_actions
  - Target: 6–8 drills, 2–3 quiz items
  - Objective: reinforce available actions and when they apply
  - Pass condition: existing session completion

- L4 Hand Rankings
  - Modules: intro_hand_rankings
  - Target: 6–8 drills, 2–3 quiz items
  - Objective: recall hand strength order
  - Pass condition: existing session completion

- L5 How to Win
  - Modules: intro_how_to_win
  - Target: 6–8 drills, 2–3 quiz items
  - Objective: pot win conditions and showdown basics
  - Pass condition: existing session completion

- L6 First Success set
  - Module: core_rules_and_setup
  - Target: 6–8 drills, 2–3 quiz items
  - Objective: transition into core rules without new mechanics
  - Pass condition: existing session completion

- L7 Mixed checkpoint (optional)
  - Module: tier_1_checkpoint (reuse)
  - Target: 4–6 drills, 1–2 quiz items
  - Objective: verify recall across L1–L6
  - Pass condition: existing session completion

If any module content does not exist or is schema-invalid, mark “NEW MODULE REQUIRED” for that level and stop.
Rationale: Launch constraint requires 1 level == 1 module to avoid cross-module progression ambiguity and simplify unlock gating.

## 5) Content Volume Targets
- Total drills: 30–50 across World 1
- Total quizzes: 10–20 across World 1
- Per level: 5–10 drills, 2–4 quiz items

## 6) Quality Bar (Best-in-class constraints)
- Deterministic, decision-first prompts; minimal text; neutral feedback only on error.
- No placeholders; no legacy fields; schema-valid JSONL only (see `CONTENT_SCHEMAS.md`).
- Consistent difficulty ramp: no jumps >1 tier between adjacent levels (tier is qualitative: intro → core).

## 7) Execution Order (One module at a time)
- Add/upgrade content level-by-level in order L1 → L7.
- After each module: run `dart run tools/validate_training_content.dart --ci` (Tier 0).
- Stop if any schema/tooling drift is detected.

## 8) Exit Criteria (World 1 ready for store)
- 5–7 levels present on map; unlock chain works end-to-end.
- 30–50 drills total, 10–20 quiz total, all schema-valid.
- Player can reach “first success” completion within first 10 minutes.
- No new runtime changes required beyond content assets.

## 9) Drift Guards
- Do not alter First 5 Minutes baseline wiring/telemetry (Phase 7/8 locks apply).
- New content must reuse existing flows/screens only.

## 10) Appendix: Mapping Table
| Level | Module id | Content path | Drills target | Quiz target | Status |
| --- | --- | --- | --- | --- | --- |
| L1 | intro_welcome | content/intro_welcome/v1 | 5–8 | 2–3 | reuse / validate |
| L2 | intro_game_types | content/intro_game_types/v1 | 5–8 | 2–3 | reuse / validate |
| L3 | intro_actions | content/intro_actions/v1 | 6–8 | 2–3 | reuse / validate |
| L4 | intro_hand_rankings | content/intro_hand_rankings/v1 | 6–8 | 2–3 | reuse / validate |
| L5 | intro_how_to_win | content/intro_how_to_win/v1 | 6–8 | 2–3 | reuse / validate |
| L6 | core_rules_and_setup | content/core_rules_and_setup/v1 | 6–8 | 2–3 | reuse / validate |
| L7 | tier_1_checkpoint | content/tier_1_checkpoint/v1 | 4–6 | 1–2 | reuse / validate |
