# W3 Canonical Certification Pilot v1

Status: Accepted.
Date: 2026-06-29.
Verdict: `w3_canonical_certification_pilot_ready`.

## 1. Verdict

W3 can safely enter the W1/W2-style canonical certification path through one
narrow canonical pilot.

This is not a W3 8.0 certification, not a launch-ready claim, and not broad W3
migration. It proves that selected existing W3 chain tasks can be exported as a
canonical, validator-backed Position Thinking slice while the older W3 bridge
fixture remains bridge-limited.

## 2. Source Truth

The pilot uses existing source tasks only:

- `content/worlds/world3/v1/sessions/w3.s11/drills/d.chain_position_open_call_v1.json`
- `content/worlds/world3/v1/sessions/w3.s12/drills/d.chain_position_continue_fold_v1.json`
- `content/worlds/world3/v1/sessions/w3.s13/drills/d.chain_position_open_fold_v1.json`
- `content/worlds/world3/v1/sessions/w3.s14/drills/d.chain_position_sensitive_open_fold_v1.json`

The selected source steps ask the learner to read position first, then choose
raise, call, or fold from the resulting preflop action frame.

## 3. Current W3 State

Before this wave, W3 had one bridge fixture:

- `test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json`

That bridge fixture remains valid but bridge-limited. It is not canonical launch
coverage and is intentionally kept separate from the new canonical pilot.

## 4. Canonicalization Decision

Accepted for a narrow pilot.

The canonical slice honestly matches the learner-facing W3 title, `Position
Thinking`, because every selected task is organized around position before
preflop action. The broader W3 source job still contains preflop-framework
bridge material, so broad W3 certification remains blocked until additional
canonical coverage or source-title reconciliation exists.

## 5. Migration Output Summary

New fixture:

- `test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json`

Output properties:

- `tasks=6`
- `world_id=world_3`
- `route_world_id=world_3`
- `display_world_title=Position Thinking`
- `content_owner_world_id=world_3`
- `route_gate_status=learner_playable`
- `source_truth_status=migrated`
- `safe_claim_status=canonical_pilot`
- `launch_coverage_claimed=false`
- `concept_family_id=position_sensitive_preflop_decision`
- `same_signal_group_id=w3.position_thinking.position_before_preflop_action`
- `repair_focus_id=position_before_preflop_action`

## 6. L2/L3 Validation Results

Canonical pilot alone:

```text
content_schema_l2_l3_validator_v1: fixtures=1 worlds=1 tasks=6 coverage_countable=6
content_schema_l2_l3_validator_v1: world_3 tasks=6 coverage_countable=6 coverage_ready=true transfer_ready=true repair_ready=true route_admission=learner_playable_route_ready
content_schema_l2_l3_validator_v1: OK
```

Bridge plus canonical:

```text
content_schema_l2_l3_validator_v1: fixtures=2 worlds=1 tasks=9 coverage_countable=9
content_schema_l2_l3_validator_v1: world_3 tasks=9 coverage_countable=9 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

## 7. Test Coverage

Added focused tests for:

- deterministic W3 canonical pilot export;
- six unique W3 task IDs;
- migrated source truth and canonical pilot claim status;
- preserved chain source metadata and step indexes;
- W3 canonical pilot route-ready L2/L3 report;
- W3 bridge plus canonical negative-control report staying bridge-limited.

Focused test command:

```bash
flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart
```

Result: all tests passed.

## 8. W3 Certification Impact

W3 now has one canonical certification pilot and one separate bridge-limited
fixture.

W3 does not earn 8.0. The pilot proves a canonical path exists, but W3 still
lacks broad canonical coverage, correctness review, payoff/progression proof,
Human QA, and full migration.

## 9. Ledger Impact

Proposed conservative movements:

- W3 world score: `5.1 -> 5.5`.
- W1-W12 Volume I Premium Product Readiness: `6.8 -> 6.9`.
- Content depth: `5.4 -> 5.5`.
- Overall top-1 readiness: unchanged at `6.3`.

Reason: one W3 route-ready canonical same-signal group exists, but the broader
W3 world remains mixed and not launch-ready.

## 10. Route Impact

Active next wave should move from `W3 Canonical Certification Pilot` to
`W3 Canonical Coverage Expansion PR2`.

Do not batch W4-W6 yet. W3 should first prove a second canonical W3 family or
document the exact source/title blocker.

## 11. Active Repair Queue Update

W3 active repair queue:

- keep bridge fixture separated as a negative control;
- expand canonical Position Thinking coverage from existing source if safe;
- decide whether remaining W3 preflop-framework source belongs in W3, W4, or a
  later source-title realignment artifact.

## 12. Evidence DoD Status

- Exporter writes the W3 canonical pilot fixture.
- Foundation validator passes on the W3 canonical fixture.
- L2/L3 passes on the W3 canonical fixture alone.
- L2/L3 keeps W3 bridge plus canonical bridge-limited.
- Focused exporter and L2/L3 tests pass.
- No screenshots, UI work, telemetry, monetization, W7-W12 opening, W13-W36
  dependency, or Human QA execution occurred.

## 13. Anti-Theater Check

This is a real source-backed pilot because it preserves `source_path`,
`source_id`, `source_chain_id`, and `source_step_index` in `migration_source`.

This is not broad W3 certification. The negative-control bridge fixture still
prevents mixed W3 evidence from being reported as route-ready canonical
coverage.
