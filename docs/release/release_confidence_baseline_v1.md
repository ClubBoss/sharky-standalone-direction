# Release Confidence Baseline v1

## Purpose

This file is the canonical baseline for what current `main` actually proves
about release confidence today.

It is not a launch verdict, not a GO signal, and not a substitute for
final-product release-owner review.

## Current Scope

- Scope: bounded multi-surface release-confidence baseline
- Coverage shape:
  - canonical world1 active path
  - branch progression boundary proof
  - premium/trust/legal runtime proof seams
  - release-doc/store-package proof seams
- Verdict policy: not a GO verdict

## What Has Widened Beyond The Older Bounded Beta Slice

- Release-confidence proof is no longer framed as only the canonical world1
  runner path.
- Current `main` now also carries bounded proof for:
  - session-result continuation on the canonical path
  - premium hub access-state truth
  - premium-target route gating truth
  - branch progression boundary isolation
  - legal surface presence
  - release-doc/store-package guard families
- This is still bounded proof, not whole-product machine coverage.

## Machine-Proven Now

- `docs/EXECUTION_RULES.md` defines the active release-confidence execution
  rules.
- `tool/release_dry_run_gate.sh` exists and sequences the documented dry-run
  contract set.
- `tool/release_smoke_baseline_v1.sh` exists and sequences the bounded runtime
  smoke family claimed by the current release owner docs.
- `tools/release_gate_world1.sh` exists as the active scoped runtime gate.
- Store package asset/docs/execution-rules/telemetry contracts exist.
- Release-content meaningful contract exists.
- Bounded canonical first-session proof seams exist:
  - onboarding first-win contract
  - universal intake/today plan contract
  - first-session result continuation contract
  - premium-entry and premium-target gating contracts
  - branch progression boundary contract
  - legal surface presence contract
  - branch progression surface presence

## Human-Proof Only

- Release-owner review that current gate scope matches the actual product scope.
- Real store-console review of submission materials.
- Final launch decision from an explicit go/hold review.
- Human review owner:
  `docs/release/release_owner_review_v1.md`

## Unresolved On Current Main

- The active runtime release gate is still world1-scoped, not full-product.
- `docs/release/final_product_release_checklist_v1.md` is a current-main truth
  owner, not machine proof that every final-product path is covered.
- `docs/release/final_product_smoke_baseline_v1.md` is a bounded smoke owner,
  not complete whole-product smoke coverage.
- `docs/release/go_hold_rollback_truth_v1.md` keeps the decision state at HOLD
  until human release review records something stronger.
- `docs/release/rollback_ownership_truth_v1.md` keeps rollback ownership
  explicit, but unresolved for current `main`.

## Current Bounded Proof On Main

- `dart run tools/release_readiness_snapshot_v1.dart` must continue to report:
  - `baselineDocPresent = true`
  - `baselineDocSaysNotGo = true`
  - `baselineDocSaysBoundedScope = true`
  - `goNoGoStateIsHold = true`
  - `moduleLauncherBoundaryContractPresent = true`
- This owner stays aligned with:
  - `docs/EXECUTION_RULES.md`
  - `docs/release/final_product_release_checklist_v1.md`
  - `docs/release/final_product_smoke_baseline_v1.md`
  - `docs/release/go_hold_rollback_truth_v1.md`
  - `docs/release/operational_review_packet_truth_v1.md`
  - `docs/release/release_owner_decision_template_v1.md`
  - `docs/release/release_owner_review_v1.md`
  - `docs/release/submission_metadata_truth_v1.md`
- This owner records the bounded release-confidence baseline only.
- This owner widens proof beyond the older bounded beta slice, but only through
  bounded multi-surface release-confidence seams already present on current
  `main`.
- This owner does not claim release completion.
- This owner does not claim GO.
- This owner does not claim whole-product machine clearance.

## Guardrail

If a release-confidence surface describes current `main` as launch-ready,
full-product covered, or GO-ready, that claim must be backed by a newer active
owner than this baseline. Otherwise it is overclaimed.
