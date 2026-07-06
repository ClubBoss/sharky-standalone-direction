# Stage 1B Wave C — W6 Proxy-Context and Independent Decision Clarity v1

Status: stage_1b_wave_c_closed

Branch: `codex/stage-1b-wave-c-w6-proxy-context-clarity-v1`

Base HEAD: `1cfe6a12a71cd025ce009273699c4ba896a65439`

## Scope

Wave C repaired only the six verified W6 action-choice rows classified as insufficient-context proxy/template rows. No new drills were added, no expected action changed, no acceptable action tier was added, no stable ID changed, and no W4/W5/W7+ content was modified.

## Exact six target rows

| Session | File | Stable ID | Expected action | Context change |
| --- | --- | --- | --- | --- |
| `w6.s01` | `content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_call_range.json` | `choose_call_range` | `call` | Prompt now names UTG, `AsKd`, `Kh-8d-3c-2s`, BB check, position, and medium range edge; feedback/why now explain controlled realization. |
| `w6.s01` | `content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_raise_range.json` | `choose_raise_range` | `raise` | Prompt now names UTG, `AsKd`, `Kh-8d-3c-2s`, BB checks twice, board fit, and pressure against weaker continues; feedback/why now explain pressure from board fit plus range edge. |
| `w6.s01` | `content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_fold_trap.json` | `choose_fold_trap` | `fold` | Prompt now names UTG, `AsKd`, `Kh-8d-3c-2s`, BB pressure, one-pair thinness, and the stronger pressure range; feedback/why now explain why continuing overpays. |
| `w6.s03` | `content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_call_realize.json` | `choose_call_realize` | `call` | Prompt now names UTG, `QsTc`, `Jd-7c-3h-2s`, BB turn check, live equity, and medium range edge; feedback/why now explain controlled realization. |
| `w6.s03` | `content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_raise_range.json` | `choose_raise_range` | `raise` | Prompt now names UTG, `QsTc`, `Jd-7c-3h-2s`, BB check, nut advantage, board fit, and pressure against weaker continues; feedback/why now explain the cleaner range story. |
| `w6.s03` | `content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_fold_trap.json` | `choose_fold_trap` | `fold` | Prompt now names UTG, `QsTc`, `Jd-7c-3h-2s`, BB river pressure, one blocker, completed board, and villain range advantage; feedback/why now explain why continuing overpays. |

## Before / after prompt examples

### `w6.s01` call row

Before: `Range proxy: choose the best action, not a single-hand snap raise.`

After: `UTG holds AsKd on Kh-8d-3c-2s in position after BB checks. Hero has a medium range edge, but the board is not enough for clean pressure. Choose the best action.`

### `w6.s03` fold row

Before: `Trap: single-hand attachment loses to range logic here, choose fold.`

After: `UTG holds QsTc on Jd-7c-3h-2s facing river pressure from BB. One blocker is tempting, but the completed board favors villain's stronger range. Choose the best action.`

## Poker rationale

The repaired rows no longer ask the learner to infer the answer from labels like proxy, trap, realize, or range-first. Each row now exposes at least two concrete beginner-facing signals:

- board/cards from the active W6 session projection defaults;
- position or opponent seat;
- street/action-history pressure;
- range edge, board fit, nut advantage, live-equity realization, or blocker thinness.

The wording stays inside beginner simplification. It does not claim solver precision, mandatory absolutes, stack/rake dependencies, or hidden mixed-strategy thresholds.

## Invariance proof

- Expected actions unchanged: `call`, `raise`, `fold`, `call`, `raise`, `fold`.
- Stable IDs unchanged: all six IDs match their pre-Wave C values.
- Drill kind unchanged: all six remain `action_choice`.
- Options unchanged: no `available_actions_v1` was added or changed.
- Acceptable tiers unchanged: no `acceptable_actions_v1` or `acceptable` tier was added.
- Session order/manifests unchanged.
- No new W6 drills added.

The bounded diff script verified that the only `content/worlds/` changes are the six target W6 drill JSON files.

## Prompt / context / feedback / why synchronization

For each row, the prompt names the decisive context, and `why_v1`, `feedback_correct_v1`, and `feedback_incorrect_v1` reuse the same action logic:

- call rows: live/medium edge plus control/realization;
- raise rows: board fit or nut/range edge plus pressure on weaker continues;
- fold rows: one-pair/blocker temptation loses to pressure/range/board completion, so continuing overpays.

The focused Wave C guard locks these synchronization terms and rejects the original proxy-only prompt fragments.

## W6 campaign guard correction

Classification: stale test expectation, current production truth authoritative.

The guard previously expected:

- `Next route`
- `World 6 sessions`
- `Why: Your next learning route is World 6 sessions.`

Current production copy for the W6 stage shift is:

- `What changes now`
- `Build Range Thinking from board-aware pressure and likely hand groups`
- `Why: World 5 trained Board Awareness before action. World 6 now introduces Range Thinking by connecting board-aware pressure to likely hand groups.`

The guard was updated to the production copy while preserving the routing assertion that the deterministic next pack is `world6_spine_campaign_v1`.

## Excluded families

Wave C did not modify:

- W4/W5 content;
- W6 range-bucket classifier rows;
- W6 clear binary rows outside the exact six targets;
- route/progression implementation;
- manifests;
- repair mappings;
- telemetry;
- Modern Table;
- assets;
- W7+ content.

## Validation

Passed:

- JSON syntax validation for the six changed drills.
- `DrillSpecV1.fromJsonString` schema parsing for the six changed drills.
- `flutter test test/guards/stage1b_wave_c_w6_proxy_context_clarity_contract_test.dart`
- `flutter test test/guards/world6_campaign_routing_contract_test.dart`
- `flutter test test/guards/world6_range_action_anchor_integrity_contract_test.dart`
- `flutter test test/guards/world6_range_bucket_runtime_truth_contract_test.dart`
- `flutter test test/tools/drill_runtime_evaluator_v1_test.dart`
- `flutter test test/ui_v2/runner/session_drill_spatial_projection_contract_v1_test.dart`
- `flutter test test/services/session_drill_projection_truth_invariant_spine_v1_test.dart`
- `flutter test test/services/session_drill_projection_truth_reconciliation_v1_test.dart`
- `flutter test test/ui_v2/runner/session_drill_canonical_spatial_scenario_state_v1_test.dart`
- `flutter analyze test/guards/stage1b_wave_c_w6_proxy_context_clarity_contract_test.dart test/guards/world6_campaign_routing_contract_test.dart`
- Bounded diff script: exactly six W6 drill files changed; no expected actions/options/stable IDs changed; no new W6 files; no W4/W5/W7+ content changed.

Known unrelated harness failures:

- `flutter test test/ui_v2/session_drill_player_spatial_runtime_bundle_contract_test.dart` does not compile because it imports missing `lib/ui_v2/screens/modern_table_screen_v1.dart` and `lib/ui_v2/screens/session_drill_player_v1_screen.dart`.
- `flutter test test/ui_v2/session_drill_player_world6_surface_contract_test.dart` does not compile because it imports missing `lib/ui_v2/screens/session_drill_player_v1_screen.dart`.
- `flutter test test/guards/session_drill_projection_truth_invariant_spine_contract_test.dart` fails before assertion because it reads missing `lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart`.

## Rendered table projection evidence

The six target rows did not add or alter table metadata fields. The prompt card/board references align with the existing shared W6 spatial projection defaults for `w6.s01` and `w6.s03`. Runner-level and service-level projection contracts passed. Direct rendered player projection tests remain blocked by pre-existing missing imported files listed above.

## Wave D admission

Wave D is not started in this branch.

Wave D admission status: stage_1b_wave_d_admitted_after_wave_c_review.
