---
status: "stage_1b_wave_c_render_mismatch_repaired"
status_source: "derived"
baseline: "1cfe6a12a71c"
generated_by: "docs_frontmatter_v1"
---

# Stage 1B Wave C — W6 Proxy-Context and Independent Decision Clarity v1

Status: stage_1b_wave_c_render_mismatch_repaired

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
  - includes one source-driven merge/resolver test;
  - includes six active surfaced-runner / Modern Table projection tests.
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
- Render-truth bounded diff: only prompt/feedback/why changed in the six
  admitted JSON rows; expected actions, options, acceptable tiers, kinds, and
  stable IDs remain byte-equivalent to pre-verification HEAD
  `60c8baefc964ba31d9ee48d4a180816802cb7306`.

Known unrelated harness failures:

- `flutter test test/ui_v2/session_drill_player_spatial_runtime_bundle_contract_test.dart` does not compile because it imports missing `lib/ui_v2/screens/modern_table_screen_v1.dart` and `lib/ui_v2/screens/session_drill_player_v1_screen.dart`.
- `flutter test test/ui_v2/session_drill_player_world6_surface_contract_test.dart` does not compile because it imports missing `lib/ui_v2/screens/session_drill_player_v1_screen.dart`.
- `flutter test test/guards/session_drill_projection_truth_invariant_spine_contract_test.dart` fails before assertion because it reads missing `lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart`.
- `flutter test test/guards/session_drill_canonical_launcher_cutover_contract_test.dart`
  fails before assertion because it reads removed
  `lib/ui_v2/screens/session_drill_player_v1_screen.dart`.
- `flutter test test/guards/canonical_terminal_session_drill_dispatch_contract_test.dart`
  fails before assertion because it reads the pre-archive surfaced-runner path.

## Rendered table projection evidence

The runtime path is:

1. `CanonicalLauncherV1.sessionDrill`
2. `CanonicalTerminalRunnerSurfaceV1`
3. active `CanonicalTerminalSessionDrillSurfacedRunnerV1`
4. `DrillRuntimeAdapterV1`
5. `mergeSessionDrillProjectionDefaultsIntoDrillJsonV1`
6. `resolveSessionDrillCanonicalSpatialScenarioStateV1`
7. embedded `ModernTableScreenV1`

`DrillRuntimeAdapterV1` merges the session entry from
`content/worlds/world6/v1/sessions/spatial_projection_defaults_v1.json`
before `DrillSpecV1` parsing. For both `w6.s01` and `w6.s03`, the merged
fields are:

- `hero_seat_v1: utg`
- `villain_seat_v1: bb`
- `player_count_v1: 7`
- `active_seats_v1: btn, co, hj, lj, utg, sb, bb`
- session-specific `hero_hole_cards_v1`
- session-specific `board_cards_v1`

The surfaced runner renders hero cards and board cards from this merged state,
labels seat index 4 as `HERO` / `UTG`, labels seat index 6 as `VILLAIN` /
`BB`, and derives `Street.turn` from the four-card board. Prior actions such
as `BB checks`, `BB checks twice`, or `BB pressure` have no separate
structured field and are not independently rendered. They remain
prompt-authored context, but no final prompt contradicts the visible table.

## Render-truth verification matrix

| Session / ID | Exact final prompt | Structured source | Surfaced state | Prior action | Classification | Hero identity |
| --- | --- | --- | --- | --- | --- | --- |
| `w6.s01/choose_call_range` | `Hero is UTG with AsKd on Kh-8d-3c-2s, in position after BB checks. Hero has a medium range edge, but the board is not enough for clean pressure. Choose the best action.` | Defaults: Hero `utg`, villain `bb`, `As Kd`, `Kh 8d 3c 2s`; target JSON: `expected.actionId=call`; street derived as turn. | Hero cards, four-card board, UTG/BB, HERO/VILLAIN, and turn all match. | Prompt-only `BB checks`; not separately rendered and not conflicting. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |
| `w6.s01/choose_raise_range` | `Hero is UTG with AsKd on Kh-8d-3c-2s after BB checks twice. Hero's top-pair range keeps the better board fit and can pressure weaker continues to fold. Choose the best action.` | Same `w6.s01` defaults; target JSON: `expected.actionId=raise`; street derived as turn. | Hero cards, board, positions, identities, and turn match. | Prompt-only `BB checks twice`; compatible with a four-card turn state. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |
| `w6.s01/choose_fold_trap` | `Hero is UTG with one pair from AsKd on Kh-8d-3c-2s, but BB pressure represents the stronger range after the turn. The hand is tempting, not secure. Choose the best action.` | Same `w6.s01` defaults; target JSON: `expected.actionId=fold`; street derived as turn. | Hero cards, board, positions, identities, and turn match. | Prompt-only BB pressure; not separately rendered and not conflicting. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |
| `w6.s03/choose_call_realize` | `Hero is UTG with QsTc on Jd-7c-3h-2s after BB checks the turn. Hero has live equity and a medium range edge, but not enough pressure to build the pot. Choose the best action.` | Defaults: Hero `utg`, villain `bb`, `Qs Tc`, `Jd 7c 3h 2s`; target JSON: `expected.actionId=call`; street derived as turn. | Hero cards, four-card board, UTG/BB, HERO/VILLAIN, and turn all match. | Prompt-only `BB checks the turn`; street reference matches projected turn. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |
| `w6.s03/choose_raise_range` | `Hero is UTG with QsTc on Jd-7c-3h-2s after BB checks. Hero's nut advantage and board fit can pressure weaker continues. Choose the best action.` | Same `w6.s03` defaults; target JSON: `expected.actionId=raise`; street derived as turn. | Hero cards, board, positions, identities, and turn match. | Prompt-only `BB checks`; not separately rendered and not conflicting. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |
| `w6.s03/choose_fold_trap` | `Hero is UTG with QsTc on Jd-7c-3h-2s facing turn pressure from BB. One blocker is tempting, but the turn board favors villain's stronger range. Choose the best action.` | Same `w6.s03` defaults; target JSON: `expected.actionId=fold`; street derived as turn. | Hero cards, board, positions, identities, and turn match after correction. | Prompt-only turn pressure; not separately rendered and not conflicting. | `prompt_only_context_but_no_conflicting_visual_state` | Explicit and unambiguous. |

## Render-truth correction

Before this verification, `w6.s03/choose_fold_trap` said `river pressure` and
`completed board`, while the authoritative merged state contained four board
cards and projected `Street.turn`. Classification before correction:
`prompt_visual_state_mismatch_confirmed`.

The prompt, `why_v1`, correct feedback, and incorrect feedback were corrected
to turn-board language. No structured state, expected action, options, stable
ID, or poker ownership changed.

All six prompts were also tightened from inferable identity such as
`UTG holds ... Hero ...` to explicit `Hero is UTG ...`. The table independently
renders the same seat as both `HERO` and `UTG`.

The focused Wave C guard now:

- loads the real projection-default source;
- applies the runtime merge function;
- parses the merged `DrillSpecV1`;
- resolves the canonical spatial state;
- verifies prompt cards, board, seats, projected street, feedback, why, and
  expected-action invariance;
- pumps the active surfaced runner for each row;
- verifies the `ModernTableScreenV1` hero cards, board cards, street,
  HERO/VILLAIN badges, and UTG/BB markers.

Legacy projection tests that import removed paths remain stale and are not
used as active-path evidence.

## Wave D admission

Wave D is not started in this branch.

Wave D admission status:
`stage_1b_wave_d_pending_owner_authorization_after_render_truth_review`.
