# NOVICE_WALKTHROUGH_EVIDENCE_v1

Status: ACTIVE
Purpose: keep one compact evidence log for `Audit B: Novice Walkthrough Proof` and separate automated proof from required human walkthrough proof.
Last updated: 2026-05-14

## Authority

Use this file beneath:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/PRODUCT_100_PROOF_AUDIT_v1.md`
- `docs/plan/NOVICE_WALKTHROUGH_PROTOCOL_v1.md`
- `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`

This file does not replace the novice protocol.

## Current Gate State

- Verdict: `Novice gate open`
- Reason: protocol requires `2-3` real novice moderated runs; automated tests alone are not sufficient.

## Automated Evidence (Completed)

Run date: 2026-05-14

1. `flutter test test/proof/novice_walkthrough_automated_v1_test.dart`
   - Result: PASS (`+5 -0`)
   - Confirms:
     - sample state initializes coherently
     - first world and first lesson/task structure exists
     - first task runner has non-empty feedback title/reason
     - empty synthetic feedback pairs in sample traversal: `0`

2. `dart run tools/act0_feedback_floor_audit.dart`
   - Result: PASS
   - Key output:
     - feedback titles: `500`
     - feedback reasons: `501`
     - empty feedback titles: `0`
     - empty feedback reasons: `0`
     - empty synthetic feedback pairs in runner wiring: `0`

3. `flutter test test/ui_v2/act0_shell_state_v1_feedback_test.dart`
   - Result: PASS (`+3 -0`)
   - Confirms:
     - source-level title/reason presence and non-empty floor
     - top-2 title share stays below `25%`
     - known synthetic/generic fallback ban-list remains absent

## Human Walkthrough Evidence (Required To Close Gate)

Required by protocol:

- `2` runs if clean and consistent
- `3` runs if split or ambiguous
- active route only:
  - `Placement -> Home -> first useful hand -> Result -> back to Home`

Templates to use:

- `docs/plan/NOVICE_WALKTHROUGH_RUN_NOTES_TEMPLATE_v1.md`
- `docs/plan/NOVICE_WALKTHROUGH_SYNTHESIS_TEMPLATE_v1.md`

## Minimal Closure Checklist

1. Run `2-3` moderated novice sessions using `NOVICE_WALKTHROUGH_PROTOCOL_v1.md`.
2. Record notes with the run template for each participant.
3. Produce one synthesis note with one protocol verdict.
4. If needed, identify at most one bounded residue family.
5. Update `ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md` from `Novice gate open` to the exact protocol verdict.

## Explicit Non-Goals

- no broad redesign list
- no dormant-system exploration
- no architecture split work
- no monetization fork decisions inside this gate
