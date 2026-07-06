# W1-W6 Final Repair Ledger v1

Status: `final_learner_truth_ledger_ready`

Base HEAD: `a21971a607fae15a2c9464dd143e0e445ae155c7`

Active decision rows accounted: 453.

## Ledger

| Finding ID | World/session/stable ID | Severity | Root cause | Evidence | Learner impact | Disposition | Proposed owner seam | Regression proof required | Reopen trigger |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1W6-LT-001 | placement -> Act0 `first_table_guide_one_clear_choice`; W1 `w1.s01/chain_world1_first_bridge_v1` | P1 | beginner profile does not constrain downstream vocabulary | `placement_service_v1.dart` routes beginner to `w1.s01`; Act0 row asks `What is the clean preflop setup here?`; W1.s01 uses cutoff/button/small blind before global ownership | first-time learner can pass/fail on undefined terms | `repair_now` | Act0 placement/first-table guide + W1 first-session source + term contract | focused Act0 first-table-guide test; term-order scanner for Hero/BTN/CO/SB/BB/blinds/preflop/board/pot | any beginner route row uses an unordered term before explanation |
| W1W6-LT-002 | Act0 `first_table_guide_one_clear_choice` | P1 | assessment distractors expose answer by elimination | option `The flop is already out and this is postflop` contradicts no-board teaching step; test locks phrase/options in `act0_shell_preview_screen_v1_test.dart` | false success on setup read | `repair_now` | `act0_shell_state_v1.dart` first-table-guide runner | widget test proving plausible distractors and no answer leakage | screenshot/human tester succeeds while unable to explain setup |
| W1W6-LT-003 | `content/_meta/term_introduction_contract_v1.json`; W1-W3 prompts | P1 | term-order contract is too narrow | priority terms cover EQUITY/OUTS/BLOCKERS/etc. but not Hero, Villain, seats, blinds, preflop/postflop, board, pot, sizing, range | hidden prerequisite and teach-after-test risk | `repair_now` | term introduction contract + scanner/tests | scanner extends to beginner route terms and proves first explanation before first assessment | any new W1-W6 row introduces unowned learner term |
| W1W6-LT-004 | W1/W4 representative rows: `w1.s01/choose_call`, `w1.s01/choose_half_pot_value`, W4 bet-sizing rows | P1 | visible feedback not source-owned for all active rows | audit script found 50 active non-chain rows missing both `feedback_correct_v1` and `feedback_incorrect_v1` | pass/fail can occur without clear why | `repair_now` | content JSON feedback fields + parser/runner feedback presentation | source scan requiring correct/incorrect/why; widget test for one W1 and one W4 row | any active decision row lacks correct/incorrect feedback after repair |
| W1W6-LT-005 | W3 `w3.s10` | P1 | active source/test authority drift | `world3_early_arc_runtime_truth_contract_test.dart` expected only `chain_preflop_final_checkpoint_v1`; runtime loaded three additional active transfer drills | route truth can be stale despite green content source | `repair_now` | W3 active session manifest/index + guard expectations | focused W3 guard updated to current active row set and route meaning | guard fails or W3.s10 active row set changes without test alignment |
| W1W6-LT-006 | W4 map/progression entry | P1 | mobile actionability/progression surface not proven | `world4_campaign_routing_contract_test.dart` failed before finding `world_campaign_open_4`, `world_campaign_next_pack_cta`, or `map_render_fallback_v1` on 360x640 | learner may not find/access next world entry | `repair_now` | Act0 map/progress entry surface and routing guard | small-portrait widget test passes with visible enabled CTA/fallback | any compact portrait cannot expose W4 entry/next CTA |
| W1W6-LT-007 | W5 source indexes | P2 | duplicate/stale authority | active sessions/manifests end at `w5.s10`; `content/worlds/world5/v1/index.md` still lists `w5.s11` | future audit/content work may reopen ghost content | `repair_now` | W5 index/manifest truth | manifest/index parity guard proving W5.s11 preserved only as inactive source | any active artifact claims W5.s11 playable |
| W1W6-LT-008 | W5 `board_texture_classifier_v1` rows, especially W5.s02-W5.s10 | P2 | prompt-only board facts weaken table/prompt contract | Stage 1B artifact records active W5.s02-W5.s10 classifiers contain expected action/texture but no structured board-card state | learner may solve text labels instead of visible board | `repair_now` | W5 source rows + session-drill scenario state projection | representative W5 rows render board cards/texture facts and pass parser/evaluator tests | Human QA or screenshot shows prompt-only table confusion |
| W1W6-LT-009 | Stage 1B repair families | P1 | repair lifecycle is intentionally narrow | receipts admitted for W4 denial, W5 dry texture, W6 strong/missed board fit, W6 wider/narrower; many W1-W6 families unmapped | repeated learner miss may silently become normal failure | `defer_with_trigger` | repair receipt adapter/persistence/consumer/queue | keep Stage 1B tests; add only if grouped repair touches family | repeated Human QA/source miss in unmapped family, or row edited in grouped repair |
| W1W6-LT-010 | Session-drill telemetry path | P1 | decision-time telemetry unavailable for current session-drill route | capsule/prompt state says decision-time telemetry remains unavailable; Act0 runner has local `time_to_decision_ms`, but session-drill path lacks equivalent capture | cannot measure hesitation, repair latency, or retained proof quality | `repair_now` | Act0/session-drill telemetry event seam | event schema/test includes user choice, correctness, error type, source ID, signal, target ID, recheck, completion, time-to-decision | any final gate claims learning effect without these fields |
| W1W6-LT-011 | Learn/Home hierarchy | P2 | competing current/progress blocks | human evidence plus `act0_learn_path_shell_v1.dart` keys for `Now`, `Current lesson`, `Current step`, progress labels, mission CTA | mobile learner may not know primary action | `repair_now` | Act0 Learn/Home hierarchy copy/layout only | widget/screenshot proof of one primary current-action hierarchy; no redesign scope | Human QA reports action ambiguity or compact CTA competition |
| W1W6-LT-012 | Portrait drill screenshot void | P3 | possible layout inefficiency without proven learner harm | user evidence says large unused vertical void below answer panel; no current proof of hidden CTA/feedback by itself | lower urgency unless it hides critical action/proof | `defer_with_trigger` | active runner portrait layout tests | only validate if CTA, feedback, scroll, safe-area, or hidden text failure is shown | CTA/feedback inaccessible, W4 compact guard remains failing, or screenshot shows hidden learner-critical text |
| W1W6-LT-013 | Completion/payoff copy and proof | P2 | Human QA not executed; proof is technical only | `HUMAN_QA_CAPSULE_v1.md` says W1-W6 have technical support, not learner-outcome proof | premature mastery/launch claim would break trust | `human_qa_required` | Human QA protocol + claim-safety guards | novice protocol captures choice/correctness/error/time/confusion/recall | any public/9.0/learning-effect claim before Human QA |
| W1W6-LT-014 | Prompt/copy templates across W1-W6 | P2 | guided recognition and repeated phrasing | repeated `Which simple action fits best`; W1 generic `Choose the best action`; label-heavy options | pattern-guesser can exploit templates | `repair_now` | content copy source and assessment-option policy | prompt/option anti-leak scan plus representative widget tests | same option/prompt template lets tester pass without explaining table clue |

## Severity summary

- P0: 0
- P1: 8
- P2: 5
- P3: 1
- P4: 0

## Root-cause summary

- beginner vocabulary/order propagation: W1W6-LT-001, W1W6-LT-003
- assessment answer leakage/template exploitation: W1W6-LT-002, W1W6-LT-014
- feedback source incompleteness: W1W6-LT-004
- active authority drift: W1W6-LT-005, W1W6-LT-007
- mobile actionability/hierarchy: W1W6-LT-006, W1W6-LT-011, W1W6-LT-012
- prompt/table structured-context gap: W1W6-LT-008
- repair/telemetry proof gap: W1W6-LT-009, W1W6-LT-010
- external evidence gate residue: W1W6-LT-013
