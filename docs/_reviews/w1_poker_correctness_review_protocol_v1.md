# W1 Poker Correctness Review Protocol v1

Status: ACCEPTED protocol and bounded review artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_poker_correctness_review_conditional_passed`

W1's six schema-backed coverage fixture families have no P0 correctness
blocker. The review found one P1 source-linked bet-size vocabulary boundary
issue: four standalone bet-size source tasks allow broad acceptable preset
alternatives that can weaken strict beginner label recognition. No content was
changed in this wave.

## 2. Source truth

Inspected docs and why:

- `AGENTS.md`: repo scope, route constraints, graphify rules, and validation
  expectations.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W1-W12 launch target,
  claim boundaries, and top-1 strategy constraints.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active route ledger
  and W1 Poker Correctness Review Protocol pointer.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1 score, correctness
  blocker, and scoring constraints.
- `docs/_reviews/w1_8_0_certification_review_v1.md`: accepted W1 8.0
  certification decision and 9.0 blocker list.
- `docs/_reviews/w1_coverage_expansion_pr3_v1.md`: accepted bet-size
  vocabulary and checkpoint synthesis evidence.
- `docs/_reviews/w1_coverage_expansion_pr2_v1.md`: accepted seat-role and
  card-board evidence.
- `docs/_reviews/w1_concept_family_migration_batch1_v1.md`: accepted
  starting-hand discipline evidence.
- `docs/_reviews/w1_world_coverage_expansion_pilot_v1.md`: accepted
  position-action-order pilot evidence.

Inspected validators and fixture authority:

- `tools/content_schema_l2_l3_validator_v1.dart`: explicit
  `w1ContentFactoryCoverageFixturePathsV1` list and L2/L3 route-ready report.
- `tools/content_schema_foundation_validator_v1.dart`: foundation field/value
  validation for W1 factory fixtures.

Inspected W1 intended coverage fixtures:

- `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json`
- `test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w1_bet_size_vocabulary_preview_migration_pr3_v1.json`
- `test/fixtures/content_factory_mvp/w1_checkpoint_synthesis_migration_pr3_v1.json`

Inspected source-linked W1 source files:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_one_third_pot_keep_price.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_half_pot_value.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_min_raise_reopen.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_pot_pressure.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.find_btn.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.tap_flop_right.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.chain_world1_blind_button_intro_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_big_blind_continue_defend_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_button_open_clean_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_small_blind_release_caution_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.find_sb.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.tap_turn.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.chain_world1_action_order_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_call_when_pressure_reaches_you_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_first_in_raise_after_folds_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_fold_when_multiway_pressure_stacks_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.find_bb.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.tap_river.json`
- `content/worlds/world1/v1/sessions/w1.s04/drills/d.chain_world1_position_stability_v1.json`
- `content/worlds/world1/v1/sessions/w1.s04/drills/d.tap_flop_right_repeat.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.chain_world1_start_quality_reinforcement_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_cutoff_raise_clean_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_small_blind_fold_weak_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.tap_turn_repeat.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.chain_world1_mixed_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_raise_clean_first_in_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.tap_river_repeat.json`
- `content/worlds/world1/v1/sessions/w1.s07/drills/d.find_btn_focus.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_big_blind_call_oop_defend_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.find_sb_focus.json`
- `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_fold_when_pressure_and_position_fail_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_raise_when_action_folds_to_you_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s10/drills/d.chain_world1_final_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s10/drills/d.find_btn_focus.json`

## 3. Protocol

Correctness dimensions:

- Correct action safety: the marked answer must be reasonable for
  beginner-level W1 and not depend on thin solver-style assumptions.
- Acceptable action safety: accepted alternatives must not teach a wrong
  beginner default or make a strict label task ambiguous.
- Feedback reason safety: feedback must explain the poker idea correctly and
  avoid overclaiming strategy depth.
- Concept-family safety: the task must belong to the assigned W1 family and
  teach that family rather than a later-world concept.
- Bet-size vocabulary boundary: W1 may preview basic size labels, but must not
  imply advanced sizing strategy, universal sizing rules, or exact exploit
  prescriptions.
- Checkpoint synthesis safety: chain/checkpoint tasks may connect prior W1
  skills, but must not introduce unreviewed advanced concepts.
- Beginner-scope safety: tasks must avoid unexplained jargon, hidden advanced
  logic, and public expert-level claims.
- Claim-safety: W1 can claim beginner foundations only. It cannot claim
  solver-grade, expert-level, or full poker correctness.

Severity levels:

- P0 correctness blocker: clearly wrong poker answer or dangerous training
  advice.
- P1 correctness issue: likely misleading beginner default or materially
  unclear feedback.
- P2 polish/copy issue: wording could improve, but it is not launch-blocking
  for correctness.
- Info: acceptable limitation or future enhancement.

Review rule:

- This protocol can conditionally clear the W1 correctness blocker only when no
  P0 or P1 issue remains in the intended W1 coverage fixture set and
  source-linked meaning.
- Human QA remains separate and cannot be cleared by this protocol.

## 4. W1 fixture coverage under review

| Fixture path | Concept family | Task count | Reviewed in this wave |
| --- | --- | ---: | --- |
| `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json` | `position_action_order` | 6 | Yes |
| `test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json` | `starting_hand_discipline` | 6 | Yes |
| `test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json` | `seat_role_orientation` | 6 | Yes |
| `test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json` | `card_board_orientation` | 6 | Yes |
| `test/fixtures/content_factory_mvp/w1_bet_size_vocabulary_preview_migration_pr3_v1.json` | `bet_size_vocabulary_preview` | 6 | Yes |
| `test/fixtures/content_factory_mvp/w1_checkpoint_synthesis_migration_pr3_v1.json` | `world1_checkpoint_synthesis` | 6 | Yes |

## 5. Correctness matrix

| Concept family | Sample/task coverage reviewed | Correct action safety | Acceptable action safety | Feedback reason safety | Beginner-scope safety | Severity result | Required action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `position_action_order` | Six action-choice tasks: clean first-in opens, facing-open calls, weak-hand folds, and multiway pressure fold. | Safe for W1: raise/call/fold defaults match the stated seat, pressure, and hand-quality frame. | Fixture-level `acceptable_actions` are empty, which keeps single-answer training strict. | Feedback explains seat/pressure before action without advanced claims. | Beginner-safe; no advanced terms beyond basic position, pressure, and action words. | Info | No repair required. Preserve as correctness baseline. |
| `starting_hand_discipline` | Six action-choice tasks: clean suited-ace/broadway opens, weak small-blind/big-blind folds, and broadway big-blind defend. | Safe for W1: actions are reasonable beginner defaults inside the simplified prompt frame. | Fixture-level `acceptable_actions` are empty, so alternatives do not dilute the training default. | Feedback stays on clean start, weak offsuit release, and simple defend. | Beginner-safe, though later human QA should check whether `defend` and `dominated` language is understood. | Info | No repair required before Human QA. |
| `seat_role_orientation` | Six seat-tap tasks: BTN, SB, and BB role identification across W1 sessions. | Safe: role answers match the prompts. | No alternative answers are present or needed. | Feedback is generic but correct: find role before action selection. | Beginner-safe; poker concept is table orientation, not strategy. | P2 | Optional later copy polish can make role feedback less generic. Not a correctness blocker. |
| `card_board_orientation` | Six board-slot tap tasks: flop-right, turn, and river slot identification. | Safe: board-slot answers match the prompts. | No alternative answers are present or needed. | Feedback correctly frames board-slot identification before action decisions. | Beginner-safe; no advanced board texture or range logic. | Info | No repair required. |
| `bet_size_vocabulary_preview` | Six fixture tasks plus source-linked standalone and chain size prompts. | Fixture `correct_action` values are safe as label recognition: `one_third_pot`, `half_pot`, `min_raise`, and `pot`. | P1 issue: standalone source tasks accept broad alternatives such as `half_pot` for `min_raise` and `pot` prompts, which can weaken strict vocabulary recognition. The migrated fixture currently flattens acceptable actions to empty. | Fixture feedback mostly stays preview/basic, but two standalone reasons drift toward strategic effect language such as getting paid or creating pressure. | Conditional: safe only if W1 remains a vocabulary preview and the broad source alternatives are repaired or explicitly excluded from correctness claims. | P1 | Run a narrow `W1 Bet-Size Vocabulary Correctness Repair` before correctness can be cleared for the 9.0 path. |
| `world1_checkpoint_synthesis` | Six chain-root checkpoint tasks linked to blind/button, action order, position stability, start quality, mixed checkpoint, and final checkpoint chains. | Safe: `complete_chain` is a schema marker for existing W1 chains, not a poker action answer. | No alternative action issue at fixture level. | Feedback connects seat, pressure, and hand quality without new strategy. | Beginner-safe; no advanced content introduced by the fixture summaries. | Info | No repair required. Human QA should later test whether chain synthesis feels understandable. |

## 6. Bet-size vocabulary boundary

Classification:

`conditional_preview_basic_with_p1_source_acceptance_repair_needed`

The W1 fixture layer keeps bet-size vocabulary as basic label recognition. The
fixture tasks have strict `correct_action` values and empty
`acceptable_actions`, so the schema-backed fixture does not itself accept
multiple answers.

The source-linked standalone bet-size files still carry broad
`acceptable_preset_ids`:

- `choose_one_third_pot_keep_price`: expected `one_third_pot`, acceptable
  `half_pot`.
- `choose_half_pot_value`: expected `half_pot`, acceptable `one_third_pot`.
- `choose_min_raise_reopen`: expected `min_raise`, acceptable `half_pot`.
- `choose_pot_pressure`: expected `pot`, acceptable `half_pot`.

This is acceptable as a future nuanced sizing conversation, but too broad for
the current W1 correctness claim when prompts ask for the smaller size, the
smallest legal raise, or the most pressure. The safe repair is narrow: tighten
or document source acceptable presets for W1 preview tasks so label recognition
does not teach that a different size is equally correct when the prompt asks
for a strict label.

No solver, GTO, or advanced sizing claim is supported.

## 7. Checkpoint synthesis boundary

Classification:

`safe_w1_synthesis_no_overreach_found`

The checkpoint fixture uses `complete_chain` as a schema marker and summarizes
existing W1 chains. The source-linked chain roots connect:

- seat and blind/button recognition;
- action-order recognition;
- repeated position stability;
- clean-start and weak-hand release;
- mixed seat, pressure, and hand-quality decisions;
- final W1 frame of seat -> pressure -> hand quality -> action.

No checkpoint source reviewed in this wave introduces advanced concepts beyond
W1's beginner seat, pressure, hand-quality, and basic action frame.

## 8. Findings

P0:

- None found.

P1:

- Bet-size vocabulary source acceptable alternatives are too broad for strict
  W1 label-recognition prompts. This affects source-linked correctness
  confidence for `bet_size_vocabulary_preview`, even though the migrated W1
  fixture currently has empty `acceptable_actions`.

P2:

- Seat-role fixture feedback is correct but generic. It can be polished later
  to name BTN/SB/BB orientation more directly.
- Some bet-size feedback phrases are strategy-adjacent. They remain acceptable
  only under the preview/basic boundary and should be tightened in the narrow
  repair wave.

Info:

- Position-action-order, starting-hand discipline, card/board orientation, and
  checkpoint synthesis have no P0/P1 correctness blocker in this bounded pass.
- Starting-hand discipline remains simplified by design. Later human QA should
  check whether words like `defend`, `pressure`, and `dominated` are understood
  by novices.

## 9. W1 9.0 implication

Correctness remains a blocker for the W1 9.0 path.

Reason:

- No P0 issue was found.
- One P1 source-linked bet-size vocabulary boundary issue remains.
- W1 should not proceed directly to Human QA Protocol as a correctness-cleared
  candidate until the bet-size preview acceptable-preset boundary is repaired
  or explicitly scoped out of the W1 9.0 correctness claim.

Next required wave:

`W1 Bet-Size Vocabulary Correctness Repair`

## 10. Ledger impact

- W1 score remains `8.0`.
- No score movement is proposed.
- W1 correctness status should move from unreviewed to conditional with one P1
  source-linked bet-size boundary issue.
- W1 should not move to 9.0 without:
  - narrow bet-size vocabulary correctness repair;
  - human novice QA;
  - payoff/progression proof.
- W1-W12 Volume I Premium Product Readiness remains `6.2`.
- Overall Top-1 Readiness remains `6.0`.
- Learning effect remains `6.0`.
- Monetization readiness remains `2.0`.

## 11. Route impact

- No route changes.
- No learner-facing title changes.
- W2-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed according to current route truth.
- W13-W36 remain deferred/post-launch.

## 12. Active repair queue update

Closed:

- W1 Poker Correctness Review Protocol v1.
- Bounded correctness review over six W1 intended coverage fixtures.
- Position/action, starting-hand, seat-role, card/board, and checkpoint
  correctness classification for this review pass.

Active:

- W1 Bet-Size Vocabulary Correctness Repair.

Must-not-skip:

- Preserve W1 as an 8.0 candidate, not launch-ready.
- Repair bet-size source acceptable-preset boundary before declaring W1
  correctness cleared for Human QA.
- Keep Human QA Protocol as a separate future gate.
- Keep payoff/progression proof as a separate future gate.
- Keep route and claim safety unchanged.

Deferred:

- Human QA execution.
- W1 payoff/progression certification.
- W2-W6 canonical realignment.
- W7-W12 admission.
- W13-W36 expansion.
- Monetization, telemetry, UI, Modern Table, screenshots, store/public beta,
  solver/GTO claims, and external dependencies.

Blockers:

- P1 bet-size vocabulary source acceptable-preset boundary.
- Human novice QA remains unrun.
- Payoff/progression proof remains incomplete.

## 13. Evidence DoD status

Completed before final close:

- `dart run tools/content_schema_l2_l3_validator_v1.dart` over intended W1
  coverage fixtures.
- `dart run tools/content_schema_foundation_validator_v1.dart` over W1 factory
  fixtures.
- `graphify hook-check`.
- `git diff --check`.
- Direct ASCII check.
- Direct trailing-whitespace/CRLF check.

No tooling or Dart test changes were made, so `dart format`, focused Flutter
tests, and `flutter analyze` are not required for this docs-only review wave.

## 14. Anti-theater check

What risk moved?

- W1 poker correctness risk moved from unreviewed to bounded conditional
  review with no P0 and one P1 source-linked bet-size boundary issue.

What did not move?

- W1 did not become 9.0, 10.0, launch-ready, human-QA-passed, payoff-certified,
  route-expanded, monetized, or externally claimable as expert-correct.

Is this docs-only or review-backed?

- This is docs-only and review-backed by the six W1 intended coverage fixtures,
  their source-linked W1 files, and existing validator evidence.

Did this change content?

- No. No source JSON, fixture JSON, product code, tests, routes, UI, telemetry,
  or monetization files were changed.

Does this clear correctness for Human QA, or require repair?

- It requires repair. The next safe step is `W1 Bet-Size Vocabulary Correctness
  Repair` before W1 can proceed as correctness-cleared into Human QA Protocol.
