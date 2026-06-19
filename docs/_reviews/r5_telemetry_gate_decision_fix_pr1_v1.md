# R5 Telemetry Gate Decision Fix PR1 v1

## 1. PR #1 CI status

- PR: `Act0 broad preview gate recovery`
- Head: `codex/act0-broad-preview-gate-recovery`
- Base: `main`
- Pre-fix status:
  - `contract`: passed
  - `verify`: passed
  - `l2`: skipped
  - `r5-release-gate`: failed
  - `TestSprite Pre-Check`: failed, external status with no details URL

## 2. Exact R5 telemetry failure command/log summary

R5 executes:

```bash
./tools/run_release_gate_r5_v1.sh
```

That script failed at:

```bash
dart run tools/run_content_qa_r2_v1.dart
```

The failing child audit was:

```bash
dart run tools/audit_worlds_0_4_telemetry_v1.dart
```

The audit reported all telemetry requirements missing because it scanned:

```text
lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart
```

That file does not exist in the current branch. The current R2 legacy runner
emission owner exists at:

```text
lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart
```

## 3. Event/payload failure matrix

| requirement | product contract required | already emitted | stale audit path | caused by PR #1 | needs product telemetry implementation |
| --- | --- | --- | --- | --- | --- |
| `session_start` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `session_end` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `session_abort` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `user_choice` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `correct` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `time_to_decision` | Yes | Yes, in archived legacy runner owner | Yes | No | No |
| `error_type` | Yes | Yes, in archived legacy runner owner payload | Yes | No | No |
| `time_to_decision_ms` | Yes | Yes, in archived legacy runner owner payload | Yes | No | No |

## 4. Root-cause classification

Decision path: **B. Test/audit fix**.

The telemetry events and payloads exist, but the audit scanned a stale,
non-existent runner-layer file. This made the static scan read an empty source
string and report every requirement as missing.

This was not classified as an Act0 repair-intent telemetry regression, because
PR #1 did not remove the R2 legacy telemetry emissions and the active Act0
shell has its own private telemetry sink/events.

## 5. Decision selected: A/B/C/D

Selected: **B. Test/audit fix**.

Rationale:

- The failing R5 gate was real, but the failure source was a stale audit path.
- The required events/payloads already exist at the current R2 legacy owner.
- Updating the audit owner is narrower than changing product telemetry or
  weakening R5.

## 6. Fix applied, if any

- Updated `tools/audit_worlds_0_4_telemetry_v1.dart` to scan
  `lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart`.
- Updated `test/tools/worlds_0_4_telemetry_audit_contract_test.dart` to lock the
  current R2 emission owner path.

No Act0 visual behavior, product flow, monetization, capture tooling, Playwright
output, TestSprite output, or telemetry event implementation was changed.

## 7. Local checks run

- `dart run tools/audit_worlds_0_4_telemetry_v1.dart`: passed
- `dart run tools/run_content_qa_r2_v1.dart`: passed
- `flutter test test/tools/worlds_0_4_telemetry_audit_contract_test.dart`: passed
- `flutter analyze`: passed
- `git diff --check`: passed
- `./tools/fast_loop_world1_v1.sh`: passed
- `./tools/release_gate_world1.sh`: passed
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart`: passed
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`: passed
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart`: passed
- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`: passed
- `./tools/run_release_gate_r5_v1.sh`: failed after the telemetry fix at
  `critical contract tests`

The local R5 run confirmed the telemetry step is fixed:

```text
[r5-gate] OK r2 content qa
```

The next R5 blocker is outside this telemetry wave:

```text
[r5-gate] FAIL critical contract tests exit=1
```

The critical tests fail to compile because they import missing legacy map/runner
paths:

```text
lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart
```

Affected tests:

```text
test/guards/world_campaign_map_home_contract_test.dart
test/guards/world_campaign_routing_matrix_contract_test.dart
```

## 8. GitHub checks after push

Pending until this fix is committed and pushed.

Expected result:

- `r5-release-gate` should pass the R2 telemetry audit path that previously
  failed.
- `r5-release-gate` may then fail later at the known stale critical contract
  tests unless that separate blocker is fixed.
- `contract` should remain passed.
- `verify` should remain passed.
- `TestSprite Pre-Check` may remain red because it is an external/config-level
  status with no local repo configuration found.

## 9. TestSprite status and recommendation

`TestSprite Pre-Check` remains classified as external/config-level. No repo
workflow or TestSprite config was found, and adding fake tests or generated
placeholder output would be out of scope.

Recommendation: resolve through GitHub integration or branch-protection policy
after R5 is green.

## 10. Merge recommendation

Do not merge while required checks are red.

This wave fixes the telemetry audit blocker. PR #1 should not merge until the
separate stale critical contract test blocker is handled or formally
reclassified, and until `TestSprite Pre-Check` is resolved or explicitly waived
by repository policy.
