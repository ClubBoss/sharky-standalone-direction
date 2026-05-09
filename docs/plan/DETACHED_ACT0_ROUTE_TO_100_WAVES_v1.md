# Detached Act0 Route to 100 Waves v1

Status: active detached-shell execution plan.

Purpose: guide the dev-only Act0 shell toward a best-in-segment learning product
without wiring production routes, BeatV1, commerce SDKs, or legacy runner
surfaces too early.

## 1. Current Read

`PROJECT_READINESS_EPICS_SSOT_v1.md` and `MASTER_PLAN_v3.0.md` put the next
highest-EV route through:

1. `I` Product Identity / Persona / Emotional Layer
2. `J` Onboarding / Trust / First-Session Framing
3. `K` Monetization / Value Packaging
4. Distribution and final release confidence

Detached Act0 already has a stronger learning core than a flat prototype:
world map, lesson loops, table-first runner, mistakes review, Play groups,
profile state, block summary, and placement preview. The remaining gap is that
the product still needs to feel alive, trustworthy, and habit-forming before
placement and trial packaging can carry real weight.

## 2. Execution Order

### Wave 1: Sharky + Sensory + First AHA

- Add compact Sharky as a live-session product layer:
  - one curated pre-session line,
  - one curated outcome reaction,
  - one identity reinforcement on block summary.
- Wire existing `UiSoundV1` and `UiHapticsV1` to detached runner answer and
  block-complete outcomes.
- Keep all copy curated and local. No AI chat, no generated content, no open
  dialogue.

### Wave 2: Mistake Repair as Product Core

- Make Review feel like a repair queue, not a static list.
- Use table context, selected answer, better answer, reason, attempts, and
  resolved state.
- Reflect weak and strong categories in Profile.

### Wave 3: Better Re-entry + Daily Loop

- Home and Play recommend one best next action:
  repair weak spot, continue lesson, or run a quick daily drill.
- Keep practice queues deterministic: current incomplete task, unresolved
  mistakes, then curated category drills.

### Wave 4: Placement v2

- Return to placement after the first-session trust layer is stronger.
- Make placement full-screen, diagnostic-only, and learner-facing:
  profile questions, 6-12 deterministic items, level result, strengths, weak
  spots, and recommended start.
- Add retake placement from `You`.

### Wave 5: Value Packaging / Premium Preview

- Add value-first premium preview only after Waves 1-4 make the product value
  clear.
- Keep detached mode non-blocking: no payment SDK, no hard paywall.
- Align trial/premium copy with `APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`.

## 3. Stop Rules

- Do not wire production routes or BeatV1 from this plan.
- Do not touch `ModernTableScreenV1`.
- Do not add dependencies, RNG, ML, solver claims, or open-ended persona chat.
- Do not expand placement while first-session trust still feels weak.
- Do not close monetization/value packaging before identity and trust are
  reviewable in the live detached shell.

## 4. Gates

Each implementation wave should run:

- `dart format lib/ui_v2/act0_shell test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `git diff --check` with the parent gitdir/work-tree fallback if native git is
  blocked by the stale worktree pointer.
