# Rollback Ownership Truth v1

## Purpose

This file is the canonical owner for rollback ownership truth on current
`main`.

It may remain unresolved, but it must not remain ownerless or ambiguous.

## Current State

- Current state: UNRESOLVED_BUT_OWNED
- Current-main policy: release-owner control remains on HOLD until a newer
  active artifact names a stronger rollback operator/runbook truth

## Current Owner Rule

- The release-owner review family owns the unresolved rollback state on current
  `main`
- `docs/release/go_hold_rollback_truth_v1.md` remains the decision artifact
- This file remains the canonical owner for whether rollback truth is resolved
  versus explicitly unresolved

## Current Bounded Proof On Main

- `dart run tools/release_readiness_snapshot_v1.dart` must continue to report:
  - `goNoGoStateIsHold = true`
  - `rollbackTruthSaysUnresolved = true`
  - `rollbackOwnershipOwnerPresent = true`
  - `rollbackOwnershipSaysUnresolvedButOwned = true`
- `docs/release/release_owner_review_v1.md` remains the human-review owner for
  the unresolved rollback state on current `main`
- `docs/release/operational_review_packet_truth_v1.md` remains the bounded
  packet owner for the supporting operational review loop
- Current bounded review artifacts for that loop are:
  - `release/_reports/operational_review_packet_v1.md`
  - `release/_reports/operational_review_packet_v1.json`
- Any newer active human decision artifact that claims stronger rollback truth
  must still use:
  - `docs/release/release_owner_decision_template_v1.md`
- This is ownership truth only, not proof of a finished rollback runbook

## Explicit Non-Machine Boundary On Current Main

- No executable rollback or deploy target seam currently exists on current
  `main`.
- No active artifact currently names one bounded rollback family with:
  - a real trigger
  - a real operator
  - a real target or build reference
  - a real verification path after rollback
- Current repo truth therefore contains rollback ownership truth only, not a
  machine-admissible rollback implementation seam.

## What A Stronger Artifact Must Name

- rollback trigger
- rollback operator / owner
- rollback target or build reference
- verification steps after rollback

## Future Wave Boundary

- A future bounded rollback implementation wave is only honest if a newer
  active artifact first defines a real executable rollback target seam.
- Until that seam exists, rollback work should not be presented as a machine
  implementation closeout.

## Guardrail

If a release-confidence surface implies resolved rollback ownership without a
newer active artifact than this file, that claim is overclaimed.
