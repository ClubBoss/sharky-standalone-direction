---
status: "w1_w6_runtime_bundle_integrity_closed_wave5_admitted"
status_source: "derived"
doc_date: "2026-07-07"
baseline: "00e0867cd76e"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Runtime Bundle + Build Integrity Gate v1

Date: 2026-07-07

Branch: `codex/w1-w6-runtime-bundle-build-integrity-v1`

Base HEAD: `00e0867cd76e95cff7f67a0f674d89055523b91d`

## 1. Verdict

`w1_w6_runtime_bundle_integrity_closed_wave5_admitted`

The active W1-W6 runtime-bundle integrity debt is closed for the admitted gate.
No Wave 5 work was started.

## 2. Mission boundary

This wave only reconciled active W1-W6 drill identity truth across:

- `content/_meta/world_drills_manifest_v1.json`;
- active `drills/index.md` rows;
- Flutter test bundle assets;
- local `build/flutter_assets` runtime bundle assets;
- `DrillRuntimeAdapterV1` loader behavior;
- focused guards that consume active manifest truth.

No learner-facing drill JSON, production runner logic, Wave 5 telemetry, W7+
route expansion, Modern Table visual work, dependency changes, or global
full-suite repair was performed.

## 3. Starting failure

Known failure reproduced:

```text
flutter test -r compact test/services/drill_runtime_adapter_v1_asset_bundle_test.dart --plain-name 'repaired world3 and world5 manifest truth stays in parity across source, test bundle, and runtime bundle'
```

Failure:

- `w3.s03` source manifest exposed retired
  `choose_call_preflop_checkpoint_v1` beside active
  `chain_preflop_checkpoint_v1`.

The full focused file also showed stale W1 chain IDs in the repaired-family
manifest assertions.

## 4. Root cause

The runtime adapter loads canonical `content/` files from disk first, then falls
back to `rootBundle` and optional bundled asset paths. The active source
manifest still carried retired W1/W3/W4/W5/W6 rows that were no longer present in
the active drill indexes. The local runtime bundle also needed to be refreshed
after manifest repair.

## 5. Owner matrix

| Owner | Role | Result |
| --- | --- | --- |
| `content/worlds/world*/v1/sessions/*/drills/index.md` | active drill identity source | W1-W6 active IDs used as source truth |
| `content/_meta/world_drills_manifest_v1.json` | source/test-bundle manifest | W1-W6 sections realigned to active indexes |
| `build/flutter_assets/content/_meta/world_drills_manifest_v1.json` | local runtime-bundle manifest | refreshed with `flutter build bundle` |
| `lib/services/drill_runtime_adapter_v1.dart` | runtime loader | unchanged; representative active paths proven |
| `test/services/drill_runtime_adapter_v1_asset_bundle_test.dart` | bundle/loader parity guard | extended for W1-W6 and representative adapter order |
| `tools/w1_w6_feedback_completeness_guard.dart` | active feedback scanner | unchanged; active count now 374 |

## 6. Manifest repair

Only the W1-W6 manifest sections were regenerated from active indexes. W0 and
W7+ sections were not admitted and were left untouched.

Representative repaired truth:

- `w1.s10`: `choose_call_focus`, `choose_fold_focus`, `choose_raise_focus`.
- `w3.s03`: `chain_preflop_checkpoint_v1`.
- `w3.s06`: `chain_preflop_mixed_context_checkpoint_v1`.
- `w3.s10`: `chain_preflop_final_checkpoint_v1`,
  `choose_call_btn_facing_open_transfer_v1`,
  `choose_fold_bb_weak_facing_open_transfer_v1`,
  `choose_raise_btn_clean_transfer_v1`.
- `w3.s14`: `chain_position_sensitive_open_fold_v1`.
- `w5.s01`: six active board-texture intro rows from the active index.
- `w6.s01`: active range/bucket/table rows from the active index.

## 7. Runtime bundle refresh

`flutter build bundle` was run after the manifest repair. It refreshed local
runtime bundle assets without introducing tracked build artifacts.

## 8. Guard extensions

`test/services/drill_runtime_adapter_v1_asset_bundle_test.dart` now includes:

- active W1-W6 index -> source manifest -> test bundle -> runtime bundle parity;
- representative W1/W3/W5/W6 adapter-path proof;
- accepted W3.s10 transfer IDs in the repaired W3/W5 guard;
- retired W3 ID exclusions.

`test/tools/w1_w6_feedback_completeness_guard_v1_test.dart` now expects the
current active manifest count: `374` active decision rows, with zero feedback
violations.

## 9. W3 parity closure

Retired/stale W3 IDs removed from active source manifest truth:

- `choose_call_preflop_checkpoint_v1`;
- `choose_raise_mixed_context_checkpoint_v1`;
- `choose_raise_late_position_leverage_v1`.

The already-retired `choose_fold_final_preflop_checkpoint_v1` remains excluded
from manifest truth and is covered by forbidden-ID checks.

## 10. Deterministic active path proof

Representative adapter sessions proved active index order:

- `w1.s10`;
- `w3.s10`;
- `w5.s01`;
- `w6.s01`.

This proves the runtime loader executes current active index truth, not stale
manifest-only or stale bundle-only truth.

## 11. Validation

Focused runtime/bundle validation:

- Known runtime-bundle parity test: PASS.
- Bounded W1-W6 parity guard: PASS.
- Representative W1/W3/W5/W6 adapter path guard: PASS.
- Full `test/services/drill_runtime_adapter_v1_asset_bundle_test.dart`: PASS.

Projection / evaluator / feedback / structured context:

- `test/guards/world3_early_arc_runtime_truth_contract_test.dart`: PASS.
- `test/guards/world5_early_runtime_truth_contract_test.dart`: PASS.
- `test/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1_test.dart`: PASS.
- `test/ui_v2/runner/session_drill_canonical_source_meta_entries_v1_test.dart`: PASS.
- `test/ui_v2/runner/session_drill_canonical_corrective_feedback_v1_test.dart`: PASS.
- `test/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1_test.dart`: PASS.
- `test/ui_v2/session_drill_player_world5_structured_context_contract_test.dart`: PASS.

Identity, admission, feedback, and terminology:

- Canonical world identity guard: PASS.
- Seven-file Tier0 admission set: PASS (`37/37`).
- W1-W6 feedback completeness guard: PASS (`374` active rows, zero violations).
- Term introduction/glossary safety: PASS.
- `dart run tools/term_coverage_scanner.dart --help`: PASS.

Policy and hygiene:

- `./tools/fast_loop_world1_v1.sh`: PASS.
- `./tools/release_gate_world1.sh`: PASS.
- `flutter analyze`: PASS.
- `git diff --check`: PASS.
- `git diff --cached --check`: PASS.
- `graphify hook-check`: PASS.

Checkpoint:

- `./tools/checkpoint_world1_v1.sh` passed release-gate/Tier0/world1 contract
  sections, then entered the known global full-suite debt zone.
- Observed unrelated global failures included missing `audit_hub_v1` imports,
  stale `stack_range_filter_test.dart` function-call syntax, stale smoke syntax
  and API drift, and unrelated personalization expectation drift.
- Full-suite repair was not opened; the checkpoint was stopped after repeated
  known non-blocking global debt appeared.

## 12. Generated-output policy

No generated build output was staged or committed. The local runtime bundle was
refreshed only for validation.

## 13. Capsule freshness

No current-state capsule was modified on this feature branch. The branch is a
pre-integration gate branch; current-state capsules should be refreshed, if
needed, only after this branch is integrated into `main`.

## 14. Remaining known non-blockers

Global full-suite debt remains outside this gate:

- audit hub archived/missing imports;
- stale stack-range syntax;
- unrelated smoke syntax/API drift;
- unrelated personalization expectation drift.

These failures are not caused by the runtime-bundle manifest repair and do not
block the admitted W1-W6 gate.

## 15. Next owner action

Integrate `codex/w1-w6-runtime-bundle-build-integrity-v1` into `main` if the
branch is accepted.

After integration, the exact next admitted product step remains Wave 5 under a
new explicit owner prompt.
