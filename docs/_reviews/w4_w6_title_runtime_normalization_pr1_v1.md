# W4-W6 Title/Runtime Normalization PR1 v1

Branch: `codex/w4-w6-title-runtime-normalization-pr1-v1`.
Baseline: `b89b2ec8` (`w4_w6_normalization_ready_with_ssot_cleanup`).

## 1. Verdict

`w4_w6_title_runtime_normalization_pr1_ready`

PR1 implements the minimum safe runtime/title normalization for W4-W6:

- W4 -> Bet Purpose / Price.
- W5 -> Board Awareness.
- W6 -> Range Thinking.

It does not create canonical fixtures, author content, open W7-W12, change
monetization behavior, or make launch/9.0 claims.

## 2. Source truth

Source truth comes from the accepted cascade and normalization artifacts:

- `docs/_reviews/w1_w12_route_content_cascade_map_v1.md`.
- `docs/_reviews/w4_w6_route_content_normalization_plan_v1.md`.

The accepted source map remains:

- W1-W3 baseline is closed.
- Preflop Framework is displaced into W3 bridge-limited source; W3 is not
  reopened.
- W4 source teaches Bet Purpose / Price.
- W5 source teaches Board Awareness.
- W6 source teaches Range Thinking.
- W7-W10 remain locked/read-only.
- W6 remains the terminal gate before W7-W10.

## 3. Accepted normalized contract

| World | Accepted runtime title | Claim status after PR1 |
| --- | --- | --- |
| W4 | Bet Purpose / Price | Runtime/title normalized; bridge-limited until canonical evidence exists. |
| W5 | Board Awareness | Runtime/title normalized; bridge-limited until canonical evidence exists. |
| W6 | Range Thinking | Runtime/title normalized; bridge-limited and still needs range correctness review before any canonical pilot. |

## 4. Implementation surface map

| Surface | Files touched | Why required |
| --- | --- | --- |
| Act0 world card metadata | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | Active runtime title, subtitle, lesson subtitle, and unlock-label truth lived here. |
| Act0 foundation label | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` | Foundation proof rendered W4 from a hard-coded title map. |
| RU localized display copy | `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart` | Localized W4-W6 world titles were title-bound to stale route truth. |
| Monetization route truth | `docs/plan/MONETIZATION_SSOT_v1.md` | Monetization planning used the old W4-W6 labels as active route truth; boundary stayed unchanged. |
| Product attack SSOT | `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` | The normalized W4-W6 ownership note needed to point to PR1 as implemented runtime/title truth. |
| Bridge fixture display titles | `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`, `w5_bridge_or_legacy_schema_migration_pilot_v1.json`, `w6_bridge_or_legacy_schema_migration_pilot_v1.json` | Schema display titles are route-title metadata and must match active route truth. |
| Factory exporter defaults | `tools/content_factory_import_export_mvp_v1.dart` | Prevents regenerated W4-W6 bridge fixtures from restoring stale display titles. |
| Focused tests | `test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`, `test/tools/content_factory_import_export_mvp_v1_test.dart`, `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | Tests prove normalized title truth, W7-W10 lock preservation, exporter defaults, and title-bound UI copy. |
| Readiness / long-horizon ledgers | `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`, `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` | PR1 changed implementation status, small score movement, and the next active wave. |

## 5. Changes made

- Changed active Act0 W4 title to `Bet Purpose / Price`.
- Changed active Act0 W5 title to `Board Awareness`.
- Changed active Act0 W6 title to `Range Thinking`.
- Updated W5/W6/W7 unlock labels so the title chain follows the normalized
  route.
- Updated title-bound lesson subtitles for W4-W6 runtime cards.
- Updated the hard-coded W4 foundation label to `Bet Purpose / Price`.
- Updated RU W4-W6 display titles/subtitles.
- Updated W4-W6 bridge fixture `display_world_title` values only.
- Updated W4-W6 factory exporter defaults so regenerated fixtures preserve the
  normalized display titles.
- Updated title-bound tests and added a focused PR1 regression guard.
- Updated monetization route wording while preserving W1-W4 free and W5+ paid
  depth.

## 6. Bridge preservation

Bridge fixtures were touched only for `display_world_title`.

Preserved fields:

- `source_truth_status: bridge_or_legacy`.
- `safe_claim_status: limited_bridge`.
- `launch_coverage_claimed: false`.
- W4 concept family remains `bet_purpose_price_bridge`.
- W5 concept family remains `board_awareness_bridge`.
- W6 concept family remains `range_thinking_bridge`.

Validator proof:

- Foundation validator passed for W4/W5/W6 bridge fixtures.
- L2/L3 validator reports all three as `route_admission=bridge_or_legacy_limited`.

## 7. W6 terminal gate proof

The focused PR1 regression test asserts that `world_7`, `world_8`, `world_9`,
and `world_10` remain:

- `Act0WorldStateV1.locked`;
- `isLocked == true`;
- `isSelectable == false`.

PR1 changes the W6 title only. It does not open W7-W10, does not mutate W7-W10
source, and does not create W6 canonical evidence.

## 8. Regression guard

New guard:

- `test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`.

It proves:

- W1 title remains `Poker from Zero`.
- W2 title remains `Hand Discipline`.
- W3 title remains `Position Thinking`.
- W4 title is `Bet Purpose / Price`.
- W5 title is `Board Awareness`.
- W6 title is `Range Thinking`.
- W7-W10 remain locked and non-selectable.

Focused stale-label searches over active title/exporter/fixture/test surfaces
found no remaining active `Preflop Framework`, `Bet Purpose And Price`, or
`Board And Draws` route-title assertions.

## 9. Tests / validation

Red checks observed before implementation:

- `flutter test test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`
  failed on `world_4` still being `Preflop Framework`.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W3-W6 bridge schema migration pilots from real source tasks"`
  failed on W4 exporter title still being `Preflop Framework`.
- `flutter test test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
  failed because W4 foundation proof still rendered the old title.

Passing focused checks after implementation:

- `flutter test test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W3-W6 bridge schema migration pilots from real source tasks"`.
- `flutter test test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Worlds route order remains unchanged across Volume I"`.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "World 4 has a real preflop framework spine"`.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "World 5 has a real bet-purpose and price spine"`.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "World 6 has a real board-and-draws spine"`.
- `dart run tools/content_factory_import_export_mvp_v1.dart`.
- `dart run tools/content_schema_foundation_validator_v1.dart` on W4/W5/W6
  bridge fixtures.
- `dart run tools/content_schema_l2_l3_validator_v1.dart` on W4/W5/W6 bridge
  fixtures.

Final Evidence DoD checks are recorded in section 13.

## 10. Score / ledger impact

Score movement is intentionally small:

- W4: `5.3 -> 5.5`.
- W5: `5.3 -> 5.5`.
- W6: `5.1 -> 5.3`.
- W1-W12 readiness: `7.2 -> 7.3`.
- Content depth: `5.6 -> 5.7`.
- Architecture scalability: `8.1 -> 8.2`.

No movement:

- no 8.0 movement;
- no launch movement;
- no Human QA movement;
- no learning-effect movement;
- no monetization readiness movement;
- no overall top-1 readiness movement.

## 11. Route impact

Runtime/title route truth now matches the accepted normalized W4-W6 contract.

Unchanged:

- W1-W3 titles/status.
- W7-W10 locked/read-only status.
- W11-W12 authored-but-not-routed status.
- W13-W36 post-launch status.
- W1-W4 free / W5+ future paid-depth monetization boundary.

## 12. Active repair queue update

Completed:

- `W4-W6 Title/Runtime Normalization Implementation PR1`.

Next recommended wave:

- `W4-W5 Canonical Pilot Batch v1`.

## 13. Evidence DoD status

- `dart format` on touched Dart/test files: pass.
- `flutter test test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`: pass.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W3-W6 bridge schema migration pilots from real source tasks"`: pass.
- `flutter test test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`: pass.
- Focused Act0 route/title regression tests in
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`: pass.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: pass.
- W4-W6 foundation validator: pass.
- W4-W6 L2/L3 validator: pass, with all three fixtures still
  `route_admission=bridge_or_legacy_limited`.
- `flutter analyze`: pass.
- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass before final staging.
- direct ASCII on the new artifact / JSON / new focused test: pass.
- diff-only ASCII excluding the intentional RU localization file: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

No screenshots were taken.

## 14. Anti-theater check

Pass.

This PR normalizes runtime/title metadata and route-title defaults only. It does
not count bridge fixtures as canonical evidence, does not create W4/W5/W6
canonical fixtures, does not open W7-W12, and does not claim launch or 9.0
readiness.

## 15. Next wave decision

`W4-W5 Canonical Pilot Batch v1`
