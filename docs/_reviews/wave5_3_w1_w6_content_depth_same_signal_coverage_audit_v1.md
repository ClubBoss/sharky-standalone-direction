# Wave 5.3 - W1-W6 Content Depth / Same-Signal Coverage Audit v1

## 1. Verdict

`wave5_3_content_depth_risk_requires_schema_first`

W1-W6 have materially more authored content than a thin prototype, but the
current proof is not clean enough to justify new content authoring before a
schema/factory foundation.

The strongest finding is source-truth drift:

- Act0 world cards and the Master Plan expose W2-W6 as Hand Discipline,
  Position Thinking, Preflop Framework, Bet Purpose And Price, and Board And
  Draws.
- Active `content/worlds/worldN` files map W2-W6 differently: W2 is broad table
  reading, W3 is preflop framework, W4 is bet purpose, W5 is board texture, and
  W6 is range thinking.
- W1-W6 JSON drills have `intent_v1`, `why_v1`, feedback, and tests, but no
  explicit `concept_family_id`, `repair_focus_id`, `same_signal_group_id`, or
  `transfer_surface_id`.

Therefore Wave 5.3 closes as an audit, but Wave 6.1 should normalize schema and
route/content source truth before additional W1-W6 authoring or W5-W12 expansion.

## 2. Source Truth

Focused files inspected:

- `AGENTS.md`: active root, Act0 boundary, graphify policy, no archive default.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: Act0 shell is canonical
  learner-facing runtime truth.
- `docs/plan/MASTER_PLAN_v3.0.md`: content quality bar, minimum density rule,
  W1-W12 first-wave policy, and W1-W6 practical ladder.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Full Top-1 route is active;
  quick public/store route remains paused.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: W1-W6 content depth is
  an active Stage A blocker and Wave 5.3 target.
- `docs/_reviews/wave5_2_w7_w12_route_truth_reconciliation_v1.md`: previous
  route-truth conflict record and Wave 5.3 dependency.
- `docs/_reviews/wave5_2_w7_w10_current_campaign_status_alignment_v1.md`:
  accepted W7-W10 locked-preview follow-up.
- `docs/_reviews/wave5_1_canonical_telemetry_instrumentation_v1.md`: canonical
  local telemetry field state and remaining deterministic `session_id` gap.
- `lib/services/progress_service.dart`: W1-W6 progression route owner and W7-W10
  clamp after Wave 5.2.
- `lib/campaign/campaign_pack_registry_v1.dart`: active W1-W6 campaign/follow-up
  pack registry.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`: Act0 card titles, lock state,
  and lesson-family labels.
- `content/worlds/world1/v1` through `content/worlds/world6/v1`: current W1-W6
  authored source content.
- Focused tests under `test/guards`, `test/tools`, `test/services`, and
  `test/ui_v2` named in the matrices below.

Commands used for evidence:

- `graphify query "W1-W6 content depth same-signal coverage active Act0 route concept_family_id repair_focus_id"`
- `rg` over the required SSOT docs, W1-W6 content, Act0 state, route owners, and
  tests.
- `find` plus `jq` over `content/worlds/world1` through `content/worlds/world6`
  to count sessions, drill kinds, chain steps, intents, feedback fields, and
  missing schema fields.

## 3. Scope and Non-Scope

In scope:

- W1-W6 content-depth audit.
- Same-signal and transfer-variant classification from existing authored files.
- Regression/test evidence classification.
- Wave 6.1 schema/factory implications.

Out of scope and not touched:

- new content authoring;
- poker lesson/task copy edits;
- W5-W6 expansion;
- W7-W12 opening;
- schema/factory implementation;
- UI, monetization, telemetry, analytics, server, Modern Table, or screenshot
  work;
- generated `output/` artifacts.

## 4. Active Route Status After Wave 5.2

Current route truth:

- W1-W6: available/current audit band through `ProgressService` campaign
  progression and W1-W6 registry packs.
- Act0 cards: W1 is selectable/current; W2-W6 are locked cards but have active
  campaign progression ownership.
- W7-W10: `locked_not_learner_playable`; registry/content may exist internally,
  but learner progression clamps to `world6_spine_followup_v1_b2`.
- W11-W12: `authored_but_not_routed`.
- W13-W36: out of scope.

## 5. W1-W6 World Inventory

| World | Title / route-facing claim | Route status | Active content owners | Concept families found | Practice / repair path | Test / guard evidence | Main risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | Poker from Zero | Current Act0 card plus campaign route | `content/worlds/world1/v1`; `world1_act0_*`; `world1_spine_*` | position/action order, start quality, simple raise/call/fold, light size-label preview | intro/session files, 98 drills, 10 chains, 31 chain steps, follow-up packs, Act0 repair surfaces | many W1 guards; `world1_scenario_truth_pilot_contract_test.dart`; `world1_foundations_microtask_packs_contract_test.dart`; telemetry tests | Coverage is broad, but concept fields are implicit and some bet-size preview belongs later. |
| W2 | Act0 says Hand Discipline; content says table-reading bridge | Campaign route | `content/worlds/world2/v1`; `world2_spine_*` | showdown, position, initiative, board texture, outs, price/action | 14 sessions, 111 drills, 8 chains, 23 chain steps, bridge/review drills | `world2_campaign_routing_contract_test.dart`; board/seat/initiative/outs validator tests; `session_drill_player_world2_*` tests | `blocked_by_source_truth`: route title and content ownership do not match cleanly. |
| W3 | Act0 says Position Thinking; content says Preflop Framework | Campaign route | `content/worlds/world3/v1`; `world3_spine_*` | preflop categories, open/call/fold, position-sensitive preflop, same hand different action | 14 sessions, 18 files, 14 chains, 42 chain steps | `world3_campaign_routing_contract_test.dart`; `world3_preflop_hand_chain_validator_convergence_test.dart`; rendered slice tests | Strong chain arc, but route-facing title is offset from content source truth. |
| W4 | Act0 says Preflop Framework; content says Bet Purpose And Price | Campaign route | `content/worlds/world4/v1`; `world4_spine_*` | value, denial, protection, bluff, size/price presets, action anchors | 10 sessions, 123 drills, 3 chains, 11 chain steps, 40 bet-size files | `world4_campaign_routing_contract_test.dart`; `world4_intent_normalization_v1_test.dart` | Coverage-ready cluster is housed under a route label that says preflop. |
| W5 | Act0 says Bet Purpose And Price; content says Board Awareness | Campaign route | `content/worlds/world5/v1`; `world5_spine_*` | dry/wet/paired/connected boards, turn/river shifts, blocker context, texture-to-action | 10 sessions, 41 drills, 8 chains, 24 chain steps | `world5_campaign_routing_contract_test.dart`; `world5_early_runtime_truth_contract_test.dart`; `w5_board_texture_same_signal_coverage_v1_test.dart` | Coherent same-signal board coverage, but it sits under the route-facing W5 bet-purpose title. |
| W6 | Act0 says Board And Draws; content says Range Thinking | Campaign route terminal before W7-W10 lock | `content/worlds/world6/v1`; `world6_spine_*` | range buckets, range-vs-hand, equity realization, blockers, range/board transition | 10 sessions, 92 drills, 6 chains, 17 chain steps | `world6_campaign_routing_contract_test.dart`; `world6_range_bucket_runtime_truth_contract_test.dart`; `session_drill_player_range_bucket_contract_test.dart`; Wave 5.2 W7-W10 clamp guard | Authored cluster is real, but W6 route-facing claim is Board And Draws while content source owns range thinking. |

## 6. Concept-Family Coverage Matrix

Audit threshold used:

- 1-2 reps: `single_spot_illusion` or thin.
- 3-4 reps: partial but fragile.
- 5-7 reps: usable but not strong.
- 8+ reps: `coverage_ready` candidate, unless source truth or missing schema
  blocks the claim.

| World | Concept family | Source IDs / task IDs | Authored decision reps | Same-signal variants | Different-surface transfer variants | Repair path present | Misconception feedback | Regression lock | Coverage status | Risk | Recommended next action |
| --- | --- | --- | ---: | ---: | ---: | --- | --- | --- | --- | --- | --- |
| W1 | Position and action order | `w1.s01-w1.s10`; `chain_world1_*`; `choose_*position*`; `find_btn`, `find_bb`, `find_sb` | 50 action choices + 31 chain steps | 10+ | seat taps, chain decisions, action choices | Partial via follow-up packs and Act0 repair surfaces | Yes in 37 incorrect-feedback files | Strong W1 guard set | `coverage_ready` | Implicit schema only | Add `concept_family_id=position_action_order` and same-signal groups in Wave 6.1. |
| W1 | Starting-hand discipline | `choose_fold_*`, `choose_call_*`, `choose_raise_*`; intents `hand_discipline_fold`, `dominated_aces`, `trash_hands` | 50 action choices + chain steps | 8+ | unopened, facing open, in-position, OOP, blind spots | Partial | Yes | Strong W1 guard set | `coverage_ready` | Concept family is implied by filename/intent, not canonical field | Schema pilot can safely start here after field contract exists. |
| W1 | Bet-size vocabulary preview | `choose_half_pot_value`, `choose_one_third_pot_keep_price`, `choose_pot_pressure`, `choose_min_raise_reopen` | 4 | 4 | size buttons only | No dedicated repair path | Yes | General W1/W4 tests, not W1 size-specific | `not_active_route_relevant` | Preview can blur W4 ownership | Keep as vocabulary preview; do not expand before schema labels it as preview. |
| W2 | Showdown / visible table truth | `showdown_winner_choice_v1`; `choose_*showdown*`; `review_showdown_hero_top_pair` | 4 direct showdown classifiers plus action branches | 4-6 | classifier, action, review | Partial via review drills | Yes in every W2 JSON file | `session_drill_player_world2_*`; validator tests | `thin_coverage` | Too few direct showdown classifiers for a route claim if W2 is Hand Discipline | Clarify whether W2 owns table truth or Hand Discipline before authoring. |
| W2 | Position thinking | `position_thinking_choice_v1`; `choose_hero_in_position_btn_vs_bb`; `choose_villain_acts_later_co_vs_btn` | 4 direct classifiers plus action branches | 5+ | seat taps, classifiers, chains | Partial | Yes | position validator and rendered tests | `blocked_by_source_truth` | W2 content teaches position while Act0 labels W3 as Position Thinking | Move/label through schema before new content. |
| W2 | Initiative / pressure | `initiative_aggressor_choice_v1`; `choose_hero_has_initiative_open_vs_call`; `review_initiative_*` | 4 direct classifiers plus action branches | 5+ | classifier, review, action choices | Partial | Yes | initiative validator/tests | `blocked_by_source_truth` | Concept is route-relevant but not cleanly housed in W2 title | Schema-first; maybe keep as table-reading bridge if route labels change. |
| W2 | Board texture / outs / price bridge | `board_texture_classifier_v1`, `outs_count_choice_v1`, `chain_texture_*`, bridge review drills | 4 texture + 3 outs + chain/action branches | 7+ | classifier, board tap, chains, action choices | Partial | Yes | board texture/outs tests | `thin_coverage` | Strong as bridge, weak as full Board And Draws claim | Mark as bridge-only unless W5/W6 source truth is normalized. |
| W3 | Preflop framework | `w3.s01-w3.s14`; `chain_preflop_*`; checkpoint action choices | 42 chain steps + 4 direct actions | 14 chain files | chain steps across open/call/fold and position contexts | Partial via recap chains | Yes in all 18 files | `world3_preflop_hand_chain_validator_convergence_test.dart`; W3 rendered tests | `coverage_ready` as content, `blocked_by_source_truth` as route label | Align W3 route-facing title or content mapping before authoring. |
| W3 | Same hand / different action transfer | `chain_preflop_same_hand_different_action_v1`; `chain_position_*` | 12+ chain steps in tail/transfer chains | 4+ | same hand under changed action/position frame | Partial | Yes | W3 chain validator | `usable_but_fragile` | Transfer exists but is chain-implicit, not fielded | Add `same_signal_group_id` and `transfer_surface_id`. |
| W4 | Bet purpose and price | `w4.s01-w4.s10`; 40 `bet_sizing_choice_v1`; value/denial/protection/bluff intents | 40 size choices + 33 actions + chain steps | 8+ per major intent family in aggregate | size buttons, action choices, anchors, chains | Partial | Yes in 83 feedback files | `world4_intent_normalization_v1_test.dart`; W4 route guard | `coverage_ready` as content, `blocked_by_source_truth` as route label | Use as schema pilot for purpose/price once W4/W5 route labels are normalized. |
| W4 | Action intent before size | `choose_raise_value`, `choose_raise_denial`, `choose_call_control`, `choose_fold_release`, chains | 33 action choices + 11 chain steps | 8+ | action choice plus size choice | Partial | Yes | W4 tests | `coverage_ready` | Route says Preflop Framework, not bet purpose | Schema-first, then decide whether title/content moves. |
| W5 | Board texture recognition | `w5.s01-w5.s10`; 33 `board_texture_classifier_v1`; dry/wet/paired/connected IDs | 33 classifiers + 24 chain steps | 8+ | classifier, chains, turn/river contexts | Partial via recap chains | Yes in all 41 files | `w5_board_texture_same_signal_coverage_v1_test.dart`; W5 route guard | `coverage_ready` as content, `blocked_by_source_truth` as route label | Candidate for schema pilot after W5 route title is reconciled. |
| W5 | Texture-to-action transfer | `classify_*_raise/call/fold`; `chain_world5_*` | 57 decisions including chain steps | 8+ | dry, wet, connected, paired, OOP/IP, turn/river | Partial | Yes | W5 tests | `coverage_ready` | Same-signal is filename-derived, not schema-owned | Add same-signal and transfer-surface fields. |
| W6 | Range buckets | `range_bucket_classifier_v1`; `classify_strong_raise`, `classify_missed_fold`, `classify_medium_call_control` | 6 classifiers + action branches | 6 | classifier plus action-bar runtime | Partial | Yes | `world6_range_bucket_runtime_truth_contract_test.dart`; range player test | `usable_but_fragile` | Only 6 direct classifiers; route says Board And Draws | Schema pilot candidate after route-title normalization. |
| W6 | Range-vs-hand / equity realization / blockers | intents `think_in_ranges`, `range_vs_hand`, `equity_realization`, `blockers_basics`; `chain_world6_*` | 22 actions + 17 chain steps | 8+ in aggregate | seat/hole/board taps, action choices, chains | Partial | Yes in all 92 files | W6 route/range tests; Wave 5.2 terminal clamp | `coverage_ready` as content, `blocked_by_source_truth` as route label | Do not author more until schema records range as W6-owned or route labels move. |

## 7. Same-Signal Coverage Findings

### coverage_ready

- W1 position/action-order and starting-hand discipline: enough authored
  raise/call/fold variants across positions, pressure states, and chains.
- W3 preflop framework content cluster: 14 chain files and 42 chain steps create
  a strong repeated open/call/fold arc.
- W4 bet purpose/price content cluster: 40 bet-sizing choices plus action
  anchors cover value, denial, protection, and bluff.
- W5 board-texture content cluster: 33 classifiers plus eight recap/checkpoint
  chains cover dry, wet, paired, connected, turn/river, and synthesis variants.
- W6 range/action aggregate: range, equity realization, blockers, and board-fit
  decisions have broad authored reps.

### usable_but_fragile

- W3 same-hand-different-action transfer exists, but only as chain/file naming.
- W6 direct range-bucket classifiers have six direct files, with broader support
  from action and anchor drills.

### thin_coverage

- W2 direct showdown classifiers and direct outs classifiers are too few to
  carry standalone world claims.
- W2 board texture/outs/price is better understood as a bridge than as full
  board/draws mastery.

### single_spot_illusion

- No major W1-W6 family is literally one spot only, but W1 bet-size vocabulary
  preview is only four reps and should not be promoted as bet-purpose mastery.

### route_claim_without_reps

- Act0 W2 Hand Discipline, W3 Position Thinking, W4 Preflop Framework, W5 Bet
  Purpose And Price, and W6 Board And Draws do not map cleanly to the matching
  `content/worlds/worldN` ownership.

### missing_repair_path

- All worlds have feedback and follow-up/recap patterns, but no W1-W6 JSON drill
  carries `repair_focus_id`.
- Repair path is therefore runtime/route-derived, not source-owned content truth.

### blocked_by_source_truth

- W2-W6 route labels and content files are offset enough that new authoring
  would likely deepen drift.
- No W1-W6 source JSON contains `concept_family_id`, `same_signal_group_id`, or
  `transfer_surface_id`; coverage is inferred from filenames/intents.

## 8. Highest-Risk Gaps

1. W2-W6 route/content title drift
   - Learner risk: product may claim one world job while authored files teach a
     different job.
   - Source evidence: Act0 cards and Master Plan titles vs `world.md` titles.
   - Why it matters: content authoring before normalization will create more
     inconsistent proof.
   - Recommended follow-up: Wave 6.1 schema/source-truth normalization first.
   - First: schema and validation.

2. Missing `concept_family_id` in all W1-W6 drills
   - Learner risk: telemetry and repair cannot reliably aggregate by concept.
   - Source evidence: `rg` found zero W1-W6 source files with
     `concept_family_id`.
   - Why it matters: same-signal coverage remains inferred, not owned.
   - Recommended follow-up: schema/factory field contract.
   - First: schema.

3. Missing `same_signal_group_id` and `transfer_surface_id`
   - Learner risk: repeated surfaces can masquerade as transfer.
   - Source evidence: zero W1-W6 source files contain same-signal or transfer
     fields.
   - Why it matters: learning-effect proof depends on distinguishing same signal
     from surface memorization.
   - Recommended follow-up: Wave 6.1 field design plus validators.
   - First: schema.

4. Missing source-owned `repair_focus_id`
   - Learner risk: repair can be shown at runtime without a durable content
     contract for what is being repaired.
   - Source evidence: zero W1-W6 source files contain `repair_focus_id`.
   - Why it matters: current repair truth is useful but not source-owned.
   - Recommended follow-up: define repair focus vocabulary in schema before new
     content.
   - First: schema.

5. W2 over-broad table-reading bridge
   - Learner risk: W2 can feel like several worlds compressed into one: showdown,
     position, initiative, board texture, outs, price, and action.
   - Source evidence: W2 has 111 drills across many kinds and intents.
   - Why it matters: high volume does not equal a single durable cognitive shift.
   - Recommended follow-up: classify W2 as bridge/migration content until route
     labels are normalized.
   - First: validation/schema.

6. W5/W6 title inversion risk
   - Learner risk: W5 route says bet purpose but content teaches board; W6 route
     says board but content teaches range.
   - Source evidence: Act0 card titles vs `content/worlds/world5/world.md` and
     `content/worlds/world6/world.md`.
   - Why it matters: this blocks honest premium/route claims.
   - Recommended follow-up: route-title/content-owner decision before authoring.
   - First: schema/source-truth decision.

7. W1 size preview leakage
   - Learner risk: early size-button vocabulary can look like bet-purpose
     teaching before W4/W5 ownership is settled.
   - Source evidence: four W1 bet-size preview files.
   - Why it matters: not harmful as preview, unsafe as mastery evidence.
   - Recommended follow-up: label preview fields in schema.
   - First: schema.

## 9. Wave 6.1 Schema / Factory Implications

Wave 6.1 should consider these source-owned fields:

- `world_id`
- `route_world_id`
- `display_world_title`
- `content_owner_world_id`
- `route_gate_status`
- `lesson_id`
- `session_id`
- `task_id`
- `concept_family_id`
- `repair_focus_id`
- `same_signal_group_id`
- `transfer_surface_id`
- `misconception_id`
- `drill_kind`
- `correct_action`
- `acceptable_actions`
- `feedback_reason`
- `table_state` or `scenario_state`
- `validation_status`
- `preview_only`
- `source_truth_status`

Validation rules to add before authoring:

- A route-visible world title must match the content-owner world job, or the
  file must explicitly declare `source_truth_status=bridge_or_legacy`.
- Every decision rep must carry a `concept_family_id`.
- Same-signal groups need at least five reps before `coverage_ready` can be
  claimed.
- Transfer groups need at least two different `transfer_surface_id` values
  before transfer can be claimed.
- Repairable concepts must carry `repair_focus_id`.
- Preview-only reps must not count toward mastery coverage.
- W7-W12 route status must remain locked/non-routed unless a route-admission
  artifact explicitly changes it.

## 10. Wave DoD Status

- W1-W6 each inventoried: done.
- Concept-family coverage matrix created: done.
- Same-signal variants classified: done, inferred from filenames/intents.
- Repair path coverage classified: done, partial/runtime-derived; source-owned
  repair IDs missing.
- Tests/guards evidence classified: done.
- No content authored: done.
- No W7-W12 opened: done.
- Wave 6.1 implications listed: done.

## 11. Evidence DoD Status

Command results:

- `git status --short`
  - Result: only pre-existing untracked `output/` folders before this artifact.
- `git switch -c codex/wave5-3-w1-w6-content-depth-audit-v1`
  - Result: branch created from accepted Wave 5.2 follow-up commit.
- `graphify query "W1-W6 content depth same-signal coverage active Act0 route concept_family_id repair_focus_id"`
  - Result: completed, but broad/noisy; targeted `rg`/source inspection was more
    useful.
- `find content/worlds/world{1..6}/v1/sessions ... | jq`
  - Result: W1 98 drills/31 chain steps; W2 111/23; W3 18/42; W4 123/11; W5
    41/24; W6 92/17.
- `rg -l 'concept_family_id|repair_focus_id|same_signal|transfer_surface' content/worlds/world{1..6}/v1/sessions`
  - Result: zero W1-W6 files for each explicit schema field.
- Feedback-field counts:
  - W1: 37 correct-feedback files, 37 incorrect-feedback files, 51 `why_v1`
    files, 10 recap files.
  - W2: 111, 111, 111, 10.
  - W3: 18, 18, 18, 14.
  - W4: 83, 83, 123, 3.
  - W5: 41, 41, 41, 8.
  - W6: 92, 92, 92, 4.

Validation commands for this docs-only wave:

- `graphify hook-check`
  - Result: passed.
- `git diff --check`
  - Result: passed.
- Direct ASCII check on changed markdown.
  - Result: no findings.
- Direct trailing-whitespace/CRLF check on changed markdown.
  - Result: no findings.

## 12. Score Delta Proposal

- Content depth: no automatic increase. W1-W6 have real volume, but source-truth
  drift and missing schema fields block a confidence increase.
- Learning effect: unchanged. Same-signal coverage is promising but not
  explicitly fielded or measured.
- Full readiness: unchanged. This audit reduces uncertainty but does not fix the
  content/source contract.
- Overall top-1 readiness: unchanged by default.

Conservative proposal: no score movement until Wave 6.1 creates source-owned
coverage fields and validates W2-W6 title/content alignment.

## 13. Remaining Work

Wave 5.3 closes as an audit and does not need PR2 if validation is green.

Recommended next step under the long-horizon ledger:

`Wave 6.1 - Content Schema Foundation`

Reason: the product should not author more W1-W6 or W5-W12 content until the
schema can express route world, content owner, concept family, same-signal group,
transfer surface, repair focus, and validation status.

Wave 5.4 Human QA Protocol can proceed if the team wants reviewer workflow next,
but the content-production path should prioritize Wave 6.1 before any urgent
authoring wave. No urgent content authoring wave should be inserted before
schema unless the user explicitly accepts the route/content source-truth drift.
