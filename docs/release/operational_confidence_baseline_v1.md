# Operational Confidence Baseline v1

## Purpose

This file is the canonical owner for what current `main` can and cannot
operationally observe today.

It is not a dashboard program, not a backend-ops plan, and not a claim that
launch operations are fully governed.

## Current Scope

- Scope: bounded operational-confidence baseline for current `main`
- Coverage shape: release-critical telemetry presence, repo-local report sink
  presence, bounded release-confidence artifacts, and low-ops proof surfaces
  already owned in-repo
- Decision policy: baseline presence does not imply governed operational review
  closure

## Review Cadence On Current Main

- Re-run the bounded operational-confidence checks after any wave that changes
  release-confidence, telemetry ownership, or launch-surface truth
- Re-run the same checks before any pre-release build or dry-run review
- Generate the bounded operational review packet when the same review seam is
  rerun:
  - `dart run tools/operational_review_packet_v1.dart --timestamp <iso8601> --write`
- Current machine-review cadence is bounded to:
  - `dart test test/contracts/telemetry_release_critical_integrity_test.dart`
  - `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`
  - `dart run tools/release_readiness_snapshot_v1.dart`
- No stronger governed post-launch or production-review cadence is claimed on
  current `main`

## Canonical Governed Review Loop On Current Main

- Canonical bounded review surface:
  `docs/release/operational_review_packet_truth_v1.md`
- Review owner on current `main`:
  `docs/release/release_owner_review_v1.md`
- Review cadence on current `main`:
  - after any wave that changes release-confidence, telemetry ownership, or
    launch-surface truth
  - before any pre-release build or dry-run review
- Review inputs:
  - `docs/release/release_confidence_baseline_v1.md`
  - `docs/release/final_product_release_checklist_v1.md`
  - `docs/release/final_product_smoke_baseline_v1.md`
  - `docs/release/go_hold_rollback_truth_v1.md`
  - `docs/release/operational_dashboard_governance_truth_v1.md`
  - `docs/release/rollback_ownership_truth_v1.md`
  - `docs/release/release_owner_decision_template_v1.md`
  - `tools/release_readiness_snapshot_v1.dart`
- Decision use now:
  - supports bounded release-owner review on whether HOLD remains honest
  - supports bounded review of whether current machine proof still matches the
    active release scope
  - supports bounded review of whether rollback ownership is still unresolved
    but explicitly owned
- This governed loop does not claim production observability maturity, a live
  analytics program, or post-launch dashboard closure.

## Decisions Current Main Can Support

- Whether release-critical telemetry events remain registered in the telemetry
  SSOT
- Whether release-critical telemetry event names remain referenced in app/runtime
  code
- Whether the repo still has a local release telemetry sink at
  `release/_reports/telemetry.jsonl`
- Whether bounded release-confidence owners and low-ops proof artifacts remain
  present and aligned
- Whether the bounded release-confidence packet still supports a HOLD verdict
  instead of an overclaimed GO decision
- Whether the current bounded release owners still leave rollback truth
  unresolved but explicitly owned

## Active Release Questions This Loop Answers Now

- Does current `main` still support `HOLD`, not `GO`, on bounded machine proof?
- Does the bounded smoke/checklist family still match the active release scope
  being claimed?
- Do release-critical telemetry references and the local telemetry sink still
  exist for bounded release review?
- Is rollback ownership still explicit, even though the rollback runbook is not
  yet resolved?
- Which decision areas remain manual-only before stronger release claims can be
  made?

## Decisions Still Manual-Inference-Only

- Which real user cohorts, devices, or store-channel segments are succeeding or
  failing in production
- Whether telemetry outputs are already governed by a repeatable release-owner
  review loop with decision history
- Whether launch/post-launch operational questions are already answered by one
  stable dashboard or report family

## Dashboard / Report Truth On Current Main

- Canonical dashboard-governance owner on current `main`:
  `docs/release/operational_dashboard_governance_truth_v1.md`
- No canonical active dashboard is currently the governed decision owner for
  launch or post-launch operations
- `release/_reports/telemetry.jsonl` is a local telemetry sink, not a governed
  dashboard
- `release/_reports/operational_review_packet_v1.md` and
  `release/_reports/operational_review_packet_v1.json` are the bounded review
  history artifacts for the governed bounded release-question loop on current
  `main`
- Generated report files under `release/_reports/` remain informational unless a
  newer active owner explicitly promotes them
- `docs/release/RELEASE_README.md` is a historical snapshot, not active
  operational-confidence authority

## Machine-Proven Now

- `test/contracts/telemetry_release_critical_integrity_test.dart`
- `test/contracts/store_package_telemetry_guard_test.dart`
- `release/_reports/telemetry.jsonl`
- `docs/ops/low_ops_burden_proof_v1.md`
- `tools/release_readiness_snapshot_v1.dart`

## Human-Proof Still Needed

- Review cadence proving which telemetry/reports actually drive release or
  operational decisions
- Confirmation that the bounded operational questions above are sufficient for
  the active release scope

## Guardrail

If an operational-confidence surface implies governed dashboards, production
observability, or low-touch launch operations beyond the bounded scope above,
that claim is overclaimed.
