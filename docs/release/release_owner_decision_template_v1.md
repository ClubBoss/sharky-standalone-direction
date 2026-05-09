# Release Owner Decision Template v1

## Purpose

This file defines the minimum structure for any newer human release-owner
decision artifact on current `main`.

It is a template only.
It does not change the current decision state.
It exists so the remaining `Ops / Release Confidence` proof gate can be closed
with one governed, reviewable artifact shape instead of ad hoc judgment notes.

## When To Use

Create a newer active decision artifact from this template only after reviewing:

- `docs/release/release_owner_review_v1.md`
- `docs/release/go_hold_rollback_truth_v1.md`
- `docs/release/rollback_ownership_truth_v1.md`
- `docs/release/operational_review_packet_truth_v1.md`
- `docs/release/release_confidence_baseline_v1.md`
- `docs/release/operational_confidence_baseline_v1.md`
- `docs/release/final_product_release_checklist_v1.md`
- `docs/release/final_product_smoke_baseline_v1.md`
- `release/_reports/operational_review_packet_v1.md`
- `release/_reports/operational_review_packet_v1.json`
- `dart run tools/release_readiness_snapshot_v1.dart`

## Required Header Fields

- Decision timestamp in UTC
- Decision owner name or role
- Branch / commit reviewed
- Decision state:
  - `HOLD`
  - `GO`
  - `GO_WITH_EXPLICIT_LIMITS`
- Scope reviewed:
  - bounded release scope only
- Superseded artifacts:
  - `docs/release/go_hold_rollback_truth_v1.md`
  - `docs/release/release_owner_review_v1.md`
  - any older decision note this artifact replaces

## Required Questions To Answer

### 1. Scope honesty

- Does the reviewed smoke/checklist scope still match the real product breadth
  being claimed?

### 2. Decision honesty

- Does current evidence still support `HOLD` as the honest current-main
  decision?
- If not, what exact stronger decision is justified?

### 3. Rollback honesty

- Is rollback ownership still explicit and acceptable for the reviewed scope?
- If rollback remains unresolved, why is the chosen decision still honest?

### 4. Manual-only residue

- Which areas remain human-only, external, store-facing, or dashboard-governed?
- Which of those remain outside current machine proof?

## Required Evidence Section

List the exact artifacts reviewed, including:

- `docs/release/release_confidence_baseline_v1.md`
- `docs/release/operational_confidence_baseline_v1.md`
- `docs/release/go_hold_rollback_truth_v1.md`
- `docs/release/rollback_ownership_truth_v1.md`
- `docs/release/release_owner_review_v1.md`
- `docs/release/operational_review_packet_truth_v1.md`
- `release/_reports/operational_review_packet_v1.md`
- `release/_reports/operational_review_packet_v1.json`
- output from `dart run tools/release_readiness_snapshot_v1.dart`

## Required Decision Body

State all of the following explicitly:

- chosen decision state
- why that state is honest on current `main`
- what evidence supports it
- what evidence does not exist yet
- what remains out of scope for machine proof
- what downstream claims are still forbidden

## Required Guardrails

Any filled decision artifact based on this template must not:

- imply whole-product proof when the review scope is bounded
- imply governed dashboard ownership not proven by current repo truth
- imply a finished rollback runbook if current truth remains unresolved
- imply that human review is complete without naming the owner and timestamp
- imply `GO` without explicitly superseding the current `HOLD` owners

## Minimal Filled Skeleton

```md
# Release Owner Decision <timestamp>

- Decision owner: <name or role>
- Reviewed branch / commit: <branch> / <sha>
- Decision state: HOLD | GO | GO_WITH_EXPLICIT_LIMITS
- Scope: bounded release scope on current main

## Evidence Reviewed

- <artifact list>

## Decision

- <explicit decision statement>

## Why This Is Honest

- <bounded reasoning>

## Remaining Limits

- <manual-only or unresolved areas>

## Supersedes

- docs/release/go_hold_rollback_truth_v1.md
- docs/release/release_owner_review_v1.md
- <older decision artifacts if any>
```
