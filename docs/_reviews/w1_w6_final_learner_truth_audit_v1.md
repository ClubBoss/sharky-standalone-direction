# W1-W6 Final Learner-Truth Audit + AI-Simulated QA Gate v1

Status: `w1_w6_final_gate_repair_program_ready`

Base HEAD: `a21971a607fae15a2c9464dd143e0e445ae155c7`

Branch: `codex/w1-w6-final-learner-truth-audit-v1`

## Final verdict

Verdict: `w1_w6_final_gate_repair_program_ready`.

The active W1-W6 route is technically traceable and Stage 1B same-signal
repair coverage is present for the admitted W4/W5/W6 families, but the route
is not learner-truth clean. The final repair program should run before Human
QA because the audit found material beginner-propagation, assessment-validity,
feedback-source, active-authority, telemetry, and mobile-hierarchy issues.

No product code, learner content, manifest, route, telemetry, UI, screenshot
tooling, Modern Table, W7+, or monetization implementation was performed.

## Scope and methodology

Required authority chain read:

- `AGENTS.md`
- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- relevant sections of `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/_reviews/stage_1b_integration_and_capsule_refresh_v1.md`

Graphify queries used:

- `active W1-W6 Act0 learner route source manifest runtime repair telemetry tests`
- `Act0ShellPreviewScreenV1 world progress lesson step current mission repair queue Session Summary`
- `W1 W2 W3 W4 W5 W6 stable id session drill source registry world manifest`

Targeted source checks then used active manifests, session indexes, Act0 shell
owners, session-drill parser/evaluator owners, repair receipt owners, and
focused tests. Archive/donor roots and W7+ source were not read for audit truth.

## Active route inventory

Inventory source: `content/_meta/world_drills_manifest_v1.json`,
`content/_meta/world_sessions_manifest_v1.json`, and active
`content/worlds/world*/v1/sessions/index.md`.

Decision-row counting rule: chain wrapper prompts are not counted as learner
decisions; each `hand_chain_v1` step is counted as one decision.

| World | Active sessions | Drill files | Chain-step decisions | Active decision rows |
| --- | ---: | ---: | ---: | ---: |
| W1 | 10 | 47 | 31 | 68 |
| W2 | 14 | 33 | 23 | 48 |
| W3 | 14 | 18 | 42 | 46 |
| W4 | 10 | 123 | 11 | 131 |
| W5 | 10 | 41 | 24 | 57 |
| W6 | 10 | 92 | 17 | 103 |
| Total | 68 | 354 | 148 | 453 |

Kind coverage across the 453 rows:

- `hand_chain_v1`: 148
- `action_choice`: 96
- `seat_tap`: 47
- `bet_sizing_choice_v1`: 44
- `board_tap`: 43
- `board_texture_classifier_v1`: 36
- `hole_cards_tap`: 15
- `range_bucket_board_fit_classifier_v1`: 6
- `range_width_classifier_v1`: 6
- `showdown_winner_choice_v1`: 3
- `position_thinking_choice_v1`: 3
- `initiative_aggressor_choice_v1`: 3
- `outs_count_choice_v1`: 3

## Runtime/source findings

- Active Act0 entry remains `Act0ShellPreviewScreenV1` via
  `lib/ui_v2/app_root.dart` and `lib/ui_v2/ui_v2_beta_shell.dart`.
- Active W1-W6 drill ownership is manifest-backed, not raw filesystem-backed.
- W5 source/index authority is still split: active `sessions/index.md` and
  manifests end at `w5.s10`, while `content/worlds/world5/v1/index.md` still
  lists `w5.s11`. This is not active route truth, but it is stale authority
  residue that can mislead future audits.
- A focused W3 runtime guard failed because `w3.s10` now loads
  `chain_preflop_final_checkpoint_v1` plus three active transfer drills, while
  `test/guards/world3_early_arc_runtime_truth_contract_test.dart` still expects
  only the chain. This is an active test/source authority drift.
- Card and street sanity script found no duplicate-card rows and no
  board-length/street mismatch across active W1-W6 decision rows.

## Beginner findings

The absolute-beginner route is not clean enough for Human QA.

Placement route evidence: `lib/services/placement_service_v1.dart` maps a
beginner bucket to `w1.s01`; weak-area repair may route to `w0.s01`, `w1.s01`,
or `w2.s01`, but no durable beginner-profile constraint follows the learner
into later W1/W2/W3 prompts.

Material failures:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  `first_table_guide_one_clear_choice` asks `What is the clean preflop setup
  here?` and uses Hero, BTN, blinds, board, and preflop in one assessment.
- W1 `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`
  uses cutoff, button, small blind, preflop setup assumptions, and sizing
  preview language at the first active W1 source row.
- `content/_meta/term_introduction_contract_v1.json` does not own first-use
  ordering for Hero, Villain, BTN/CO/SB/BB, blinds, preflop/postflop, board,
  pot, sizing, or basic role labels.

Disposition: repair now via a beginner-route vocabulary/profile propagation
wave. Human QA should not be asked to discover these obvious missing-definition
risks.

## Terminology-order matrix

| Term | First active assessment/use found | First explicit owner found | Audit result |
| --- | --- | --- | --- |
| Hero | Act0 first-table guide and W1.s01 chain | no term-contract owner | repair now |
| Villain | W2.s01 showdown rows | local context only | repair now for glossary/order coverage |
| BTN/button | Act0 first-table guide and W1.s01 chain | partial local teaching | repair now |
| CO/cutoff | W1.s01 chain | no term-contract owner | repair now |
| SB/small blind | W1.s01 chain | no term-contract owner | repair now |
| BB/big blind | W1.s02 chain | no term-contract owner | repair now |
| blinds | Act0 first-table guide / W1.s01 | no term-contract owner | repair now |
| preflop | Act0 first-table guide; W2.s03 prompt | no term-contract owner | repair now |
| postflop | W2.s02 intro/prompt family | local context only | keep with glossary coverage |
| board | Act0/W2 early table reads | local context only | keep, but validate beginner order |
| pot | Act0/W1.s01 | no term-contract owner | repair now |
| sizing | W1.s01 preview rows | no term-contract owner | repair now |
| range | W4/W6 route copy | W6 combo only; range not ordered as beginner term | repair now before Human QA |
| equity | W1.s05/W4 rows | contract introduces EQUITY at W1.s05 | keep, but assert no test before W1.s05 |
| blockers | W4.s03 | contract introduces BLOCKERS at W4.s03 | keep |
| outs | W2.s06 | contract introduces OUTS at W2.s06 | keep |
| texture | W2.s04/W2.s08 | PAIRED covered; broader texture terms local | keep with scan |

## Prompt/table findings

- Representative prompt/table truth for Stage 1B W6 repaired rows is good:
  `stage1b_wave_c_w6_proxy_context_clarity_contract_test.dart` passed six
  rendered/runtime state checks.
- Many W5 later board-texture classifier rows are still prompt/label authored
  without structured `board_cards_v1`. Stage 1B accepted this for repair
  targeting, but the final learner gate should not rely on prompt-only board
  facts where a visible table state is the teacher.
- First-table guide prompt repeats facts that the table/teaching step already
  exposes and asks a vocabulary setup question before proving the learner can
  distinguish the table facts independently.

Disposition: repair now for beginner prompt/table contract and high-EV W5
structured-context rows; keep W6 Stage 1B repaired rows.

## Assessment-validity findings

- `first_table_guide_one_clear_choice` has an obviously implausible distractor:
  `The flop is already out and this is postflop`, while the prompt/teaching
  step says no board is out. This can be solved by elimination, not table
  understanding.
- Several early prompts are recognition/guided-label tasks rather than
  independent transfer, especially when the correct answer is embedded in the
  option label.
- Active answer-position distribution for large action families is not the
  dominant leak; template/label exploitation is the bigger risk.

Disposition: repair now.

## Language findings

Language is mostly concise, but not consistently beginner-safe. Material
examples:

- W1.s01 starts with `Choose the best action.` rows without local feedback or
  setup explanation.
- W4 sizing rows often use compact strategy labels but no row-local
  learner-facing feedback.
- Repeated phrases like `Which simple action fits best` are serviceable but
  can train pattern matching when paired with template-stable options.

Disposition: repair now as copy/feedback source work, not visual redesign.

## Feedback findings

Audit script found 50 active non-chain rows missing both
`feedback_correct_v1` and `feedback_incorrect_v1`. Representative rows:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_call.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_half_pot_value.json`
- W4 `bet_sizing_choice_v1` rows from `w4.s01` through `w4.s08`

This is a P1 learner-truth issue: evaluator pass/fail can be correct while the
visible explanation is absent, generic, or runtime-fallback owned.

Disposition: repair now. All repaired rows need correct, acceptable where
applicable, incorrect, and `why_v1` agreement.

## Transfer and repetition findings

- W1-W6 have enough row volume and changed contexts for a route-level repair
  program; the issue is not raw quantity.
- Same-signal coverage is uneven by design: Stage 1B only admits W4 denial,
  W5 dry texture, W6 board fit strong/missed, and W6 range width wider/narrower.
- W1-W3 and large W4/W5/W6 families still count on normal route repetition, not
  durable same-signal repair receipts.

Disposition: repair now only for families connected to material audit
failures; defer remaining families with explicit reopen triggers.

## Repair lifecycle findings

Stage 1B repair lifecycle is technically coherent for admitted families:

- source miss -> receipt -> persistence -> consumer -> launch queue -> target
  -> retained recheck result is implemented through
  `session_drill_repair_receipt_adapter_v1.dart`,
  `session_drill_repair_receipt_persistence_v1.dart`,
  `session_drill_repair_receipt_consumer_v1.dart`, and
  `session_drill_recheck_launch_queue_v1.dart`;
- focused Stage 1B repair lifecycle tests passed 7/7 before unrelated later
  guard failures stopped the grouped test command.

Open repair lifecycle limits:

- no per-decision time-to-decision in the session-drill path;
- repair receipts exist only for exact reviewed tuples;
- W5 wet/connected/paired/high-card, W6 medium/weak board fit, W6
  `less_constrained`, W6 `stronger_on_average`, and most W1-W3 rows remain
  unmapped by explicit policy.

Disposition: repair now for telemetry/receipt field gaps; defer unmapped
families unless the grouped repair program touches their source rows or Human
QA exposes a repeated miss.

## Telemetry findings

Actual support:

| Field | Current support |
| --- | --- |
| user choice | local Act0 runner event and repair receipt `chosenActionId` for eligible rows |
| correctness | evaluator result and retained result `success`/`miss` for eligible rechecks |
| error type | evaluator `errorClass` / receipt `errorClass` for eligible rows |
| source ID | receipt source world/session/drill IDs for eligible rows |
| signal | `missedSignalId` for eligible rows |
| target ID | receipt target session/drill IDs for eligible rows |
| recheck result | retained recheck result for eligible rows |
| completion | route/progress service support exists |
| time to decision | Act0 runner has `time_to_decision_ms`; current session-drill path remains unavailable per Stage 1B prompt/capsule |

Disposition: required in grouped repair program. Do not invent telemetry.

## Progression/payoff findings

- Technical completion and progression are guarded, but Human QA has not been
  executed and cannot be simulated into learner-outcome proof.
- W4 small-portrait actionability guard failed before finding
  `world_campaign_open_4`, `world_campaign_next_pack_cta`, or
  `map_render_fallback_v1`; this is progression/action-access evidence.
- Completion/payoff copy must remain claim-safe: no mastery, fixed-forever,
  launch, or learning-effect claims.

Disposition: repair now for W4 actionability; Human QA required before
learner-outcome claims.

## Cognitive-load findings

Human evidence and source confirm a hierarchy risk:

- Home/Learn can expose current world/current lesson/current step/mission and
  repeated progress/navigation concepts.
- `act0_learn_path_shell_v1.dart` renders `Current lesson`, `Current step`,
  `Now`, progress labels, and a mission CTA in close proximity.
- The portrait void screenshot is not classified as a defect by itself. It
  becomes actionable only if CTA access, feedback visibility, scrolling,
  safe-area, or comprehension is affected. The W4 small-portrait guard failure
  is the concrete reopen path for actionability.

Disposition: repair now for hierarchy/actionability; defer pure whitespace.

## Persona simulation findings

Only material failures are recorded.

| Persona | Material failure |
| --- | --- |
| Absolute beginner | Undefined Hero/BTN/blinds/preflop/board setup can arrive before stable introduction. |
| Literal reader | Prompt/table facts and option labels can make elimination easier than concept understanding. |
| Impatient mobile user | Learn/Home hierarchy risks competing current/now/progress blocks; W4 small portrait guard failed. |
| Weak poker vocabulary | Seat abbreviations, blinds, pot, range, and sizing are not globally order-owned. |
| Lightly experienced contradiction-noticer | W5.s11 stale top-level index versus inactive manifest can look like duplicate authority. |
| Pattern-guesser | Template-stable prompts/options allow guided recognition in early route rows. |
| Repeated-error learner | Repair is strong only for admitted Stage 1B families; many misses silently remain normal failure. |
| Returning learner | Proof/return copy must stay local-evidence based; no durable time-to-decision/decision telemetry for session-drill path. |

## Human QA residue

Human QA is not executed. Exact future protocol must include:

- absolute beginner session from placement `new`;
- W1.s01 and Act0 first-table-guide comprehension checks for Hero/BTN/blinds/preflop/board;
- W4 small-portrait CTA/accessibility check;
- W5 prompt/table texture explanation check;
- W6 repaired row comprehension check;
- confusion note, user choice, correctness, error type, source ID, target ID,
  recheck result, completion, and time-to-decision capture.

## Closure recommendation

Run the grouped repair program in
`docs/_reviews/w1_w6_grouped_repair_program_v1.md` before Human QA. Highest-EV
first wave: beginner vocabulary/order + first-table-guide assessment validity
because it blocks the strict "first time playing poker" promise and affects
the first learner trust moment.
