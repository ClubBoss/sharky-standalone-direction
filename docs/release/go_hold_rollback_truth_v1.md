# Go / Hold / Rollback Truth v1

## Purpose

This file is the canonical owner for go/hold/rollback decision truth on current
`main`.

## Current Decision State

- Current state: HOLD
- Reason: current `main` has bounded machine proof and explicit human-proof-only
  gaps
- GO policy: no GO claim is valid unless a human release owner records it
  against this owner family after reviewing the active checklist and smoke
  baseline using `docs/release/release_owner_decision_template_v1.md`

## Machine Inputs

- `docs/release/release_confidence_baseline_v1.md`
- `docs/release/final_product_release_checklist_v1.md`
- `docs/release/final_product_smoke_baseline_v1.md`
- `docs/EXECUTION_RULES.md`
- `docs/release/release_owner_review_v1.md`
- `docs/release/operational_review_packet_truth_v1.md`
- `docs/release/rollback_ownership_truth_v1.md`

## Human-Proof Required Before GO

- Release-owner review of the checklist and smoke baseline
- Explicit review of store/distribution materials and policy-facing fields
- Explicit decision record that the current state may move from HOLD to GO
- Review owner artifact:
  `docs/release/release_owner_review_v1.md`
- Required bounded operational review packet artifacts:
  - `release/_reports/operational_review_packet_v1.md`
  - `release/_reports/operational_review_packet_v1.json`
- Required decision template for any newer active decision artifact:
  `docs/release/release_owner_decision_template_v1.md`

## Rollback Truth On Current Main

- No active artifact currently proves a finalized production rollback runbook
- Current rollback ownership truth is explicitly owned by:
  `docs/release/rollback_ownership_truth_v1.md`
- Current-main truth is therefore conservative:
  - default to HOLD if machine proof or human proof is incomplete
  - do not publish a new release candidate when blocking contradictions remain
  - if a release candidate is later judged unsafe, the rollback owner must be a
    newer active artifact than this file

## Guardrail

If a release-confidence surface implies GO, resolved rollback ownership, or
final launch approval without a newer active decision artifact, that claim is
overclaimed.
