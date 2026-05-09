# Dev Main 2.0 Soft Rotation v1
Status: SUPERSEDED
Purpose: historical record of the earlier soft-rotation phase before the working-surface policy moved to an explicit `dev`-first cutover.
Last updated: 2026-04-30

Superseded by:

- `docs/plan/DEV_MAIN_2_ACTIVE_CUTOVER_v1.md`

Use the active cutover document above for current working-surface decisions.

## Authority

Use this document for:

- which learner-facing surface is the primary active build target now
- how `main` should be treated during the `dev -> main 2.0` push
- what kinds of work belong in `dev` versus donor/reference families
- how to avoid splitting product direction across two active UI centers

This document does not replace:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` for readiness scoring
- `docs/plan/MASTER_PLAN_v3.0.md` for active product-working route order
- runtime truth and guard evidence already attached to canonical `main` families

If there is a conflict between:

- product-working-surface choice, use this document
- readiness scoring or bottleneck order, use the readiness SSOT chain

## Working Decision

For the current phase:

- the detached `dev` shell is the primary product-design and learner-experience build surface
- treat `dev` as `main 2.0` for new UI/product-direction decisions
- treat current `main` runner families as donor/reference systems, not as the default place to continue shaping the product feel

Primary active surface family:

- `lib/ui_v2/act0_shell/**`

Primary detached entry surface today:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Primary donor/reference families:

- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
- `lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- `lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart`
- other active runner/runtime families already carrying canonical truth, edge-case handling, and guard-backed behavior

## What This Means In Practice

Default assumption:

- if a task is about product feel, shell quality, pedagogy presentation, explanation clarity, table readability, mascot/persona, summary/review presentation, or first-session trust, start in `dev`

Do not default to `main` for:

- new learner-facing polish
- new visual direction
- new shell composition ideas
- new first-session emotional framing

Use `main` as donor/reference for:

- route ownership truth
- progression and continuation semantics
- runtime state transitions
- poker/action/betting truth already proven there
- telemetry and guards
- wider world-family behavior not yet re-expressed in `dev`

## Allowed Work In Main

Allowed:

- extracting reusable logic or contracts needed by `dev`
- reading existing behavior to reproduce or improve it in `dev`
- minimal donor fixes required so extraction remains possible
- protecting existing guard-backed truth from accidental breakage

Not the default:

- continuing to evolve `main` as the preferred product shell
- adding new product-direction polish to old learner-facing host surfaces unless the change is strictly donor maintenance

## Soft-Rotation Guardrails

1. One active learner-facing product center at a time.
   The active center is `dev`.

2. Do not create a second competing product vision inside `main`.

3. Prefer new `dev`-native implementations over hauling large host/UI chunks from `main`.

4. Reuse truth, contracts, and narrow logic from `main`; do not blindly transplant its whole shell architecture.

5. When a piece is missing in `dev`, decide in this order:
   - can it be designed cleanly in `dev` from known truth?
   - if not, can a narrow donor contract or adapter be extracted from `main`?
   - only then consider borrowing a larger implementation slice

6. Keep `main` searchable and intact as a donor archive until `dev` is independently broad enough to replace it.

## Current Non-Goal

This is not yet a hard repository migration.

Do not do the following by default:

- mass file moves
- broad renames to hide old `main` families
- deleting donor surfaces just because `dev` is now the active product center

The current move is organizational and executional:

- `dev` becomes the build center
- `main` becomes the donor/reference base

## Reassessment Trigger

Reassess this policy when one of the following becomes true:

- `dev` is broad enough to stand on its own runtime/progression footing
- the missing gap list for `dev` is concrete and small
- donor access patterns have stabilized enough to justify a harder repo migration

At that point, decide whether to:

- keep soft rotation longer
- promote a harder cutover plan
- archive or demote more of `main`
