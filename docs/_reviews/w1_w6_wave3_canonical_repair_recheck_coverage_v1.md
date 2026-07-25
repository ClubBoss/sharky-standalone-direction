---
status: "w1_w6_wave3_canonical_repair_recheck_coverage_implemented"
status_source: "derived"
baseline: "b188f29d777e"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Wave 3 Canonical Repair/Recheck Coverage v1

Verdict: `w1_w6_wave3_canonical_repair_recheck_coverage_implemented`

Branch: `codex/w1-w6-wave3-canonical-repair-recheck-coverage-v1`

Base: `b188f29d777e72e79333dafb0d60f08fcbe4c2f9`

## Scope Implemented

Wave 3 implements the admitted CAP-006 canonical Act0 repair/recheck coverage
from `docs/_reviews/w1_w6_consolidated_repair_admission_program_v1.md`.

Changed runtime owner:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Added focused proof:

- `test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart`

Updated ledger status only:

- `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`

No JSON Session Drill receipt, session-drill queue, campaign-pack, generic
module-completion, archived runner, Modern Table, scoring, or Human QA closure
logic was modified.

## Prerequisite Family Map

| Family | Source world/lesson/task examples | Mistake signal | Previous outcome | Canonical target admitted | Completion semantics |
| --- | --- | --- | --- | --- | --- |
| W2 hand buckets | `world_2` / `hand_discipline_buckets` / `hand_discipline_buckets_premium`, `strong`, `medium`, `trash`, `borderline` | `starting_hand_read:hero_cards` | Generic hero-card receipt could route backward to W1 first-hand repair. | Same W2 bucket drills in `hand_discipline_buckets`. | Correct repair answer resolves only the source mistake; exact replay remains fallback if target is unavailable. |
| W4 purpose | `world_4` / `why_bets_happen` / `w4_value_purpose`, `w4_bluff_purpose` | `table_read:hero_cards_board_pot` | Generic table-read receipt could route backward to W1 table-read repair. | Peer W4 purpose drill in `why_bets_happen`. | Source task attribution is preserved in the repair intent and retention memory. |
| W4 protection | `world_4` / `protection_and_denial` / `w4_protection_bet`, `w4_protection_check` | `board_read:board_cards` | Generic board receipt could route backward to W1 board-count repair. | Peer W4 protection drill in `protection_and_denial`. | Same as above. |
| W4 price | `world_4` / `call_price` / price call/fold drills | `price_read:pot_to_call` | Generic price receipt could route backward to W1 call repair. | Same W4 price lesson peer drill. | Same as above. |
| W5 board texture | `world_5` / `board_texture_basics` / `w5_dry_board`, `w5_wet_board` | `board_read:board_cards` | Generic board receipt could route backward to W1 board-count repair. | Same W5 texture lesson peer drill. | Same as above. |
| W5 connectedness | `world_5` / `connected_boards` / `w5_disconnected_board`, `w5_connected_board` | `board_read:board_cards` | Generic board receipt could route backward to W1 board-count repair. | Same W5 connectedness lesson peer drill. | Same as above. |
| W6 range buckets | `world_6` / `range_bucket_basics`, `range_board_fit` | `table_read:hero_cards_board_pot` | Generic table-read receipt could route backward to W1 table-read repair. | Same W6 bucket/board-fit target or dedicated `w6_wet_board_repair`. | Same as above; no W7 or capstone target is imported. |
| W6 pressure lines | `world_6` / `range_pressure_lines` / value, bluff, missed action drills | `action_read:no_bet_yet` | Generic action receipt could route backward to W1 check repair. | Same W6 pressure-line peer drill. | Same as above. |

## Mapping and Metadata

The existing public mapper `act0FirstValueSameSignalRepMappingV1` now checks
canonical W2/W4/W5/W6 source task IDs before the older generic W1/W3 fallback
rules. This preserves existing W1/W3 behavior for unknown or legacy source
tasks while admitting same-world targets for the canonical Wave 3 families.

The implementation did not add new runner metadata because the existing
first-value receipt contract already derives a bounded signal from the selected
wrong/suboptimal option and table proof:

- `hero_cards` -> `starting_hand_read`
- `board_cards` -> `board_read`
- `pot_to_call` -> `price_read`
- `no_bet_yet` -> `action_read`
- `hero_cards_board_pot` -> `table_read`

Where no same-world alternate target is launchable, Act0 still uses exact
replay of the source task as the honest fallback.

## CTA Priority and Launchability

The patched mapper feeds both:

- first-value daily rep launch target resolution; and
- open repair intent target resolution.

Open repair intents still resolve through Act0's existing launchability guard:
the target world, lesson, and task must exist in the progressed Act0 state and
the target task must be a drill. Same-signal mapped targets cannot equal the
source task; exact replay is only used through the explicit fallback path.

Existing resolver tests prove active repair intent priority over passive queue
history, deterministic target reuse, and fallback to exact replay when a mapped
target is unavailable.

## Telemetry and Recheck Proof

No telemetry schema was changed. Wave 3 preserves the existing Act0 lifecycle:

1. A wrong/suboptimal answer builds an `Act0RepairIntentV1`.
2. The intent stores source world, source lesson, source task, choice, missed
   signal, skill atom, target world, target lesson, target task, mapping type,
   and reason code.
3. A launchable repair target can be opened from Home/Review/Practice surfaces.
4. Correct repair completion clears only the matching source repair item and
   writes `fixedRecent` retention memory.
5. Retention aging exposes `agedRecheck`.
6. A correct aged recheck emits `recheck_completed` and promotes the memory
   toward `ownedCandidate`.

Focused telemetry coverage passed through the existing Act0 telemetry tests,
including `repair_started`, `repair_completed`, and `recheck_completed`.

## Progression Safety

The repair target mapping does not mark a canonical lesson, world, or generic
module complete. Completion remains owned by the normal Act0 answer path:

- wrong/suboptimal source answers create repair intent and retention memory;
- correct repair answers resolve the source mistake only when the source and
  completed target match the stored intent contract;
- unrelated repair outcomes do not resolve the item;
- normal task completion does not create repair outcomes.

No scoring or 9/10 claim is made from this wave.

## Tests

Added:

- `test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart`

The new test proves:

- W2 bucket misses map to W2 bucket drills, not W1 first-hand repair.
- W4 purpose and price misses map to W4 targets.
- W5 texture misses map to W5 targets, not W1 board-count repair.
- W6 range-bucket and pressure misses map inside W6.
- Unknown source tasks still use the legacy generic fallback.
- Built repair intents preserve source attribution, missed signal, skill atom,
  target world/lesson/task, mapping type, and reason code.

Focused validation:

- `flutter test test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart`:
  9/9 passed.
- Focused repair/recheck regression suite:
  102/102 passed across Wave 3, repair intent contract/lifecycle/resolver,
  queue resolution, Practice repair queue projection, repair outcome
  projection, telemetry sink, and Wave 2 assessment-validity tests.

Observed unrelated existing failure:

- `flutter test test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart`
  fails independently on `sizing confirmation resolves its preset option before
  emitting a completed-decision contract` with `Bad state: No element` at the
  test helper `_task`. That file was not modified by Wave 3 and does not cover
  the patched repair/recheck mapper.

## Deferred Scope

Still deferred:

- Wave 4 W4 purpose-to-size transfer.
- Wave 4 W5 texture-to-action transfer.
- W6 scope/payoff or capstone-depth decisions.
- Canonical-only per-world re-score.
- Fixed-build novice Human QA.
- Any optional/session-drill receipt or queue improvement.

## Integration Status

Integration disposition:
`IMPLEMENTED_PENDING_RE_SCORE_AND_HUMAN_QA`

Minimum next step:
run the canonical-only W1-W6 source re-score gate and then fixed-build novice
Human QA before any W1-W6 9/10 or hard-closure claim.
