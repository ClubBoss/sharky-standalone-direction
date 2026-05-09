# Dev Main 2.0 Active Cutover v1
Status: ACTIVE
Purpose: define the current working-surface policy now that learner-facing product work should route through the detached `dev` shell by default and `main` should no longer be treated as an active product surface.
Last updated: 2026-04-30

## Authority

Use this document for:

- which learner-facing surface is the sole active product-build center now
- how `main` should be treated during the current `dev`-first push
- what kinds of work still justify touching `main`
- how to avoid reopening a dual-surface product direction

This document does not replace:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` for readiness scoring
- `docs/plan/MASTER_PLAN_v3.0.md` for active product-working route order
- runtime truth and guard evidence already attached to canonical `main` families

If there is a conflict between:

- product-working-surface choice, use this document
- readiness scoring or bottleneck order, use the readiness SSOT chain

## Working Decision

For the current phase:

- the detached `dev` shell is the sole active learner-facing product surface
- treat `dev` as the live `main 2.0` path for product direction, shell composition, trust, identity, pedagogy presentation, and learner-visible flow shaping
- treat current `main` families as donor/archive truth, not as a parallel active product center

Primary active surface family:

- `lib/ui_v2/act0_shell/**`

Primary detached entry surface today:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Primary donor/archive families:

- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
- `lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- `lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart`
- other active runner/runtime families carrying canonical truth, edge-case handling, and guard-backed behavior not yet re-expressed in `dev`

## What This Means In Practice

Default assumption:

- if a task changes what the learner sees, feels, understands, or trusts, it belongs in `dev`

This includes:

- shell composition
- first-session trust
- mascot/persona expression
- summary/review presentation
- explanation clarity
- table readability
- navigation feel
- learner-facing polish

Do not treat `main` as an active product surface for:

- new learner-facing polish
- new visual direction
- new shell composition ideas
- new first-session framing
- new mascot/persona placement
- default UI iteration

Use `main` only as donor/archive truth for:

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
- maintaining legacy-entry compatibility for tests, release checks, or donor verification

Not allowed by default:

- continuing to evolve `main` as the preferred learner-facing shell
- splitting new product direction across `main` and `dev`
- landing new learner-facing polish in old host surfaces just because the donor path already exists

## Cutover Guardrails

1. One active learner-facing product center at a time.
   The active center is `dev`.

2. `main` is no longer a co-equal surface in planning language.

3. Prefer new `dev`-native implementations over hauling large host/UI chunks from `main`.

4. Reuse truth, contracts, and narrow logic from `main`; do not blindly transplant its whole shell architecture.

5. When a piece is missing in `dev`, decide in this order:
   - can it be designed cleanly in `dev` from known truth?
   - if not, can a narrow donor contract or adapter be extracted from `main`?
   - only then consider borrowing a larger implementation slice

6. Keep `main` searchable and intact as a donor archive until a deliberate repository migration is chosen.

7. Do not reopen `main` as a product-direction surface without concrete new evidence that `dev` cannot carry the next active bottleneck family.

## Current Non-Goal

This is a working-surface cutover, not yet a destructive repository migration.

Do not do the following by default:

- mass file moves
- broad renames to hide old `main` families
- deleting donor surfaces just because `dev` is the active product center
- rewriting readiness scoring to pretend the cutover changed final-readiness truth

The current move is executional:

- `dev` owns learner-facing product direction now
- `main` remains available as donor/archive truth

## Reassessment Trigger

Reassess this policy when one of the following becomes true:

- `dev` is broad enough to stand on its own runtime/progression footing
- the donor extraction list is small and stable
- the repo is ready for a deliberate harder migration or archival plan

At that point, decide whether to:

- keep the cutover policy as-is
- promote a harder repository migration plan
- archive or demote more of `main`
