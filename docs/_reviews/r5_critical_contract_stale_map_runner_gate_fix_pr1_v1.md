# R5 Critical Contract Stale Map Runner Gate Fix PR1 v1

## 1. PR #1 status

- PR: `Act0 broad preview gate recovery`
- Head: `codex/act0-broad-preview-gate-recovery`
- Base: `main`
- Pre-fix GitHub state:
  - `contract`: passed
  - `verify`: passed
  - `l2`: skipped
  - `r5-release-gate`: failed at critical contract tests
  - `TestSprite Pre-Check`: failed, external status with no details URL

## 2. Exact failing R5 critical tests

R5 failed in the `critical contract tests` step while running:

```text
test/guards/world_campaign_map_home_contract_test.dart
test/guards/world_campaign_routing_matrix_contract_test.dart
```

Both tests imported missing legacy/current paths:

```text
lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart
```

## 3. Failure reproduction

Commands reproduced the failure locally:

```bash
flutter test test/guards/world_campaign_map_home_contract_test.dart --reporter expanded
flutter test test/guards/world_campaign_routing_matrix_contract_test.dart --reporter expanded
```

The compile failures matched GitHub R5:

- missing `UiV2ProgressMapScreenV2`
- missing `World1FoundationsMicroTaskRunnerScreen`
- missing legacy runner mode constants such as
  `kWorld1RunnerModeCampaignSpine`

## 4. Per-test contract classification

| test | original contract | current validity | classification |
| --- | --- | --- | --- |
| `world_campaign_map_home_contract_test.dart` | Old map/home campaign route, map CTA, and legacy microtask runner launch | Stale relative to current Act0 canonical root | `stale_contract_replace` |
| `world_campaign_routing_matrix_contract_test.dart` | Old map/routing matrix and legacy microtask runner mode routing | Stale relative to current Act0 route truth | `stale_contract_replace` |

The files were not accidentally deleted by this PR. The current app boundary is
the Act0 shell route, and `Act0ShellPreviewScreenV1` is the canonical root.

## 5. Decision selected: A/B/C/D

Selected: **A. Refresh tests to current Act0/current route truth**.

The R5 critical test filenames remain in the R5 gate, but their stale bodies
were replaced with compact current-route contracts.

## 6. Files changed

- `test/guards/world_campaign_map_home_contract_test.dart`
- `test/guards/world_campaign_routing_matrix_contract_test.dart`
- `docs/_reviews/r5_critical_contract_stale_map_runner_gate_fix_pr1_v1.md`

## 7. Why this is not / is an Act0 product regression

This is not an Act0 product regression.

Evidence:

- `lib/ui_v2/act0_shell/act0_canonical_path_root_v1.dart` returns
  `Act0ShellPreviewScreenV1(showPlacementOnStart: true)`.
- `lib/ui_v2/app_root.dart` delegates the canonical route to
  `buildCanonicalPathRootV1()`.
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart` already covers current
  Home, Learn, Play, Review, runner, retention, repair, placement, and
  completion route behavior.

The failure was a stale test import and stale product owner, not a broken Act0
route.

## 8. Current replacement coverage

Replacement coverage now points at:

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `test/guards/app_root_shell_ownership_contract_test.dart`
- the refreshed R5 critical guard files:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world_campaign_routing_matrix_contract_test.dart`

The refreshed guards assert that R5 still owns critical route coverage while
tracking Act0 as the current canonical route owner.

## 9. Local checks run

Initial focused reproduction:

- `flutter test test/guards/world_campaign_map_home_contract_test.dart --reporter expanded`: failed before fix
- `flutter test test/guards/world_campaign_routing_matrix_contract_test.dart --reporter expanded`: failed before fix

Post-fix focused checks:

- `flutter test test/guards/world_campaign_map_home_contract_test.dart --reporter expanded`: passed
- `flutter test test/guards/world_campaign_routing_matrix_contract_test.dart --reporter expanded`: passed

Broader local checks:

- `flutter analyze`: passed
- `git diff --check`: passed
- `./tools/run_release_gate_r5_v1.sh`: passed
- `./tools/fast_loop_world1_v1.sh`: passed
- `./tools/release_gate_world1.sh`: passed
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`: passed

## 10. GitHub checks after push

Pending until this fix is committed and pushed.

Expected:

- `r5-release-gate` should pass the stale critical contract step that previously
  failed.
- `contract` should remain passed.
- `verify` should remain passed.
- `l2` should remain skipped by policy.
- `TestSprite Pre-Check` may remain red because it is an external/config-level
  status.

## 11. Remaining blockers

Known blocker outside this wave:

- `TestSprite Pre-Check`, external status with no details URL and no local repo
  config found.

## 12. Merge recommendation

Do not merge while required checks are red.

If R5 turns green and only `TestSprite Pre-Check` remains red, PR #1 should be
treated as code-gate ready but blocked by an external required-check/admin
decision.
