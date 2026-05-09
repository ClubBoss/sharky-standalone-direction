# ROADMAP_FINAL_100_SSOT

This document is the single source of truth (SSOT) for the complete end-to-end roadmap to a fully finished, autonomous, monetized Sharky Poker / Poker Analyzer product.

Project-readiness scoring and the meaning of true final `100/100` are defined
separately in `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`. Use the roadmap
for milestone order and backlog scope, and the project-readiness SSOT for
current readiness scoring, gating interpretation, and bottleneck reporting.

## Global principles (apply to every milestone)
- Deterministic-first. No RNG/time-based nondeterminism in logic. Prefer stable traversal/sorting.
- No new dependencies unless explicitly justified by a milestone DoD.
- Prefer contract/widget tests over screenshot PNG proofs. Add PNG proofs only for true regression risk.
- PIEC mandatory: search for existing equivalent logic/tests first; STOP as NO-OP if already covered.
- Git hygiene mandatory: PRE/POST `git status --porcelain` must be clean for each change batch.
- Small, reversible diffs. Avoid renames/moves unless required.
- ASCII-only. Append-only enums if touched.
- Do not mix milestones. Finish the active milestone to 100/100 before starting the next.

## What “Rest state” means (final completion definition)
The product is considered fully complete when:
1) Core loops are stable and deterministic across supported devices and text scales.
2) Content expansion is automated via tooling + validators and does not break runtime.
3) Monetization is integrated (IAP/paywalls), compliant, and does not degrade learning outcomes.
4) Player profile + personalization layer reliably adapts training without ML (rule-based).
5) Regression protection is strong: tiered gates, minimal flakiness, clear playbooks.
6) A small team can ship content/features without fear of regressions; maintenance is low-touch.

## Release-Ready Definition v1 (overlay, all milestones)
This section is an objective release overlay. It does not change milestone order, weights, or scope.

### Release-Ready DoD (must-pass)
- Product E2E:
- Onboarding -> start session -> complete outcome -> continue/return loop works with no dead ends.
- Primary CTA path is clear and actionable at each step (start, commit, continue, return).
- Content minimum:
- World2 Gold is accepted under R7 S0-S5 rubric with two-person S2+S3 approval.
- At least a 2-world rollout is completed using the Gold rubric before release candidate signoff.
- UX/Visual:
- R6 placement/visual matrix contract suite is green for defined device and textScale variants.
- No critical overlap/clipping regressions in key states (seat-quiz, decision state, result/feedback).
- Stability/Gates:
- Tier0 is green at all times; Tier2 checkpoint is green at the defined checkpoint cadence.
- Zero open P0/P1 bugs at release cut.
- Determinism constraints remain intact (no time/RNG drift in logic or tests).

P0/P1 severity shorthand:
- P0: release blocker (crash/data loss/dead-end/security/compliance risk).
- P1: major user-facing defect that materially breaks core learning or monetization flows.

### NO-GO / STOP rules
- STOP release if Tier0 is red.
- STOP release if Tier2 checkpoint is red for the release candidate.
- STOP release if any P0 or P1 issue remains open.
- STOP release if determinism constraints are violated in runtime, tests, or content tooling.
- STOP release if content validators or content QA runner fail on release candidate branch.

### Post-Release bucket (allowed after v1)
- Visual polish and non-critical UI refinements.
- Additional worlds beyond release minimum.
- Deeper mastery/crucible expansion beyond release minimum.
- Gamification/engagement enhancements that do not change release-critical flows.
- Nice-to-have telemetry refinements and dashboard/reporting expansion.

## Release Candidate Definition v2 (planning lock)
This section extends v1 and is the strict SSOT for RC cut readiness in R10+.

### Must-pass E2E flows
- onboarding -> world1 -> world2 -> world10 -> track choice -> track s01..s03 -> result -> back to map
- No dead ends, no blocked CTA, no stuck return path in the primary loop.

### Hard stop rules
- STOP on any Tier0 red (`flutter analyze` or `./tools/fast_loop_world1_v1.sh`).
- STOP on any open P0 or P1 issue.
- STOP on any determinism violation in runtime/tests/content traversal.
- STOP on content validator or QA failure when content is touched.

### Gate policy
- Tier0 always required for every implementation batch.
- Content validators required only when content is touched:
- `dart run tools/validate_world_content_v1.dart`
- `dart run tools/run_content_qa_r2_v1.dart`
- Tier2 required only on checkpoint cadence or RC cut checkpoints.

### Messaging policy truth
- No solver wording in release-visible copy ("solver", "GTO", "optimal", "node", "branch").
- Use "recommended play" plus factual `why_v1` lines for user explanation.
- Soft-pass path remains supported through `acceptable_actions` with "Legal, but worse" style copy.

## Ship Checklist v1 (trackable)
### Product flow
- [ ] Onboarding opens and completes without error.
- [ ] Today Plan shows a playable primary CTA.
- [ ] Start session CTA opens a playable runner state.
- [ ] Runner commit action transitions to outcome state.
- [ ] Outcome state shows deterministic feedback lines.
- [ ] Continue CTA from outcome opens next playable step.
- [ ] Return path to map/home works from runner and outcome.
- [ ] No dead-end route in primary user loop.

### Content
- [ ] World2 Gold package passes S0 structural checks.
- [ ] World2 Gold package passes S1 decision/feedback checks.
- [ ] World2 Gold package passes S2 consistency review.
- [ ] World2 Gold package passes S3 pedagogy correctness review.
- [ ] World2 Gold package passes S4 balance and deterministic gate checks.
- [ ] World2 Gold package passes S5 rollout-template readiness checks.
- [ ] Two-person S2+S3 approvals are recorded before merge.
- [ ] Two-world pilot rollout content is completed and validated.
- [ ] World2 canonical content pass complete (Policy Truth v1).
- [ ] World3 and World4 rolled out (MS1-MS10 each), validators green.

### UX/Visual
- [ ] Stadium ratio/aspect contract test is green.
- [ ] Seat-quiz caption safe-zone contract test is green.
- [ ] Placement matrix contracts are green for required sizes and text scales.
- [ ] Decision-state controls are readable and not clipped.
- [ ] Result/feedback surface stays within safe bounds.
- [ ] No critical overlap among caption, seat labels, board, pot, and controls.

### Stability/QA
- [ ] `flutter analyze` passes.
- [ ] `./tools/fast_loop_world1_v1.sh` passes.
- [ ] `./tools/run_release_gate_r5_v1.sh` passes.
- [ ] `dart run tools/run_content_qa_r2_v1.dart` passes.
- [ ] Tier2 checkpoint workflow is green at required checkpoint.
- [ ] No open P0 issues.
- [ ] No open P1 issues.
- [ ] Release notes and rollback pointer are prepared.

---

# Milestone R0 — Ship-Ready Demo (World1 loop)

## Goal
A demo-grade prototype (not placeholder) with real actionable tasks + deterministic feedback/explanations, preserving deterministic infra + regression proofs.

## Active Counter (R0) — 0..100
Counter tracking format for this milestone:
Counter — X/100 (+Δ%)

### R0 Weights (100)
B) UI Surface Integrity (55)
- B5 Review-mode geometry parity (same guarantees as spine; long caption + textScale 1.0/1.15) — 25
- B3 Device size variants (>=2 portrait sizes) — 10
- B4 Seat config variants (>=2 configs OR N/A with enforced fixed config + test) — 10
- B6 Hitbox/edge inset sanity — 10

A) Core Demo Loop Hardening (25)
- A3 Step progression integrity (multi-street sequence doesn’t auto-skip) — 10
- A4 Task/Prompt non-placeholder for all demo steps — 5
- A6 Review loop integrity (non-empty queue -> non-empty review session + consumes) — 5
- A7 Abort/back safety — 5

F) Release Packaging (20)
- F1 Golden demo path documented — 8
- F2 Crash-free smoke checklist — 6
- F3 Repo/artifact hygiene note — 3
- F4 Minimal demo scope locked — 3

## R0 DoD (binary checks)
- All R0 weighted items are complete and evidenced by tests/docs.
- Tier0 gates green on main.
- Demo script works in <2 minutes: launch -> start World1 -> make at least one mistake -> see deterministic feedback -> finish -> see UP NEXT/review.

---

# Milestone R1 — MVP Content Slice (World0–4) — 100/100

## Goal
A minimal “alive” product where a user experiences learning gains in 1–3 sessions and progression feels real.

## Counter (R1) — 0..100
### R1 Weights (100)
1) Curriculum completeness (40)
- World0–4 content present as canonical bundles under content/<id>/v1/ — 20
- Each world has a minimal Learn -> Practice -> Checkpoint structure (or equivalent) — 10
- Review/repetition schedule exists for World0–4 (basic) — 10

2) Content quality automation (30)
- Validators enforce structure, links, and “no placeholder” — 10
- Validators enforce action-order correctness wording — 10
- Validators enforce micro-theory limits (prevent textbook drift) — 10

3) Progression integrity (20)
- Map/Home/Today Plan reliably route through World0–4 without dead-ends — 10
- Session result continuity (UP NEXT / REVIEW) works across World0–4 — 10

4) Telemetry minimal completeness (10)
- Emits: user_choice, correct/error_type, time_to_decision for drills used in World0–4 — 10

## R1 DoD
- All World0–4 packs/modules load from canonical content/ bundles.
- All validators + Tier0 gates green.
- A user can complete World0–4 without crashes and with clear progression.

---

# Milestone R2 — Full Curriculum (World0–9) — 100/100

## Goal
The full 10-world roadmap is completed with stable pacing, repetition, and QA automation.

## Counter (R2) — 0..100
### R2 Weights (100)
1) World5–9 content fill (45)
- World5–9 canonical content bundles created and validated — 30
- Mixed checkpoints every N modules (spaced repetition) — 10
- Difficulty/pacing rules applied consistently — 5

2) Content QA automation at scale (35)
- Tooling supports batch ingest/validate with deterministic output — 15
- CI prevents broken content from merging — 10
- Content lint rules cover common failure modes (links, placeholders, ordering statements) — 10

3) Progression + retention coherence (20)
- Path/map progression remains coherent across all 10 worlds — 10
- Review scheduling remains effective and does not starve older items — 10

### R2 Counter breakdown (0..100)
- W5 baseline parity verified (structure+roles+density) - 10
- W6 baseline parity verified - 10
- W7 baseline parity verified - 10
- W8 baseline parity verified - 10
- W9 baseline parity verified - 10
- Mixed checkpoints cadence integration - 10
- Content QA at scale (batch ingest/CI hardening) - 15
- Progression coherence across 0-9 (tools + runtime) - 15
- Pacing/difficulty rules applied - 10

### R2 Current credited DONE
- W5..W9 baseline parity audits confirmed OK (NO-OP evidence from recent audits).

## R2 DoD
- 10 worlds completed with consistent quality and pacing.
- Adding a new module is routine, deterministic, and low-risk.

---

# Milestone R3 — Personalization & Player Profile — 100/100

## Goal
Rule-based personalization that increases learning outcomes and retention without ML.

## Counter (R3) — 0..100
### R3 Weights (100)
1) Player Profile UI + metrics (30)
- Profile screen with understandable metrics and history — 15
- Clear explanations of metrics (help/info) — 15

2) Explanation Layer v1->v2 (35)
- Contextual, deterministic explanations for key error types — 20
- Explanations integrate into session flow without clutter — 15

3) Adaptive routing (25)
- Next-step selection based on weaknesses and recency — 15
- Prevents overfitting/memorization with isomorphic repeats — 10

4) Retention loop (10)
- Streak-lite / goals-lite without economy coupling — 10

## R3 DoD
- Two users with different error patterns see different, explainable next-step routing.
- Explanations are deterministic and improve outcomes.

---

# Milestone R4 — Monetization & Economy — 100/100

## Goal
Monetization integrated without harming learning integrity.

## Counter (R4) — 0..100
### R4 Weights (100)
1) Economy system (35)
- Training Bankroll currency (earn/spend/recovery) — 20
- Exactly-once spend invariants preserved — 15

2) Paywalls + purchases (45)
- IAP integration + restore purchases — 25
- Paywall strategy: free onboarding, paid progression — 10
- Edge cases: offline, restore, receipt failures — 10

3) Safety + compliance (20)
- Store compliance readiness — 10
- Learning-first constraints preserved (no pay-to-win) — 10

## R4 DoD
- Purchases work reliably and are recoverable.
- Economy does not break deterministic training loops.

---

# Milestone R5 — Autonomous Release System — 100/100

## Goal
Low-touch maintenance: quality gates + playbooks make the system stable and scalable.

## Counter (R5) — 0..100
### R5 Weights (100)
1) Regression protection (40)
- Tiered gates stable, minimal flakiness — 20
- Critical UI contracts cover key screens/states — 20

2) Content CI automation (30)
- Any content change is validated and safe — 20
- Tooling playbooks for authors and maintainers — 10

3) Performance + determinism audits (20)
- Perf budgets documented and enforced — 10
- Deterministic screenshot pipeline used only for regressions — 10

4) Operational playbooks (10)
- Release checklist, hotfix protocol, rollback steps — 10

## R5 DoD
- The app can be maintained with predictable effort.
- New content/features can be shipped with low regression risk.

---

# Milestone R6 — Visual Perfection + Placement Test Suite (v1)

## Goal
Zero visual defects + guaranteed non-overlap/readability across key devices + text scales.

## Scope
Strictly UI/layout/contracts/tests only; no content rewrites.

## Counter (R6) — 0..100
### R6 Weights (100)
1) Stadium ratio restore + aspect contract (P0) — 25
2) Seat-quiz caption collision fix + seat-quiz state contract test — 25
3) Placement/visual matrix contract suite (devices + textScale + key states) — 25
4) PNG proofs only when needed policy enforcement + checklist closeout — 15
5) Visual regression triage playbook addendum (small) — 10

## R6 DoD
- All weighted R6 items are complete with deterministic contract coverage.
- Critical visual states are overlap-safe and readable on target device/textScale matrix.
- PNG proofs are only added where contract checks cannot safely cover visual risk.
- Tier0/Tier1 gates remain green; Tier2 checkpoint includes the updated visual suite.

## R6 STOP rules
- STOP if the requested visual fix requires content rewrites or schema/telemetry changes.
- STOP if passing requires broad UI redesign outside the scoped visual contracts.
- STOP if a regression cannot be reproduced deterministically.

---

# Milestone R7 — Deep Content Mastery Pass (Gold World + rollout) (v1)

## Goal
Deep, meaningful decision drills per world aligned to ULA v4.3.1; one Gold World as canonical standard; rollout to all worlds; QA S0-S5.

## Hard constraints
- Must follow UNIFIED_LEARNING_ARCHITECTURE v4.3.1 (frozen).
- Must follow CONTENT_SYSTEM v2.1 (micro-sessions, atoms, 3-layer depth).
- Must follow PROJECT_RULES_VFINAL for content format (targets/spotkinds, module structure, ASCII-only for in-app content).

## Gold World (selected)
- Gold World: World2 (canonical standard for deep rewrite + rollout rubric).
- Rationale:
- World2 is early enough to stay beginner-friendly, but deep enough to express real decision quality.
- World2 concepts are reused across later worlds, so quality gains propagate through rollout.
- World2 is stable in progression and avoids overloading World0/World1 onboarding constraints.
- World2 supports deterministic strategic examples without solver language drift.

## Canonical R7 mastery spec (Gold World standard)
- Structure:
- Atoms + micro-sessions follow Content System v2.1, with 6-12 decisions per micro-session.
- Feedback is deterministic and factual, limited to 1-2 lines per decision outcome.
- Mastery and crucible placement:
- Deep strategic drills (3bet/4bet, check-raise, value/bluff) live in mastery/crucible layers, not in early onboarding layers.
- Quality gates:
- S0: structural integrity (files, links, deterministic ids).
- S1: action legality and expected-action correctness.
- S2: pedagogy clarity and progression coherence.
- S3: realism and decision quality under deterministic constraints.
- S4: integrated pass across validator/test/telemetry expectations.
- S5: rollout readiness checklist and maintenance notes.
- Merge requirement:
- Two-person S2+S3 review is mandatory before merge.

## Gold World completion checkpoints
- Gold World DoD checkpoint:
- Gold World passes S0-S5 with explicit S2+S3 two-person signoff.
- Canonical acceptance checkpoint:
- Gold World rubric is accepted as the reference standard for rollout.
- Rollout readiness checkpoint:
- Pilot plan for two additional worlds is defined and mapped to the same rubric.

## World2 Gold Blueprint (v1)
- World2 learning target:
- World2 moves the learner from remembering isolated rules to making consistent action-order decisions in realistic table context, with deterministic reasoning and no solver language.
- Must-master outcomes:
- Correctly identify acting order and legal actions from seat and street context.
- Choose stable default actions for common preflop and simple postflop spots.
- Separate value intent from bluff intent using factual cues only.
- Detect and avoid high-frequency tactical mistakes (illegal checks, unnecessary folds, passive leaks).
- Explain choice in one factual sentence tied to pot, toCall, and board state.

- Micro-session plan (10 sessions, each 8 decisions):
- MS1 Seat and action-order anchor: lock acting order by seat labels and blinds. Mix: 4 seat/order, 2 legality, 2 preflop open/call-fold. Error classes: action_order_mismatch, illegal_action_selection, expected_action_mismatch.
- MS2 Preflop open discipline by position: pick open/fold defaults from early to late position. Mix: 3 position, 3 open/fold, 2 sizing-intent basics. Error classes: range_mismatch, expected_action_mismatch, unnecessary_passive_action.
- MS3 Facing open responses: decide fold/call/raise_to versus an opener. Mix: 2 seat/order, 4 facing-open choices, 2 toCall legality checks. Error classes: tocall_legality_mismatch, expected_action_mismatch, overfold_pattern.
- MS4 Flop c-bet or check baseline: apply simple flop continuation defaults. Mix: 2 board texture reads, 4 bet/check choices, 2 value-vs-bluff intent tags. Error classes: unnecessary_bet, missed_value_spot, expected_action_mismatch.
- MS5 Turn continuation control: decide second barrel versus check-back on turn. Mix: 2 stack-pot context, 4 continue/slowdown choices, 2 legality/order checks. Error classes: overbluff_pattern, missed_checkback_spot, expected_action_mismatch.
- MS6 River value and bluff discipline: choose thin value, check, or bluff with capped ranges. Mix: 3 value/bluff intent, 3 sizing-choice basics, 2 call-fold response spots. Error classes: value_bluff_confusion, thin_value_miss, expected_action_mismatch.
- MS7 Facing aggression with toCall pressure: respond to bets and raises without illegal shortcuts. Mix: 2 order checks, 4 call/fold/raise_to spots, 2 pot-odds-lite comparisons. Error classes: tocall_legality_mismatch, panic_fold_pattern, expected_action_mismatch.
- MS8 Mixed street sequence stability: maintain coherent line across flop-turn-river mini chains. Mix: 2 per street across 3 streets plus 2 recap spots. Error classes: line_inconsistency, street_transition_error, expected_action_mismatch.
- MS9 Mastery bridge pack: combine position, toCall, and intent in mixed drills. Mix: 2 seat/order, 2 legality, 2 value/bluff, 2 aggression response. Error classes: mixed_context_confusion, expected_action_mismatch, tocall_legality_mismatch.
- MS10 Checkpoint proving session: timed but deterministic recall of World2 defaults. Mix: 8 mixed spots from MS1-MS9 distributions. Error classes: expected_action_mismatch, action_order_mismatch, value_bluff_confusion.

- Mastery and Crucible placement:
- Mastery feeders: MS6, MS7, MS8, MS9 feed mastery layers after learner clears baseline accuracy in MS1-MS5.
- Crucible drill C1 3bet and 4bet discipline: purpose is stable preflop aggression decisions by position and opener context; constraints are deterministic spot sets and factual 1-2 line feedback.
- Crucible drill C2 Check-raise intent control: purpose is correct use of check-raise as value or bluff by board and toCall context; constraints are deterministic action legality and explicit expected-action checks.
- Crucible drill C3 River value versus bluff separation: purpose is disciplined final-street intent selection without solver phrasing; constraints are fixed scenario packs and deterministic incorrectness explanations.
- Crucible drills are only introduced after mastery feeders; they do not alter early onboarding worlds.

- Acceptance rubric mapped to S0-S5 (PASS criteria):
- S0 PASS: world/module/session structure is complete and loadable under canonical content paths with deterministic ids and links.
- S1 PASS: each micro-session has 6-12 decisions (target 8 here), legal action sets, expected actions, and factual feedback lines present.
- S2 PASS: pedagogy is coherent end-to-end, terminology is consistent, no contradictory instruction or progression jumps.
- S3 PASS: poker correctness holds across legality/order/value-bluff logic, with no factual rule violations.
- S4 PASS: balanced coverage across core error classes, deterministic validator/test/telemetry gates pass, no drift into solver language.
- S5 PASS: Gold World package is template-ready for rollout and includes maintenance notes for repeatable authoring.
- Two-person requirement: S2 and S3 must be approved by two independent reviewers before merge.

- Rollout readiness checklist (2-world pilot):
- Gold World accepted at S0-S5 with documented rationale for structure and error taxonomy.
- Pilot worlds selected and mapped to the same micro-session and mastery/crucible template.
- Pilot scope explicitly preserves deterministic feedback style and factual wording constraints.
- QA gate runbook is updated so pilot worlds must pass the same S0-S5 thresholds.
- Rollout kickoff is blocked until S2+S3 two-person approvals are recorded for Gold and both pilot candidates.

## R7 checkpoint status (current)
- World2 canonical status (Policy Truth v1): implemented.
- World2 canonical coverage:
- explicit expected + why_v1 completion across World2 sessions and crucibles.
- acceptable_actions runtime support is active, and World2 acceptable_actions content is tuned.
- soft-pass copy uses policy-based wording and avoids solver/optimal phrasing.
- Rollout coverage:
- World3: MS1-MS10 complete.
- World4: MS1-MS10 complete.
- Worlds 3-10 canonicalization: complete (MS1-MS10 for each world), with transition checkpoints complete for w4-w6, w6-w7, w7-w8, w8-w9, and w9-w10.
- Cover-grade Worlds 1-2 checkpoint: complete.
- World1: one-time intro prelude covers positions and action order.
- World1: preflop SB/BB in-hand truth is fixed and contract-guarded.
- World2: one-time training intro and world1->world2 handoff hint are active.
- World2: seat-quiz gold contracts lock 6-seat clockwise loop and instruction-target match.
- World2: incorrect seat taps show visible Incorrect/Expected/You chose outcome messaging.
- World2: correct seat taps auto-advance with no continue gate.
- World2: action-decision slice v1 includes flop board visibility contract coverage.
- Gates: Tier0 green and deterministic contracts present.

## World2 Two-Person S2+S3 Review Packet v1
- Review roles and rule:
- Two-person review is mandatory before merge: one S2 reviewer (consistency and coherence) and one S3 reviewer (poker and pedagogy correctness).
- Both reviewers must approve; single-review approval is not valid for Gold World acceptance.

- S2 checklist (consistency and internal coherence):
- Verify every World2 session and crucible decision record includes prompt, expected, feedback_correct_v1, feedback_incorrect_v1, and error_class.
- Verify each decision id is unique within its drills index and matches its d.<id>.json filename.
- Verify each session and crucible drills/index.md maps to existing drill files with no missing entries.
- Verify per-session error_class sets stay bounded and intentional (no uncontrolled class explosion).
- Verify prompts are deterministic (no maybe, no optional branching language, no ambiguous action wording).
- Verify expected actions are explicit and legal branch names only (call, fold, raise).
- Verify feedback lines are exactly factual outcome statements and do not conflict with expected action.
- Verify no contradictory instructions across MS1-MS10 for the same context type.
- Verify mastery feeders are explicitly marked in MS6-MS9 session text and notes.
- Verify crucibles are explicitly marked as mastery-layer only and not onboarding replacements.
- Verify World2 sessions index remains contiguous and coherent for w2.s01..w2.s10.
- Verify crucibles are reachable via gauntlet entry and listed in world2 crucibles index.
- Verify all player-facing text is ASCII-only and free of placeholder TODO text.
- Verify no schema drift in drill JSON key names versus existing World2 keys.

- S3 checklist (poker correctness and pedagogy correctness):
- Verify seat and street anchors in prompts match expected seat_tap or board_tap targets.
- Verify action-order context is correct for position references (button, blinds, early seats).
- Verify toCall pressure nodes map to legal call/fold/raise responses only.
- Verify checkback control nodes are not labeled as aggression nodes, and vice versa.
- Verify value-intent nodes and bluff-intent nodes are not mixed in the same decision.
- Verify fold nodes are used only where pressure context and price framing justify release.
- Verify raise nodes correspond to approved pressure/value branches for the scenario.
- Verify call nodes correspond to priced-continue or control-checkback branches as defined.
- Verify feedback_incorrect_v1 states factual mismatch with scenario, not motivational coaching.
- Verify there is no solver jargon and no wording like GTO says or solver output references.
- Verify World2 content stays aligned to ULA World2 intent (price, board, street linkage) and does not regress to World0 or World1 onboarding assumptions.
- Verify crucibles C1-C3 express the intended concepts only: 3bet/4bet discipline, check-raise intent control, river value versus bluff separation.
- Verify no decision requires hidden assumptions outside provided seat/street/action context.
- Verify pedagogical progression from MS1-MS10 into C1-C3 remains coherent and deterministic.

- Evidence pointers (reviewer inspection paths):
- World2 sessions: content/worlds/world2/v1/sessions/w2.s01..w2.s10/
- World2 session index: content/worlds/world2/v1/sessions/index.md
- World2 crucibles root: content/worlds/world2/v1/crucibles/
- Crucible index: content/worlds/world2/v1/crucibles/index.md
- Crucible C1 path: content/worlds/world2/v1/crucibles/c1_3bet_4bet_discipline/
- Crucible C2 path: content/worlds/world2/v1/crucibles/c2_check_raise_intent_control/
- Crucible C3 path: content/worlds/world2/v1/crucibles/c3_river_value_bluff_separation/
- Crucible reachability entry: content/gauntlets/world2_crucibles_v1/v1/gauntlet.md

- Issue log template:
| item_id | severity | file_path | excerpt | expected_fix | owner | status |
| --- | --- | --- | --- | --- | --- | --- |
| S2-001 | blocker\|major\|minor\|nit | content/... | one-line excerpt | concrete fix | reviewer/author | open\|fixed\|verified |

- PASS criteria and merge gate:
- S2 PASS requires: 0 blocker issues; all major issues fixed and verified; minor and nit issues logged with explicit disposition.
- S3 PASS requires: 0 blocker issues; 0 unresolved major poker-correctness issues; all legality/order/value-bluff mismatches fixed and verified.
- Two-person gate requires signed S2 PASS and signed S3 PASS recorded in the review packet.
- Merge gate: Gold World merge is blocked until S2 and S3 both PASS.
- Rollout gate: no rollout to other worlds is allowed until this two-person PASS gate is achieved for World2.

## Counter (R7) — 0..100
### R7 Weights (100)
1) Gold World selection + content spec + acceptance rubric — 15
2) Gold World deep rewrite: atoms + micro-sessions + drills/demos/quiz/recap, with S1-S4 QA — 35
3) Error taxonomy + explanation mapping for strategic actions (3bet/4bet, check-raise, value/bluff) WITHOUT solver language — 15
4) Rollout plan + 2-world pilot (apply Gold rubric) — 20
5) Test/telemetry + content QA gates updated to cover new deep drills — 15

## R7 DoD
- Gold World is completed at rubric quality and accepted as canonical reference.
- Two-world pilot validates rollout quality using the same rubric and QA bars.
- Strategic error taxonomy/explanations are deterministic, human-readable, and solver-language-free.
- Content QA and telemetry/test gates cover new deep drill patterns end-to-end.

## R7 STOP rules
- STOP on any surface-fill approach that skips deep rewrite quality requirements.
- STOP if two-person S2+S3 review is not satisfied per Content System.
- STOP if required ULA/CONTENT_SYSTEM/PROJECT_RULES_VFINAL constraints would be violated.

---

# Milestone R8 — Track Specialization v1 (Cash / Tournament / Mixed)
- Goal: after World10 completion, learner picks a specialization track; each track has its own early spine modules (v1).
- Scope v1: microcopy + routing + first 3 sessions per track (content-only); no economy or gamification expansion.
- Track choice + routing + sessions1-3 per track shipped; guards green.
- Guardrails: deterministic behavior, reuse existing pack ids, no schema changes, and gates stay green via:
- `dart run tools/validate_world_content_v1.dart`
- `dart run tools/run_content_qa_r2_v1.dart`
- `./tools/fast_loop_world1_v1.sh`

---

# Milestone R9 — Release Candidate Hardening v1 (Cover-grade E2E)
- Goal: make the app release-candidate stable and coherent from onboarding through track followups.
- Goal: close the remaining P0/P1 UX and logic gaps with deterministic contracts and no regressions.
- P0.1-P0.5 complete; contracts green; RC hardening v1 done.
- Status: completed (closed).

## Scope (strict)
- Fix remaining P0/P1 UX and logic gaps in Worlds 1-2 runner and track entry flow.
- Ensure no dead ends across: onboarding -> world1 -> world2 -> world10 -> track choice -> track s01..s03 -> return.
- Deterministic-only changes; no new dependencies; no schema changes.

## P0 items (ordered)
- P0.1 End-to-end navigation contract: world10 completion -> chooser -> selected track -> s01 playable -> s02 -> s03 -> result.
- P0.2 Runner truth invariants: pot/toCall/board/street/seat-in-hand visibility remain correct across preflop and postflop.
- P0.3 Messaging polish contract: no solver/optimal wording; soft-pass copy and why_v1 surfaces are present and factual.
- P0.4 Performance guard: tap-to-outcome first-frame latency stays within target using existing debug instrumentation.
- P0.5 No-dead-end return path: result and map/back actions remain deterministic after track session completion.

## R9 DoD
- Tier0 is consistently green.
- Release gate script is green when used (`./tools/release_gate_world1.sh`), otherwise required fast gates are green.
- No open P0/P1 issues at release-candidate cut.
- Contract coverage includes: track choice routing, track chaining, world2 seat-quiz loop, postflop board visibility, and pot invariants.

## Gates
- Always: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- For content changes: `dart run tools/validate_world_content_v1.dart` and `dart run tools/run_content_qa_r2_v1.dart`.
- Tier2/checkpoint gates are required only on checkpoint cadence or release-candidate checkpoint.

---

# Milestone R10 — Planning Lock v1 (Release Roadmap Extension)
- Status: completed (closed).

## Goal
- Freeze RC Definition v2 as a non-negotiable quality contract for release work.
- Extend the roadmap with strict sequencing and stop rules across R11-R14.

## Scope (strict)
- Docs-only milestone. No runtime/content/tooling changes are executed inside R10.
- Define release policy, backlog boundaries, and sequencing constraints only.

## P0 items (ordered)
- P0.1 Define "Release Candidate Definition v2": what 100% means, must-pass flows, P0/P1 policy, and required gates.
- P0.2 Define "Post-RC Backlog Buckets" and lock the rule: no pulling backlog work early.
- P0.3 Define Milestones R11-R14 with title, scope, ordered P0 items, DoD, gates, and stop rules.

## R10 DoD
- R10 section exists and is internally consistent with R7-R9 outputs.
- R11-R14 sections exist with ordered P0 items and explicit stop rules.
- Milestone switching line remains `ACTIVE=R10; NEXT=R11`.

## R10 stop rules
- STOP if R10 introduces implementation tasks beyond docs planning.
- STOP if RC Definition v2 conflicts with existing hard gates or determinism policy.

---

# Milestone R11 — Track Expansion v1 (Sessions 4-10 per track)
- Status: completed (closed).

## Scope (strict)
- Content-only under existing track roots (cash/tournament/mixed).
- No runtime routing changes, no schema changes, no dependency changes.

## P0 items (ordered)
- P0.1 Implement sessions s04-s10 for cash/tournament/mixed using canonical template.
- P0.2 Add a single audit report that verifies reachability and counts per track.
- P0.3 Add transition checkpoint microcopy between early and expanded track sessions.

## DoD and gates
- Track content validators and QA are green.
- Tier0 remains green after content merge.
- One deterministic audit document exists and references final counts.

## R11 stop rules
- STOP if runtime changes are required.
- STOP on validator/QA failures.

---

# Milestone R12 — Onboarding + Aha Loop v1
- Status: completed (closed).

## Scope (strict)
- Microcopy and lightweight one-time overlays only, table-first and non-blocking.
- No encyclopedia copy, no new mechanics, no dependency changes.

## P0 items (ordered)
- P0.1 Improve first-run clarity for positions/action order and street turn order.
- P0.2 Explain silent-until-error behavior and what progress to expect.
- P0.3 Clarify track meaning at handoff points with deterministic one-time hints.

## DoD and gates
- Reduced first-run confusion in QA rubric and audit notes.
- Deterministic behavior remains intact; no new gates introduced.
- Tier0 stays green across all overlay and copy changes.

## R12 stop rules
- STOP if overlays block taps or add continue-gate friction.
- STOP if copy violates policy-truth wording constraints.

---

# Milestone R13 — RC Cut + Store Package v1
- Status: completed (closed).

## Scope (strict)
- Release gate checklist, versioning, final audit reports, and regression locks.
- No feature expansion outside RC criteria.

## P0 items (ordered)
- P0.1 Run RC gates and checkpoint cadence suite; record outputs.
- P0.2 Produce final RC audit report with SSOT contract evidence.
- P0.3 Mark RC definition/tag state in SSOT and release docs.

## DoD and gates
- RC gates are green and documented.
- Final RC report is merged and references all required contract suites.
- Release metadata and rollback pointers are complete.

## R13 stop rules
- STOP on any open P0/P1.
- STOP if required RC evidence is missing.

---

# Milestone R14 — Post-RC Backlog Activation

## Scope (strict)
- Activate only after RC cut completion.
- Allow selected backlog buckets by EV: localization, gamification, extra worlds, and polish streams.

## P0 items (ordered)
- P0.1 Prioritize backlog buckets with explicit EV ranking.
- P0.2 Define per-bucket guards that protect RC core flows.
- P0.3 Execute one bucket at a time with checkpoint validation.

## DoD and gates
- RC core contracts remain green during backlog work.
- Active bucket and stop rules are visible in SSOT.
- Tier0 remains mandatory for every backlog batch.

## R14 stop rules
- STOP if RC core flow regressions appear.
- STOP if bucket work bypasses EV prioritization.

---

# Milestone R15 — New Drill Formats v1 (Sizing + Classifiers)

## Goal
- Add three new drill formats that increase learning EV without solver jargon.

## Scope v1
- `bet_sizing_choice_v1`: preset buttons only, deterministic buckets, no float math.
- `board_texture_classifier_v1`: dry/wet/pair/connect cues mapped to action choices.
- `range_bucket_classifier_v1`: strong/medium/weak/draw/missed buckets mapped to action choices.

## Guardrails
- Deterministic only; no RNG or time-based logic checks.
- No new dependencies.
- Schema change is allowed only if tooling + runtime + tests ship in the same milestone batch.

## P0 items (ordered)
- P0.1 Define minimal JSON contract keys for each new drill type.
- P0.2 Add tooling validators and ingest support.
- P0.3 Add runtime evaluator and table-first UI integration.
- P0.4 Ship one Gold module per drill type and one audit report.

## DoD
- Tier0 is green.
- New drill types are covered by contract tests.
- Each Gold module is playable end-to-end (start -> decision -> feedback -> result -> return).
- "Legal but worse" messaging works where applicable.

## R15 stop rules
- STOP on Tier0 red.
- STOP on partial schema rollout without matching tooling/runtime/tests.

---

# Milestone R16 — Multi-step Hand Chains v1 (2-4 decisions)

Status: completed (closed).

## Goal
- Teach planning across streets (preflop -> flop -> turn/river) using deterministic chains.

## Scope v1
- 2-4 decisions per chain.
- Deterministic FSM only.
- No RNG and no side-pot support in v1.

## P0 items (ordered)
- P0.1 Define chain data contract (snapshot + ordered steps).
- P0.2 Implement runtime chain runner with contract tests (ordering and pot/toCall invariants).
- P0.3 Ship one Gold chain module and one audit report.

## DoD
- Chain traversal is deterministic.
- No dead ends in chain progression and return path.
- Performance is acceptable under existing Tier0 guard policy.

## R16 stop rules
- STOP if chain runner breaks existing single-step flows.
- STOP on invariant failures (ordering, pot, toCall, or dead-end navigation).

---

# Milestone R17 — Mastery & Checkpoints v1 (Review Loop)

Counter — R17 100/100 (+25%)

Status: completed (closed).

## Goal
- Prevent empty clicking by adding periodic checkpoints and targeted review.

## Scope v1
- Checkpoint every 3-5 sessions.
- Short recap plus top-3 error-class review queue.

## P0 items (ordered)
- P0.1 Define checkpoint trigger rules (content tags where possible).
- P0.2 Add minimal result-screen UI with one primary CTA.
- P0.3 Ship one Gold checkpoint implementation and one audit report.

## DoD
- Review loop is measurable and deterministic.
- No UI clutter or CTA ambiguity is introduced.
- Checkpoint path is contract-covered and dead-end free.

## R17 stop rules
- STOP if checkpoint logic introduces nondeterministic routing.
- STOP if result-screen UI adds competing primary actions.

## Evidence
- Checkpoint trigger and top-3 error queue with deterministic tie-break are implemented in `ProgressService`.
- Checkpoint routing uses dedicated pack `season1_checkpoint_global_v1` via `SessionResultScreen` + `ProgressService`.
- Checkpoint runner consumes seed deterministically and shows cue "Checkpoint: review your top mistakes."
- Map-first checkpoint entry surface appears when pending and is contract-covered by map guard test.

---

# Milestone R18 — Mastery & Checkpoints UX v1 (User-visible Loop)

Counter — R18 100/100 (+25%)

Status: completed (closed).

## Goal
- Make the checkpoint loop discoverable, readable, and motivating without UI clutter.

## Scope v1 (strict)
- Map: keep pending strip + explicit checkpoint CTA as final copy/placement.
- Runner: keep checkpoint UX minimal and clear (`Step X of 6` + checkpoint cue).
- Result: keep single-CTA flow and deterministic return-to-map after checkpoint completion.
- No new schemas, no economy/gamification expansion, deterministic-only behavior.

## P0 items (ordered)
- P0.1 Lock map checkpoint entry UX (copy, placement, key contract) and prevent regression.
- P0.2 Lock checkpoint runner cue/step semantics (`Step 1 of 6`, checkpoint cue visible).
- P0.3 Lock checkpoint completion return path (checkpoint complete -> map, no dead ends).
- P0.4 Publish short R18 UX audit with contract pointers and open-risk list (must be empty for closeout).

## DoD
- Map shows checkpoint strip only when `checkpointPending=true`.
- Map strip CTA opens `season1_checkpoint_global_v1` deterministically.
- Checkpoint runner shows step counter and checkpoint cue in stable surfaces.
- Checkpoint flow remains single-primary-CTA; no competing start surfaces.
- Completing checkpoint clears pending and returns to map deterministically.
- No dead-end routes across map -> checkpoint -> result -> map loop.
- Tier0 remains green on final diff.
- No open P0/P1 issues at milestone close.

## Gates
- Always: `flutter analyze`
- Always: `./tools/fast_loop_world1_v1.sh`
- Content validators (`validate_world_content_v1`, `run_content_qa_r2_v1`) only if content files are touched.

## R18 stop rules
- STOP on any Tier0 red.
- STOP on deterministic routing/state regressions.
- STOP if any P0/P1 remains open.

## Evidence
- Map checkpoint strip is pending-only and opens `season1_checkpoint_global_v1` via explicit CTA.
- Runner keeps stable checkpoint semantics (`Step 1 of 6` + checkpoint cue) under contract tests.
- Completion path clears checkpoint pending and preserves deterministic return/no-dead-end routing.
- Audit: `docs/_reviews/r18_mastery_checkpoints_ux_audit_v1.md`.

## Counter rubric
- `25%`: map pending strip + CTA contract locked.
- `50%`: runner checkpoint cue + step semantics contract locked.
- `75%`: completion return-to-map loop locked, no dead ends.
- `100%`: audit published, Tier0 green, zero open P0/P1.

---

# Milestone R19 — Checkpoint Content Quality v1 (Targeted Review Accuracy)

Counter — R19 100/100 (+50%)

Status: completed (closed).

## Goal
- Improve checkpoint review quality so repeated mistakes are addressed with clear, table-first practice.

## Scope v1 (strict)
- Keep checkpoint loop deterministic and map-first (no new entry surfaces).
- Improve checkpoint slice quality using existing drill contracts and error_class mapping.
- Keep single-primary-CTA behavior across map -> checkpoint runner -> result -> map.
- No new schemas, no new dependencies, no gamification/economy expansion.

## P0 items (ordered)
- P0.1 Audit checkpoint drill selection coverage against top-3 error classes and deterministic ordering.
- P0.2 Add/adjust minimal contract tests for checkpoint slice quality where coverage gaps exist.
- P0.3 Tune checkpoint pack/runtime selection logic only if P0.1/P0.2 reveal a deterministic mismatch.
- P0.4 Publish R19 quality audit and close milestone only when open-risk list is empty.

## DoD
- Top-3 seeded error classes map to checkpoint drill selection deterministically.
- Checkpoint slice stays stable in count/order under identical seed input.
- Checkpoint flow remains no-dead-end and single-primary-CTA.
- Tier0 is green on final behavior-lock diff.
- No open P0/P1 issues remain at closeout.

## Gates
- Always: `flutter analyze`
- Always: `./tools/fast_loop_world1_v1.sh`
- Content validators (`validate_world_content_v1`, `run_content_qa_r2_v1`) only if content files are touched.

## R19 stop rules
- STOP on any Tier0 red.
- STOP on deterministic ordering/selection regressions.
- STOP if any P0/P1 remains open.

## Counter rubric
- `25%`: checkpoint seed-to-selection audit completed with evidence.
- `50%`: missing checkpoint quality contracts added and green.
- `75%`: deterministic selection mismatches fixed (if any) and re-verified.
- `100%`: R19 audit published, Tier0 green, zero open P0/P1.

## Evidence
- Seed source and deterministic top-3 ranking are implemented in `ProgressService`.
- Checkpoint selection order/count/fallback are implemented in `buildCheckpointSeededDrillsV1`.
- P0.2 edge contracts are green for idempotent seed runs and unknown/empty fallback.
- Audit: `docs/_reviews/r19_checkpoint_content_quality_audit_v1.md`.

---

# Milestone R20 — Release Spine Audit v1 (Ship-Critical Gap Cut)

Counter — R20 100/100 (+100%)
Status: completed (closed).

## Goal
- Produce an evidence-based release spine that answers what is ship-critical now vs what is deferred.

## Scope v1 (strict)
- Audit-only pass over current runtime, contracts, content integrity, and release gates.
- Classify gaps into P0/P1/P2 with hard prioritization and anti-drift constraints.
- No runtime/content/schema/dependency changes in R20 by default.
- Close R20 only after audit evidence and an explicit ship-distance estimate.

## P0 items (ordered)
- P0.1 Define and lock R20 audit contract in SSOT (goal, scope, DoD, gates, stop rules, rubric).
- P0.2 Publish release spine audit with exact evidence for onboarding, map/path, runner correctness, result loop, checkpoint loop, track routing, content validity, and deterministic routing.
- P0.3 Produce ranked P0/P1/P2 gap list with top-3 highest-EV actions and anti-drift "do not work on" verdict.
- P0.4 Estimate remaining distance to first launch-worthy release in bounded slices and set next execution focus.

## DoD
- One R20 audit document exists with explicit evidence pointers and severity-ranked gaps.
- Ship-critical blockers (if any) are listed as P0 with no ambiguity.
- Non-critical polish work is explicitly marked deferred.
- A bounded remaining-distance estimate is provided (not vague prose).
- SSOT remains internally consistent with one authoritative execution line.

## Gates
- Doc-only default: no test runs required.
- If executable changes are introduced (exception-only): `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.

## R20 stop rules
- STOP if audit conclusions are not evidence-backed.
- STOP if scope drifts into runtime/content changes without a documented blocker.
- STOP if P0/P1/P2 classification is ambiguous or non-actionable.

## Counter rubric
- `25%`: R20 SSOT definition is complete and consistent.
- `50%`: release spine audit published with evidence coverage across all required surfaces.
- `75%`: ranked P0/P1/P2 list plus top-3 action plan and anti-drift verdict are complete.
- `100%`: bounded distance-to-launch estimate is set and next execution focus is unblocked.

## Evidence
- Audit: `docs/_reviews/r20_release_spine_audit_v1.md`.
- Truth reconciliation: `docs/_reviews/r20_release_truth_reconciliation_v1.md`.
- Slice A closure: `docs/_reviews/r20_entitlement_paywall_matrix_v1.md`.

---

# Milestone R21 — Launch Closure Execution v1 (Checklist + Final Verdict)

Counter — R21 100/100 (+100%)
Status: completed (closed).

## Goal
- Complete the minimum remaining launch-closure sequence and publish a final go/no-go verdict.

## Scope v1 (strict)
- Execute only Slice B and Slice C from the corrected launch spine.
- Slice A is already complete and used as fixed evidence input.
- Doc-first by default; executable changes allowed only if checklist evidence proves a concrete blocker.
- No new product scope, schemas, or dependencies.

## P0 items (ordered)
- P0.1 Publish one consolidated launch checklist artifact (single authoritative go/no-go source).
- P0.2 Run final reconciliation against current main and publish launch verdict (PASS/BLOCKED) with explicit open-risk list.
- P0.3 If BLOCKED, list only bounded blocker fixes; if PASS, freeze scope and prepare launch cut.

## DoD
- Consolidated launch checklist exists and references all ship-critical proof points.
- Final launch verdict doc exists with explicit PASS/BLOCKED status.
- Open-risk list is empty for PASS, or explicitly bounded for BLOCKED.
- One authoritative execution line remains in SSOT.

## Gates
- Doc-only default: no test runs required.
- If executable changes are introduced: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.

## R21 stop rules
- STOP if scope expands beyond checklist/reconciliation closure.
- STOP if conclusions are not evidence-backed.
- STOP if new product work is proposed before launch verdict is finalized.

## Counter rubric
- `25%`: milestone definition aligned to corrected launch spine and Slice A recorded as complete input.
- `50%`: consolidated launch checklist published.
- `75%`: final reconciliation run documented with explicit open-risk list.
- `100%`: final launch verdict published and next execution focus unblocked.

## Evidence
- Consolidated checklist: `docs/_reviews/r21_launch_checklist_v1.md`.
- Final verdict: `docs/_reviews/r21_launch_verdict_v1.md` (`GO`).
- Gate evidence recorded in checklist/verdict (`flutter analyze`, `fast_loop`, `release_gate_world1` all PASS).

---

# Milestone R22 — Post-Launch Stabilization Audit v1 (Production Reality Lock)

Counter — R22 100/100 (+25%)

Status: completed (closed).

## Goal
- Validate post-launch production reality against launch assumptions and lock only high-EV stabilization actions.

## Scope v1 (strict)
- Audit-only pass over launch-critical behavior in real usage signals (routing, checkpoint loop, entitlement/paywall interactions, and gate health).
- Classify findings into P0/P1/P2 with strict anti-drift boundaries.
- No new feature scope, schema changes, or dependency additions by default.

## P0 items (ordered)
- P0.1 Publish a production-reality audit with evidence for route integrity, checkpoint behavior, and entitlement/paywall stability.
- P0.2 Define and prioritize only bounded stabilization fixes (if any), with deterministic contract impact noted.
- P0.3 Publish a post-launch execution plan that separates immediate stabilization from deferred expansion.

## DoD
- One R22 audit artifact exists with explicit evidence-backed findings.
- Any launch-critical regression is labeled P0 with a bounded fix path.
- If no launch-critical regressions exist, this is explicitly stated with zero false blockers.
- One authoritative execution line remains in SSOT.

## Gates
- Doc-only default: no test runs required.
- If executable changes are introduced: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.

## R22 stop rules
- STOP if conclusions are based on assumptions rather than evidence.
- STOP if scope drifts into feature expansion or redesign.
- STOP if stabilization backlog is not severity-ranked and bounded.

## Counter rubric
- `25%`: R22 scope and audit contract are locked in SSOT.
- `50%`: production-reality audit is published with severity-ranked findings.
- `75%`: bounded stabilization plan is published with deterministic guard expectations.
- `100%`: post-launch execution focus is unblocked with zero ambiguous P0 status.

## Evidence
- Production reality audit: `docs/_reviews/r22_production_reality_audit_v1.md`.
- Stabilization plan: `docs/_reviews/r22_stabilization_plan_v1.md`.
- Post-launch focus: `docs/_reviews/r22_post_launch_execution_focus_v1.md`.
- Included stabilization slice closed by deterministic contracts:
  - `test/services/subscription_status_v1_test.dart`
  - `test/payments/payment_service_restore_verification_policy_v1_test.dart`
  - commit `464f915f1` (`flutter analyze` PASS, `./tools/fast_loop_world1_v1.sh` PASS).
- R23 milestone section is not yet defined in SSOT and must be defined before R23 execution work begins.

---

# Milestone R23 — Post-Launch Reliability Loop v1 (Ops + Contracts)

Counter — R23 100/100 (+25%)

Status: completed (closed).

## Goal
- Improve post-launch reliability with bounded operational hardening, using existing deterministic contracts and gate discipline.

## Scope v1 (strict)
- Validate and tighten operational release hygiene around existing flows (no feature expansion).
- Convert recurring gate/process friction into explicit, deterministic runbook rules and checklist updates.
- Keep product behavior unchanged unless a bounded regression is proven by existing contracts.

## P0 items (ordered)
- P0.1 Publish an operational reliability baseline doc with recurring failure modes and deterministic handling rules.
- P0.2 Lock one bounded reliability contract/process improvement that reduces gate-block recurrence.
- P0.3 Publish a closeout audit with open-risk list and explicit defer list for non-reliability work.

## DoD
- R23 reliability baseline and closeout artifacts exist with evidence pointers.
- Included reliability slice is closed with deterministic proof (or explicitly blocked with one bounded cause).
- No new runtime/product scope is introduced without a proven regression.
- One authoritative execution line remains in SSOT.

## Gates
- Doc-only default: no test runs required.
- If executable changes are introduced: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.

## R23 stop rules
- STOP if scope drifts into feature roadmap work or architecture redesign.
- STOP if reliability conclusions are not evidence-backed.
- STOP if included slice is not bounded to one deterministic closure target.

## Counter rubric
- `25%`: R23 scope and reliability baseline contract are locked in SSOT.
- `50%`: baseline reliability artifact is published with ranked operational risks.
- `75%`: included bounded reliability slice is implemented/proven.
- `100%`: closeout audit published with zero ambiguous P0 status and next focus unblocked.

## Evidence
- Baseline: `docs/_reviews/r23_operational_reliability_baseline_v1.md`.
- Included slice closure: `docs/_reviews/r23_formatter_gate_hardening_v1.md`.
- Closeout audit: `docs/_reviews/r23_reliability_closeout_audit_v1.md`.
- Next focus handoff: `docs/_reviews/r23_next_execution_focus_v1.md`.
- Included slice closure commit: `0a03ab6a0` (`ops+docs: r23 formatter gate hardening v1`).

---

# Milestone R24 — Personalization / Profile EV Layer v1 (Rule-Based Adaptation)

Counter — R24 100/100 (+25%)
Status: completed (closed).

## Goal
- Start the first bounded personalization layer so the trainer adapts next-best practice to the current player profile using existing deterministic data/contracts.

## Scope v1 (strict)
- Rule-based only personalization (no ML, no model-training scope).
- Use existing telemetry/progress/error-class signals to derive weak-area priority.
- Apply profile-backed prioritization to next-best followup/review ordering only.
- No new feature-family expansion, no schema redesign, no content-scaling or UX-cohesion programs.

## P0 items (ordered)
- P0.1 Publish a profile EV baseline audit: current signals, candidate weak-area rules, deterministic precedence/tie-break policy.
- P0.2 Implement one bounded rule-based prioritization slice for next-best followup selection using existing data surfaces.
- P0.3 Add/extend deterministic contracts proving stable profile-driven ordering under identical inputs.
- P0.4 Publish closeout audit with open-risk/defer list and transition note for next personalization increment.

## DoD
- One profile EV baseline artifact exists with explicit evidence and bounded rules.
- Included personalization slice is shipped with deterministic contract coverage.
- No schema changes, no dependency additions, and no feature-family scope drift.
- Open-risk list is explicit and non-included work is deferred.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.
- Doc-only passes in this milestone may skip tests when no executable changes are made.

## R24 stop rules
- STOP if scope drifts into content scaling, UX cohesion, expansion/gamification/localization, architecture redesign, or ML systems.
- STOP if prioritization logic is not deterministic under identical input state.
- STOP if slice expands beyond one bounded personalization closure target.

## Counter rubric
- `25%`: profile EV baseline and deterministic rule contract are published.
- `50%`: one bounded rule-based prioritization slice implemented.
- `75%`: deterministic contract coverage for profile-driven ordering is green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline: `docs/_reviews/r24_profile_ev_baseline_v1.md`.
- P0.2 implementation: `238b91e73` (`runtime+test: r24 checkpoint fallback focus v1`).
- P0.3 contract lock: `0199d3d02` (`test: r24 p0.3 profile fallback contracts v1`).
- Closeout audit: `docs/_reviews/r24_personalization_closeout_audit_v1.md`.
- Next execution focus: `docs/_reviews/r24_next_execution_focus_v1.md`.

---

# Milestone R25 — Personalization / Profile EV Layer v2 (Deterministic Signal Layer)

Counter — R25 100/100 (+100%)
Status: completed (closed).

## Goal
- Ship one additional bounded rule-based personalization refinement on top of R24 to improve next-best followup/review prioritization using existing deterministic signals/contracts.

## Scope v1 (strict)
- Add exactly one new deterministic signal layer into the existing precedence stack (no scoring engine expansion).
- Keep explicit precedence and tie-break policy deterministic under identical input state.
- Reuse existing data/contracts first; no schema redesign or dependency additions.
- No content scaling, UX cohesion programs, expansion/gamification/localization, architecture redesign, or ML scope.

## P0 items (ordered)
- P0.1 Publish R25 signal-layer baseline: candidate signal, precedence placement, tie-break contract, and bounded inclusion/exclusion.
- P0.2 Implement one bounded prioritization refinement using the selected deterministic signal layer.
- P0.3 Add deterministic contracts proving ordering stability, precedence safety, and fallback preservation with identical input state.
- P0.4 Publish closeout audit with open-risk/defer list and next increment transition note.

## DoD
- Exactly one new signal layer is integrated and contract-proven.
- Routing remains deterministic under identical state and preserves higher-priority paths.
- No schema/dependency/content/UI/feature-family drift enters scope.
- Open-risk list is explicit; non-included work is deferred.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.
- Doc-only passes may skip tests when no executable changes are made.

## R25 stop rules
- STOP if work expands beyond one bounded deterministic signal-layer refinement.
- STOP if precedence/tie-break behavior is not explicit and contract-covered.
- STOP on any drift into content scaling, UX cohesion, expansion tracks, architecture redesign, or ML systems.

## Counter rubric
- `25%`: R25 baseline and deterministic precedence contract are published.
- `50%`: one bounded signal-layer refinement is implemented.
- `75%`: deterministic ordering/precedence contracts are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline: `docs/_reviews/r25_signal_layer_baseline_v1.md`.
- P0.2 implementation: `61e9ba792` (`runtime+test: r25 focus-review-due fallback v1`).
- P0.3 contract lock: `28f994570` (`test: r25 p0.3 deterministic routing contracts v1`).
- Closeout audit: `docs/_reviews/r25_personalization_closeout_audit_v1.md`.
- Next execution focus: `docs/_reviews/r25_next_execution_focus_v1.md`.

---

# Milestone R26 — Personalization / Profile EV Layer v3 (Deterministic Prioritization Refinement)

Counter — R26 100/100 (+100%)
Status: completed (closed).

## Goal
- Ship one additional bounded deterministic personalization refinement on top of R25 that improves next-best followup/review prioritization using existing contracts and persisted signals only.

## Scope v1 (strict)
- Add exactly one rule-based prioritization refinement layer in the existing adaptive routing stack.
- Keep explicit precedence, tie-break, and fallback rules deterministic under identical input state.
- Reuse existing data/contracts first; no schema redesign, no dependency additions, no new scoring engine.
- No content scaling, UX/visual cohesion tracks, expansion/gamification/localization, architecture redesign, ML scope, or profile UI/dashboard expansion.

## P0 items (ordered)
- P0.1 Publish R26 signal-layer baseline: candidate layer inventory, one selected refinement target, precedence/tie-break/fallback contract.
- P0.2 Implement one bounded deterministic refinement using the selected signal layer in adaptive routing.
- P0.3 Add/extend deterministic contracts proving stable ordering, precedence safety, and fallback preservation under identical state/time inputs.
- P0.4 Publish closeout audit with open-risk/defer list and transition note for the next bounded personalization increment.

## DoD
- Exactly one additional deterministic refinement layer is integrated and contract-proven.
- Routing remains deterministic and preserves higher-priority paths without regression.
- No schema/dependency/content/UI/feature-family drift enters scope.
- Open-risk list is explicit and non-included work is deferred.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.
- Doc-only passes may skip tests when no executable changes are made.

## R26 stop rules
- STOP if work expands beyond one bounded deterministic personalization refinement.
- STOP if precedence/tie-break/fallback behavior is not explicit and contract-covered.
- STOP on any drift into content scaling, UX cohesion, expansion tracks, architecture redesign, ML, or profile UI expansion.

## Counter rubric
- `25%`: R26 baseline and deterministic precedence contract are published.
- `50%`: one bounded deterministic refinement is implemented.
- `75%`: deterministic ordering/precedence/fallback contracts are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- P0.2/P0.3 implementation + contracts: `1b0f99d16` (`runtime+test: r26 placement-score fallback v1`).
- Closeout audit: `docs/_reviews/r26_personalization_closeout_audit_v1.md`.
- Next execution focus: `docs/_reviews/r26_next_execution_focus_v1.md`.

---

# Milestone R27 — Personalization / Profile EV Layer v4 (Deterministic Routing Refinement)

Counter — R27 100/100 (+100%)
Status: completed (closed).

## Goal
- Ship one additional bounded deterministic personalization refinement on top of R26 to improve followup/review routing quality using existing persisted signals and contracts only.

## Scope v1 (strict)
- Add exactly one rule-based refinement layer in the current adaptive routing precedence stack.
- Keep precedence, tie-break, and fallback behavior explicit and deterministic under identical input/time state.
- Reuse existing data/contracts first; no schema redesign, no dependency additions, no scoring-engine expansion.
- No content scaling, UX/visual cohesion tracks, expansion/gamification/localization, architecture redesign, ML scope, or profile dashboard/UI expansion.

## P0 items (ordered)
- P0.1 Publish R27 signal-layer baseline: candidate refinement inventory, selected single target, and deterministic precedence/tie-break/fallback contract.
- P0.2 Implement one bounded deterministic refinement in adaptive routing using the selected existing signal layer.
- P0.3 Add/extend deterministic contracts proving ordering stability, higher-priority precedence safety, and fallback preservation.
- P0.4 Publish closeout audit with open-risk/defer list and transition note for the next bounded personalization increment.

## DoD
- Exactly one additional deterministic refinement layer is integrated and contract-proven.
- Routing remains deterministic and preserves all higher-priority paths without regression.
- No schema/dependency/content/UI/feature-family drift enters scope.
- Open-risk list is explicit and non-included work is deferred.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.
- Doc-only passes may skip tests when no executable changes are made.

## R27 stop rules
- STOP if work expands beyond one bounded deterministic personalization refinement.
- STOP if precedence/tie-break/fallback behavior is not explicit and contract-covered.
- STOP on any drift into content scaling, UX cohesion, expansion tracks, architecture redesign, ML, or profile UI expansion.

## Counter rubric
- `25%`: R27 baseline and deterministic precedence contract are published.
- `50%`: one bounded deterministic refinement is implemented.
- `75%`: deterministic ordering/precedence/fallback contracts are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- P0.2/P0.3 implementation + contracts: `9d2051220` (`runtime+test: r27 skill-band fallback v1`).
- Closeout audit: `docs/_reviews/r27_personalization_closeout_audit_v1.md`.
- Next execution focus: `docs/_reviews/r27_next_execution_focus_v1.md`.

---

# Milestone R28 — Personalization / Profile EV Layer v5 (Deterministic Followup Refinement)

Counter — R28 100/100 (+100%)
Status: completed (closed).

## Goal
- Ship one additional bounded deterministic personalization refinement on top of R27 to improve next-best followup/review routing quality using existing persisted signals/contracts only.

## Scope v1 (strict)
- Add exactly one rule-based refinement layer in the existing adaptive routing precedence stack.
- Keep precedence, tie-break, and fallback behavior explicit and deterministic under identical input/time state.
- Reuse existing data/contracts first; no schema redesign, no dependency additions, no scoring-engine expansion.
- No content scaling, UX/visual cohesion tracks, expansion/gamification/localization, architecture redesign, ML scope, or profile dashboard/UI expansion.

## P0 items (ordered)
- P0.1 Publish R28 signal-layer baseline: candidate refinement inventory, selected single target, and deterministic precedence/tie-break/fallback contract.
- P0.2 Implement one bounded deterministic refinement in adaptive routing using the selected existing signal layer.
- P0.3 Add/extend deterministic contracts proving ordering stability, higher-priority precedence safety, and fallback preservation.
- P0.4 Publish closeout audit with open-risk/defer list and transition note for the next bounded personalization increment.

## DoD
- Exactly one additional deterministic refinement layer is integrated and contract-proven.
- Routing remains deterministic and preserves all higher-priority paths without regression.
- No schema/dependency/content/UI/feature-family drift enters scope.
- Open-risk list is explicit and non-included work is deferred.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Content validators only if content files are touched.
- Doc-only passes may skip tests when no executable changes are made.

## R28 stop rules
- STOP if work expands beyond one bounded deterministic personalization refinement.
- STOP if precedence/tie-break/fallback behavior is not explicit and contract-covered.
- STOP on any drift into content scaling, UX cohesion, expansion tracks, architecture redesign, ML, or profile UI expansion.

## Counter rubric
- `25%`: R28 baseline and deterministic precedence contract are published.
- `50%`: one bounded deterministic refinement is implemented.
- `75%`: deterministic ordering/precedence/fallback contracts are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- P0.2/P0.3 implementation + contracts: `67dd20126` (`runtime+test: r28 skill-tags fallback v1`).
- Closeout audit: `docs/_reviews/r28_personalization_closeout_audit_v1.md`.
- Bottleneck decision handoff: `docs/_reviews/r29_bottleneck_audit_v1.md`.

---

# Milestone R29 — Execution Continuity Guard v1 (Weakest-Link Closure)

Counter — R29 100/100 (+100%)

Status: completed (closed).

## Goal
- Eliminate recurring execution churn where ACTIVE advances ahead of defined milestone scope, by adding bounded SSOT/process guardrails with deterministic checks.

## Scope v1 (strict)
- SSOT/process guard scope only: no runtime product behavior changes.
- Ensure milestone continuity: ACTIVE/NEXT must reference defined milestones and one authoritative execution line must exist.
- Add deterministic preflight/checklist guard for milestone-switch integrity and closure evidence presence.
- No personalization feature expansion, no content scaling, no UX cohesion tracks, no architecture redesign, no ML scope.

## P0 items (ordered)
- P0.1 Publish continuity baseline and recurrence inventory from recent milestones (R23-R28 evidence).
- P0.2 Add one bounded deterministic continuity guard (script/check) for SSOT milestone-definition and execution-line integrity.
- P0.3 Add minimum contract/process proof showing the guard fails on broken state and passes on valid state.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- One bounded continuity guard is in place and evidence-backed.
- ACTIVE/NEXT continuity rules are deterministic and enforceable.
- No product/runtime/content/schema scope drift entered.
- Open-risk/defer lists are explicit.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` for executable changes.
- Doc-only passes may skip tests when no executable changes are made.

## R29 stop rules
- STOP if work expands beyond SSOT/process continuity closure.
- STOP if scope drifts into personalization feature growth, content programs, UX cohesion, expansion tracks, architecture redesign, or ML.
- STOP if continuity checks are non-deterministic or ambiguous.

## Counter rubric
- `25%`: continuity baseline and recurrence inventory published.
- `50%`: bounded continuity guard implemented.
- `75%`: deterministic proof/contract for guard behavior is green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline and weakest-link decision: `docs/_reviews/r29_bottleneck_audit_v1.md`.
- Bounded continuity guard + preflight integration: `03f8ab2f5` (`tools: add ssot continuity guard v1`), `tools/ssot_continuity_guard_v1.sh`, `tools/release_preflight_world1.sh`.
- Closeout audit: `docs/_reviews/r29_execution_continuity_closeout_audit_v1.md`.
- Next focus handoff: `docs/_reviews/r29_next_execution_focus_v1.md`.

---

# Milestone R30 — Content/Explanation Sanity Guard v1 (Evidence-First Bottleneck Cut)

Counter — R30 100/100 (+100%)

Status: completed (closed).

## Goal
- Reduce the highest remaining post-R29 bottleneck by shipping one bounded deterministic content/explanation sanity guard that improves learning clarity without expanding feature scope.

## Scope v1 (strict)
- Content/explanation quality guard scope only; no runtime product feature expansion.
- Focus on deterministic validation/assembly discipline for explanation clarity (for example `why_v1` quality and contradiction/sanity checks) using existing content/tooling surfaces.
- Add exactly one bounded guardrail slice with actionable pass/fail output.
- No personalization layer expansion, no content scaling program, no UX cohesion/visual redesign, no gamification/localization expansion, no architecture redesign, no ML scope.

## P0 items (ordered)
- P0.1 Publish R30 baseline audit: current explanation/content friction inventory and candidate bounded guard options with EV ranking.
- P0.2 Select and implement exactly one deterministic content/explanation sanity guard in existing tools/docs flow.
- P0.3 Add minimum proof/contract coverage showing guard fail-on-broken and pass-on-valid behavior.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic content/explanation guard is implemented and proven.
- Guard output is actionable and deterministic under identical input state.
- No runtime product behavior/schema/dependency drift enters scope.
- Open-risk and defer lists are explicit.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` when executable files change.
- Run content validators when content or content-tooling surfaces are touched: `dart run tools/validate_world_content_v1.dart` and `dart run tools/run_content_qa_r2_v1.dart`.
- Doc-only passes may skip tests when no executable changes are made.

## R30 stop rules
- STOP if scope expands beyond one bounded deterministic content/explanation guard.
- STOP if work drifts into broad content rewrite, solver-like explanation generation, personalization expansion, UX cohesion tracks, architecture redesign, or ML scope.
- STOP if guard behavior or failure messaging is non-deterministic or non-actionable.

## Counter rubric
- `25%`: R30 baseline audit published with ranked candidate guard options.
- `50%`: one bounded deterministic guard implemented.
- `75%`: proof/contract coverage is green and deterministic.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- R29 weakest-link + R30 direction handoff: `docs/_reviews/r29_bottleneck_audit_v1.md`.
- Bounded guard implementation + targeted contract: `7dd59b06c` (`tools+test: r30 why_v1 placeholder guard v1`), `tools/why_v1_ssot_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Closeout audit: `docs/_reviews/r30_content_explanation_closeout_audit_v1.md`.
- Next focus handoff: `docs/_reviews/r30_next_execution_focus_v1.md`.

---

# Milestone R31 — Content/Explanation Sanity Guard v2 (Semantic Leak Fence)

Counter — R31 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV post-R30 bottleneck with one bounded deterministic explanation-sanity guard that reduces learning-friction copy errors without expanding product/runtime scope.

## Scope v1 (strict)
- Add exactly one deterministic content/explanation sanity guard on existing tooling surfaces.
- Target semantic leakage/sanity failures (for example prompt/answer leakage or similarly narrow explanation-sanity fault class) with deterministic actionable failure output.
- Reuse existing validators and content QA flow; no runtime product behavior changes.
- No personalization increment, no content scaling/rewrite program, no UX cohesion/visual expansion, no architecture redesign, no ML scope.

## P0 items (ordered)
- P0.1 Publish R31 baseline: bounded candidate guard options for explanation-sanity faults, with evidence-based selection.
- P0.2 Implement exactly one deterministic guard in the current tooling pipeline.
- P0.3 Add minimum proof/contract coverage for fail-on-broken and pass-on-valid behavior.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic explanation-sanity guard is implemented and proven.
- Guard behavior and failure output are deterministic and actionable.
- No runtime product/schema/dependency drift enters scope.
- Open-risk/defer lists are explicit.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` for executable changes.
- Run content validators when content/content-tooling surfaces are touched: `dart run tools/validate_world_content_v1.dart` and `dart run tools/run_content_qa_r2_v1.dart`.
- Doc-only passes may skip tests when no executable changes are made.

## R31 stop rules
- STOP if scope expands beyond one bounded deterministic explanation-sanity guard.
- STOP if work drifts into broad content rewrite/scaling, solver-like explanation generation, personalization expansion, UX cohesion tracks, architecture redesign, or ML scope.
- STOP if guard output is non-deterministic or non-actionable.

## Counter rubric
- `25%`: R31 baseline and selected bounded guard contract are published.
- `50%`: one deterministic explanation-sanity guard is implemented.
- `75%`: deterministic proof/contract coverage is green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Weakest-link decision and scope selection: `docs/_reviews/r31_bottleneck_audit_v1.md`.
- Bounded semantic-sanity guard implementation: `80ccb649f` (`tools+test: r31 feedback label mismatch guard v1`), `tools/why_v1_ssot_v1.dart`, `tools/validate_world_content_v1.dart`.
- Targeted proof: `test/tools/why_v1_ssot_v1_test.dart`.
- Closeout audit: `docs/_reviews/r31_content_explanation_closeout_audit_v1.md`.
- Next focus handoff: `docs/_reviews/r31_next_execution_focus_v1.md`.

---

# Milestone R32 — Content/Explanation Sanity Guard v3 (Prompt/Answer Leak Fence)

Counter — R32 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV post-R31 bottleneck by shipping one bounded deterministic explanation-sanity guard that blocks prompt/answer leakage patterns without expanding product/runtime scope.

## Scope v1 (strict)
- Add exactly one deterministic content/explanation sanity guard using existing tooling surfaces.
- Target one narrow leakage class (prompt/answer leakage or equivalent bounded semantic leak) with deterministic actionable failure output.
- Reuse existing validation/QA flow; no runtime product behavior changes.
- No personalization expansion, no content scaling/rewrite program, no UX cohesion/visual expansion, no architecture redesign, no ML scope.

## P0 items (ordered)
- P0.1 Publish R32 baseline: candidate bounded leakage guards and evidence-based single-target selection.
- P0.2 Implement exactly one deterministic leakage guard in current tooling flow.
- P0.3 Add minimum proof/contract coverage for fail-on-broken and pass-on-valid behavior.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic explanation-sanity guard is implemented and proven.
- Guard behavior and failure output are deterministic and actionable.
- No runtime product/schema/dependency drift enters scope.
- Open-risk/defer lists are explicit.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` for executable changes.
- Run content validators when content/content-tooling surfaces are touched: `dart run tools/validate_world_content_v1.dart` and `dart run tools/run_content_qa_r2_v1.dart`.
- Doc-only passes may skip tests when no executable changes are made.

## R32 stop rules
- STOP if scope expands beyond one bounded deterministic explanation-sanity guard.
- STOP if work drifts into broad content rewrite/scaling, solver-like explanation generation, personalization expansion, UX cohesion tracks, architecture redesign, or ML scope.
- STOP if guard output is non-deterministic or non-actionable.

## Counter rubric
- `25%`: R32 baseline and selected bounded guard contract are published.
- `50%`: one deterministic explanation-sanity guard is implemented.
- `75%`: deterministic proof/contract coverage is green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- R31->R32 continuity and bounded scope direction: `docs/_reviews/r31_next_execution_focus_v1.md`, `docs/_reviews/r31_bottleneck_audit_v1.md`.
- Bounded prompt/answer leakage guard implementation + targeted proof: `1e845aa4f` (`tools+content: add r32 prompt answer leak guard v1`), `tools/why_v1_ssot_v1.dart`, `tools/validate_world_content_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded content cleanup required by guard: `content/worlds/world3/v1/sessions/w3.s01/drills/d.choose_fold_first.json`, `content/worlds/world3/v1/sessions/w3.s01/drills/d.choose_raise_last.json`, `content/worlds/world3/v1/sessions/w3.s02/drills/d.choose_call_after_turn.json`, `content/worlds/world3/v1/sessions/w3.s02/drills/d.choose_fold_after_river.json`, `content/worlds/world3/v1/sessions/w3.s02/drills/d.choose_raise_trap.json`, `content/worlds/world3/v1/sessions/w3.s04/drills/d.choose_fold_repeat.json`, `content/worlds/world8/v1/sessions/w8.s02/drills/d.choose_raise_trap.json`.
- Closeout audit: `docs/_reviews/r32_content_explanation_closeout_audit_v1.md`.

---

# Milestone R33 — Content/Explanation Sanity Guard v4 (Action-Cue Leak Fence)

Counter — R33 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the highest-EV remaining post-R32 sanity gap with one bounded deterministic guard that prevents action-cue answer leakage patterns while keeping scope strictly tooling/content validation.

## Scope v1 (strict)
- Add exactly one deterministic content/explanation sanity guard using existing tooling surfaces.
- Target one narrow action-cue leak class (for example prompt patterns that trivially cue expected action labels) with deterministic actionable failure output.
- Reuse existing validation/QA flow and guard helpers first; no runtime product behavior changes.
- No personalization expansion, no broad content rewrite/scaling, no UX cohesion/visual expansion, no architecture redesign, no ML scope.

## P0 items (ordered)
- P0.1 Publish R33 baseline: candidate bounded action-cue leak guards and evidence-based single-target selection.
- P0.2 Implement exactly one deterministic action-cue leakage guard in current tooling flow.
- P0.3 Add minimum proof/contract coverage for fail-on-broken and pass-on-valid behavior.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic explanation-sanity guard is implemented and proven.
- Guard behavior and failure output are deterministic and actionable under identical content/input state.
- No runtime product/schema/dependency drift enters scope.
- Open-risk/defer lists are explicit.
- One authoritative execution line remains in SSOT.

## Gates
- Default: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` for executable changes.
- Run content validators when content/content-tooling surfaces are touched: `dart run tools/validate_world_content_v1.dart` and `dart run tools/run_content_qa_r2_v1.dart`.
- Add targeted proof run when guard tests are added/changed.
- Doc-only passes may skip tests when no executable changes are made.

## R33 stop rules
- STOP if scope expands beyond one bounded deterministic explanation-sanity guard.
- STOP if work drifts into broad content rewrite/scaling, semantic-policy engines, personalization expansion, UX cohesion tracks, architecture redesign, or ML scope.
- STOP if guard output is non-deterministic or non-actionable.

## Counter rubric
- `25%`: R33 baseline and selected bounded guard contract are published.
- `50%`: one deterministic explanation-sanity guard is implemented.
- `75%`: deterministic proof/contract coverage is green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Prior continuity and scope anchors: `docs/_reviews/r31_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r31_next_execution_focus_v1.md`, `docs/_reviews/r32_content_explanation_closeout_audit_v1.md`.
- Bounded action-cue leak guard implementation + targeted proof: `tools/why_v1_ssot_v1.dart`, `tools/validate_world_content_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded content cleanup required by guard: `content/worlds/world8/v1/sessions/w8.s01/drills/d.choose_raise_trap.json`.
- Closeout audit: `docs/_reviews/r33_content_explanation_closeout_audit_v1.md`.

---

# Milestone R34 — Post-R33 Weakest-Link Decision v1 (Bounded Next-Slice Selection)

Counter — R34 100/100 (+100%)

Status: completed (closed).

## Goal
- Determine the highest-EV bounded next slice after R33 by evidence-first comparison, then lock one implementation-ready target with explicit stop boundaries.

## Scope v1 (strict)
- Decision/audit scope only: compare bounded candidates and select exactly one next executable slice.
- Candidate classes must include:
  - next bounded content/explanation sanity slice,
  - bounded return to personalization/profile EV,
  - other bounded weakest-link area if evidence supports it.
- Produce one explicit winner and one narrow implementation-ready contract for the next milestone.
- No runtime/tooling/content implementation in R34 unless needed only for factual evidence extraction (prefer none).
- No broad backlog gardening, no architecture redesign, no ML scope, no UX cohesion expansion.

## P0 items (ordered)
- P0.1 Build post-R33 baseline matrix across at least the three candidate classes (content/explanation, personalization, other).
- P0.2 Rank each candidate by completeness, local/system/strategic EV, scope-explosion risk, and evidence confidence.
- P0.3 Publish weakest-link verdict with why non-selected candidates are deferred.
- P0.4 Update SSOT continuity with selected next milestone direction and explicit anti-drift/defer boundaries.

## DoD
- One evidence-backed weakest-link verdict is published.
- Exactly one bounded next-slice target is identified with deterministic scope boundaries.
- Non-selected candidates are explicitly deferred with rationale.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Doc-only by default: no tests required when no executable files change.
- If executable files are touched for evidence extraction, run `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.

## R34 stop rules
- STOP if evidence does not support a single bounded winner; in that case, publish inconclusive verdict and keep next slice undefined.
- STOP if scope expands into implementation, broad process redesign, architecture redesign, or multi-slice planning.
- STOP if candidate comparison is opinion-only without repo/doc/test evidence.

## Counter rubric
- `25%`: baseline candidate matrix and evidence sources captured.
- `50%`: EV/risk/confidence comparison completed for all candidates.
- `75%`: weakest-link verdict and defer rationale published.
- `100%`: SSOT continuity updated with bounded next-slice direction and anti-drift boundaries.

---

## Evidence
- Decision artifact: `docs/_reviews/r34_weakest_link_decision_v1.md`.
- Input continuity evidence: `docs/_reviews/r30_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r30_next_execution_focus_v1.md`, `docs/_reviews/r31_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r31_next_execution_focus_v1.md`, `docs/_reviews/r32_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r33_content_explanation_closeout_audit_v1.md`.
- Weakest-link verdict: content/explanation remains top bottleneck; next bounded executable direction selected as Template Action-Cue Fence v1.

---

# Milestone R35 — Content/Explanation Sanity Guard v5 (Template Action-Cue Fence)

Counter — R35 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV content/explanation leakage class by shipping one bounded deterministic template action-cue fence without broad content rewrite.

## Scope v1 (strict)
- Implement exactly one deterministic template action-cue leakage guard in existing validation tooling.
- Target a single bounded formulaic prompt-cue class selected by R34 decision evidence.
- Add minimum deterministic proof for fail-on-broken/pass-on-valid behavior.
- Limit content cleanup strictly to rows touched by the selected guard.
- No runtime product behavior changes, no schema redesign, no new dependencies, no semantic engines.

## P0 items (ordered)
- P0.1 Baseline selected template-cue family and confirm low false-positive contract.
- P0.2 Implement one deterministic guard for that template-cue family.
- P0.3 Add minimum proving contracts and run required gates.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic template action-cue guard is implemented and proven.
- Guard output is deterministic and actionable under identical input state.
- Content cleanup is minimal and bounded to selected guard impact.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Since content/tooling surfaces are expected to change, also run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted proof run when test surface is updated.

## R35 stop rules
- STOP if selection cannot be held to one deterministic template-cue class.
- STOP if scope expands into broad rewrite, semantic interpretation engines, personalization expansion, UX cohesion, architecture redesign, or ML scope.
- STOP if file count begins to sprawl beyond bounded cleanup for the selected guard.

## Counter rubric
- `25%`: bounded template-cue target and contract published.
- `50%`: one deterministic guard implemented.
- `75%`: deterministic proof and gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

---

## Evidence
- R34 decision artifact and bounded target selection: `docs/_reviews/r34_weakest_link_decision_v1.md`.
- Bounded template action-cue guard implementation + targeted proof: `tools/why_v1_ssot_v1.dart`, `tools/validate_world_content_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded content cleanup required by guard: `content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_call_track_baseline.json`, `content/worlds/world10/v1/sessions/w10.s02/drills/d.choose_call_cash_pressure.json`, `content/worlds/world10/v1/sessions/w10.s03/drills/d.choose_fold_mtt_pressure.json`, `content/worlds/world10/v1/sessions/w10.s04/drills/d.choose_call_mixed_stability.json`, `content/worlds/world10/v1/sessions/w10.s05/drills/d.choose_fold_switch_guardrails.json`, `content/worlds/world10/v1/sessions/w10.s06/drills/d.choose_call_consistency_check.json`, `content/worlds/world10/v1/sessions/w10.s07/drills/d.choose_raise_cash_deepening.json`, `content/worlds/world10/v1/sessions/w10.s08/drills/d.choose_fold_mtt_deepening.json`, `content/worlds/world10/v1/sessions/w10.s09/drills/d.choose_call_mixed_balance.json`, `content/worlds/world10/v1/sessions/w10.s10/drills/d.choose_raise_track_synthesis.json`.
- Closeout audit: `docs/_reviews/r35_content_explanation_closeout_audit_v1.md`.

---

# Milestone R36 — Content/Explanation Sanity Guard v6 (Second-Cue Template Fence)

Counter — R36 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV content/explanation leakage class by shipping one bounded deterministic guard for the deferred second-cue template family.

## Scope v1 (strict)
- Implement exactly one deterministic template action-cue leakage guard in existing validation tooling.
- Target only the bounded family: `When the second cue appears, choose <action>.`
- Add minimum deterministic proof for fail-on-broken/pass-on-valid behavior.
- Limit content cleanup strictly to rows touched by this one template family.
- No runtime product behavior changes, no schema redesign, no new dependencies, no semantic engines.

## P0 items (ordered)
- P0.1 Baseline target rows for the second-cue template and confirm low false-positive contract.
- P0.2 Implement one deterministic guard for the selected template family.
- P0.3 Add minimum proving contracts and run required gates.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic second-cue template guard is implemented and proven.
- Guard output is deterministic and actionable under identical input state.
- Content cleanup is minimal and bounded to selected guard impact.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Since content/tooling surfaces are expected to change, also run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted proof run when test surface is updated.

## R36 stop rules
- STOP if selection cannot be held to one deterministic template class.
- STOP if scope expands into broad rewrite, semantic interpretation engines, personalization expansion, UX cohesion, architecture redesign, or ML scope.
- STOP if file count begins to sprawl beyond bounded cleanup for the selected guard.

## Counter rubric
- `25%`: bounded second-cue template target and contract published.
- `50%`: one deterministic guard implemented.
- `75%`: deterministic proof and gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Prior bounded direction and deferred-family continuity: `docs/_reviews/r33_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r34_weakest_link_decision_v1.md`, `docs/_reviews/r35_content_explanation_closeout_audit_v1.md`.
- Bounded second-cue template guard implementation + targeted proof: `tools/why_v1_ssot_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded content cleanup required by guard: `content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_raise_track_baseline.json`, `content/worlds/world10/v1/sessions/w10.s02/drills/d.choose_fold_cash_pressure.json`, `content/worlds/world10/v1/sessions/w10.s03/drills/d.choose_raise_mtt_pressure.json`, `content/worlds/world10/v1/sessions/w10.s04/drills/d.choose_raise_mixed_stability.json`, `content/worlds/world10/v1/sessions/w10.s05/drills/d.choose_call_switch_guardrails.json`, `content/worlds/world10/v1/sessions/w10.s06/drills/d.choose_raise_consistency_check.json`, `content/worlds/world10/v1/sessions/w10.s07/drills/d.choose_call_cash_deepening.json`, `content/worlds/world10/v1/sessions/w10.s08/drills/d.choose_raise_mtt_deepening.json`, `content/worlds/world10/v1/sessions/w10.s09/drills/d.choose_fold_mixed_balance.json`, `content/worlds/world10/v1/sessions/w10.s10/drills/d.choose_call_track_synthesis.json`.
- Closeout audit: `docs/_reviews/r36_content_explanation_closeout_audit_v1.md`.

---

# Milestone R37 — Content/Explanation Sanity Guard v7 (Ordinal-Cue Template Fence)

Counter — R37 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV content/explanation leakage class by shipping one bounded deterministic ordinal-cue template fence based on post-R36 evidence.

## Scope v1 (strict)
- Implement exactly one deterministic template action-cue leakage guard in existing validation tooling.
- Target one bounded family only: ordinal-cue templates such as `When the <ordinal> cue appears, choose <action>.`
- Add minimum deterministic proof for fail-on-broken/pass-on-valid behavior.
- Limit content cleanup strictly to rows touched by this one template family.
- No runtime product behavior changes, no schema redesign, no new dependencies, no semantic engines.

## P0 items (ordered)
- P0.1 Baseline candidate matrix for post-R36 bottlenecks and confirm one bounded ordinal-cue target with acceptable false-positive risk.
- P0.2 Implement exactly one deterministic ordinal-cue template fence.
- P0.3 Add minimum proving contracts and run required gates.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic ordinal-cue template guard is implemented and proven.
- Guard output is deterministic and actionable under identical input state.
- Content cleanup is minimal and bounded to selected guard impact.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Since content/tooling surfaces are expected to change, also run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted proof run when test surface is updated.

## R37 stop rules
- STOP if selection cannot be held to one deterministic ordinal-cue template class.
- STOP if scope expands into broad rewrite, semantic interpretation engines, personalization expansion, UX cohesion, architecture redesign, or ML scope.
- STOP if file count begins to sprawl beyond bounded cleanup for the selected guard.

## Counter rubric
- `25%`: bounded ordinal-cue template target and contract published.
- `50%`: one deterministic guard implemented.
- `75%`: deterministic proof and gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Prior bounded direction and deferred-family continuity: `docs/_reviews/r34_weakest_link_decision_v1.md`, `docs/_reviews/r35_content_explanation_closeout_audit_v1.md`, `docs/_reviews/r36_content_explanation_closeout_audit_v1.md`.
- Bounded ordinal-cue template guard implementation + targeted proof: `tools/why_v1_ssot_v1.dart`, `test/tools/why_v1_ssot_v1_test.dart`.
- Baseline confirmation for exact leaking rows in selected family (none currently): deterministic scan against `content/worlds/**/drills/*.json` for `When the <ordinal> cue appears, choose <action>.`.
- Closeout audit: `docs/_reviews/r37_content_explanation_closeout_audit_v1.md`.

---

# Milestone R38 — Personalization/Profile EV Return v1 (Bounded Signal Re-Entry)

Counter — R38 100/100 (+100%)

Status: completed (closed).

## Goal
- Re-enter personalization with one bounded deterministic refinement after evidence of diminishing returns in repeated content/explanation sanity guards.

## Scope v1 (strict)
- Select exactly one highest-EV deterministic personalization refinement using existing persisted/derivable signals only.
- Implement only one bounded adaptive-routing refinement with explicit precedence/tie-break/fallback behavior.
- Add minimum deterministic contract coverage for stability and precedence safety.
- No schema changes, no new dependencies, no UI/profile dashboard expansion, no weighted scoring engine, no ML scope.

## P0 items (ordered)
- P0.1 Publish baseline signal matrix and choose exactly one bounded refinement target (include/maybe/exclude).
- P0.2 Implement exactly one deterministic personalization refinement in adaptive routing.
- P0.3 Add minimum proving contracts for deterministic behavior, precedence safety, and fallback preservation.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic personalization refinement is implemented and proven.
- Higher-priority routing paths remain unchanged and continue to win when applicable.
- Identical input/time state yields stable selection.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run targeted test suite for touched routing contracts.
- Run content validators only if content files are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R38 stop rules
- STOP if baseline does not yield one single bounded deterministic refinement target.
- STOP if scope expands into multi-signal scoring engine growth, profile UI expansion, content scaling, UX cohesion tracks, architecture redesign, or ML scope.
- STOP if deterministic precedence/tie-break contract cannot be kept explicit and testable.
- STOP as NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: baseline matrix and selected single bounded refinement target published.
- `50%`: one deterministic personalization refinement implemented.
- `75%`: deterministic proof contracts and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Personalization continuity inputs: `docs/_reviews/r24_profile_ev_baseline_v1.md`, `docs/_reviews/r24_personalization_closeout_audit_v1.md`, `docs/_reviews/r25_signal_layer_baseline_v1.md`, `docs/_reviews/r25_personalization_closeout_audit_v1.md`, `docs/_reviews/r26_personalization_closeout_audit_v1.md`, `docs/_reviews/r27_personalization_closeout_audit_v1.md`.
- Bounded runtime refinement (world-mastery fallback re-entry): `lib/services/progress_service.dart`.
- Deterministic contract proof: `test/services/review_queue_v1_test.dart`.
- Closeout audit: `docs/_reviews/r38_personalization_closeout_audit_v1.md`.

---

# Milestone R39 — External Learning Truth Triage Anchor v1 (Doc-Only Preservation)

Counter — R39 100/100 (+100%)

Status: completed (closed).

## Goal
- Restore SSOT continuity by formalizing a bounded doc-only milestone that preserves external Learning Truth & Feedback findings as ranked triage input for future weakest-link passes.

## Scope v1 (strict)
- Create one authoritative triage artifact for external audit findings and classify them into bounded severity/priority classes.
- Preserve explicit separation of candidate work surfaces:
  - tooling guards,
  - content cleanup batches,
  - runtime presentation adjustments.
- Keep this milestone decision/triage-only; no runtime/content/test implementation in R39.
- Do not force broad rewrite plans or automatic execution from triage output.

## P0 items (ordered)
- P0.1 Capture external audit source summary and normalize issue classes (P0/P1/P2).
- P0.2 Publish explicit split by execution surface (tooling/content/runtime) for future bounded slices.
- P0.3 Anchor triage artifact in roadmap context as deferred evidence source.
- P0.4 Publish closeout-ready roadmap continuity state without inventing implementation scope.

## DoD
- One authoritative triage doc exists and is linked from SSOT context.
- P0/P1/P2 classes are explicit and actionable for future bounded selection.
- Anti-drift statement explicitly prevents automatic broad implementation.
- No runtime/schema/dependency/content drift occurs in R39.
- One authoritative execution line remains in SSOT.

## Gates
- Doc-only by default: no tests required when no executable files are touched.
- If executable files are touched unexpectedly, run:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`

## R39 stop rules
- STOP if scope drifts into broad implementation planning or rewrite execution.
- STOP if triage is treated as automatic mandate rather than deferred evidence input.
- STOP if milestone introduces runtime/content/test changes unrelated to factual triage capture.

## Counter rubric
- `25%`: external triage artifact created with ranked issue classes.
- `50%`: execution-surface split completed (tooling/content/runtime candidates).
- `75%`: SSOT anchoring complete with anti-drift constraints.
- `100%`: R39 continuity/closeout state is ready with deferred evidence preserved.

## Evidence
- Prior weakest-link and continuity anchors: `docs/_reviews/r34_weakest_link_decision_v1.md`, `docs/_reviews/r38_personalization_closeout_audit_v1.md`.
- External audit preservation artifact: `docs/_reviews/external_learning_truth_audit_triage_v1.md`.
- R39 ranked execution verdict: `docs/_reviews/r39_external_audit_execution_verdict_v1.md`.

---

# Milestone R40 — Learning Truth Guard v1 (Contradictory Feedback Fence)

Counter — R40 100/100 (+100%)

Status: completed (closed).

## Goal
- Execute exactly one bounded external-audit-derived family: contradictory primary-correct feedback/mismatch prevention, using deterministic tooling/contract-first closure.

## Scope v1 (strict)
- Implement one deterministic tooling guard class for contradiction patterns in correctness feedback fields.
- Add minimum targeted contracts proving fail-on-broken / pass-on-valid behavior.
- Perform only bounded content cleanup required by the new guard, if violations are found.
- No prompt-leak family expansion, no placeholder batch program, no onboarding/runtime flow rewrites in this milestone.
- No schema changes, no new dependencies, no broad feature work.

## P0 items (ordered)
- P0.1 Baseline contradiction-pattern inventory for `feedback_correct_v1` / `feedback_incorrect_v1`.
- P0.2 Implement one bounded deterministic contradiction fence in existing tooling.
- P0.3 Add minimum contract proof and run required gates.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded contradiction-fence class is implemented and proven.
- Deterministic actionable failure output exists for broken cases.
- Any content cleanup remains bounded to rows required by the new guard.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted test run for touched tooling/test surfaces.

## R40 stop rules
- STOP if scope expands beyond one contradiction-guard family.
- STOP if work drifts into prompt-leak, placeholder, onboarding/runtime, or multi-family audit cleanup in the same pass.
- STOP if bounded deterministic contract cannot be expressed with high-confidence rules.
- STOP as NO-OP if equivalent guard coverage is already sufficient.

## Counter rubric
- `25%`: baseline contradiction inventory and bounded guard contract published.
- `50%`: one deterministic contradiction fence implemented.
- `75%`: targeted contracts and gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Triage and direction anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r39_external_audit_execution_verdict_v1.md`.
- Implemented bounded contradiction guard: `tools/why_v1_ssot_v1.dart`.
- Validator wiring for drill and hand-chain surfaces: `tools/validate_world_content_v1.dart`.
- Targeted deterministic contract proof: `test/tools/why_v1_ssot_v1_test.dart`.
- Closeout audit: `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`.
- R40 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `dart run tools/validate_world_content_v1.dart`, `dart run tools/run_content_qa_r2_v1.dart`, `dart test test/tools/why_v1_ssot_v1_test.dart`.

---

# Milestone R41 — Learning Truth Guard v2 (Prompt Leakage Family Closure)

Counter — R41 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the highest-EV remaining external-audit family by applying one bounded deterministic prompt-leakage closure pass across existing content tooling surfaces.

## Scope v1 (strict)
- Treat prompt leakage as one execution family and close it via deterministic tooling guard refinement plus bounded violation-driven cleanup.
- Cover only explicit answer-cue/action-cue template classes that are deterministic and low false-positive risk.
- Keep implementation bounded to existing tooling/validation/test seams and only rows that violate the selected prompt-leak contracts.
- No contradictory-feedback expansion, no placeholder/TODO batch program, no runtime presentation redesign in this milestone.
- No schema changes, no new dependencies, no feature/system redesign.

## P0 items (ordered)
- P0.1 Baseline prompt-leak family inventory from preserved external-audit classes and current validator gaps.
- P0.2 Implement one bounded prompt-leak family guard set in existing tooling flow (deterministic pass/fail, actionable errors).
- P0.3 Add minimum targeted contracts and run required gates/content validators.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Prompt-leak family closure for selected deterministic cue classes is enforced by tooling guards.
- Failure output is deterministic and actionable for violating rows.
- Content cleanup (if needed) is bounded to rows triggered by the selected prompt-leak contracts.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators for touched tooling/content surfaces:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted test run for updated prompt-leak contracts.

## R41 stop rules
- STOP if prompt-leak selection cannot remain one bounded deterministic family.
- STOP if scope drifts into contradiction-family expansion, placeholder/TODO batch cleanup, onboarding/top-leak runtime tracks, or multi-family rewrite.
- STOP if cleanup breadth exceeds violation-driven bounded correction.
- STOP as NO-OP if equivalent prompt-leak family coverage is already sufficient and proven.

## Counter rubric
- `25%`: prompt-leak baseline inventory and bounded guard contract set are published.
- `50%`: deterministic prompt-leak family guard implementation is complete.
- `75%`: targeted contracts and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Triage and direction anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r39_external_audit_execution_verdict_v1.md`, `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`.
- Prompt-leak family guard update: `tools/why_v1_ssot_v1.dart`.
- Deterministic contract proof update: `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded violation-driven cleanup (selected family only): `content/worlds/world6`, `content/worlds/world7`, `content/worlds/world8`, `content/worlds/world9`.
- Closeout audit: `docs/_reviews/r41_learning_truth_closeout_audit_v1.md`.
- R41 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `dart run tools/validate_world_content_v1.dart`, `dart run tools/run_content_qa_r2_v1.dart`, `dart test test/tools/why_v1_ssot_v1_test.dart`.

---

# Milestone R42 — Learning Truth Guard v3 (TODO/Placeholder Leakage Closure)

Counter — R42 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the highest-EV remaining safe bounded learning-truth family after R41 by fencing TODO/placeholder leakage in user-visible instructional/content fields with deterministic tooling rules.

## Scope v1 (strict)
- Treat TODO/placeholder leakage as one execution family and close it with tooling-first deterministic checks plus bounded violation-driven cleanup.
- Cover only explicit placeholder classes (for example `todo`, `tbd`, `placeholder`, `coming soon`, `n/a`, and deterministic prefixed variants) in user-visible text surfaces addressed by existing validators.
- Keep implementation bounded to existing tooling/validation/test seams and only rows directly flagged by selected placeholder contracts.
- No continuation of broad generic prompt-leak cleanup in this milestone.
- No contradictory-feedback expansion, no runtime Top-leak redesign, no onboarding/binding flow redesign.
- No schema changes, no new dependencies, no broad feature/system work.

## P0 items (ordered)
- P0.1 Baseline TODO/placeholder leakage inventory across currently validated user-visible content surfaces.
- P0.2 Implement one bounded deterministic placeholder-leak guard family in existing tooling flow (actionable pass/fail output).
- P0.3 Perform violation-driven bounded cleanup only for rows directly flagged by the selected family; add minimum targeted contracts and run gates.
- P0.4 Publish closeout audit with cleanup scope summary, open-risk/defer list, and next-focus transition note.

## DoD
- Selected TODO/placeholder leakage family is deterministically fenced in tooling.
- Failure output is actionable and stable under identical input/content state.
- Cleanup remains bounded to rows directly flagged by the selected family.
- No runtime/schema/dependency drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators for touched tooling/content surfaces:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted test run for updated placeholder-leak contracts.

## R42 stop rules
- STOP if selection cannot remain one bounded deterministic TODO/placeholder family.
- STOP if scope drifts into broad prompt-leak rewrite, contradictory-feedback expansion, runtime Top-leak redesign, or onboarding/binding architecture work.
- STOP if cleanup breadth begins to sprawl beyond direct validator hits for selected placeholder classes.
- STOP as NO-OP if equivalent TODO/placeholder coverage is already sufficient and proven.

## Counter rubric
- `25%`: placeholder leakage baseline inventory and bounded guard contract family are published.
- `50%`: deterministic placeholder-leak guard implementation is complete.
- `75%`: targeted contracts, cleanup, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Triage and direction anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r39_external_audit_execution_verdict_v1.md`, `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`, `docs/_reviews/r41_learning_truth_closeout_audit_v1.md`.
- Implemented bounded placeholder guard: `tools/why_v1_ssot_v1.dart`.
- Validator wiring for session TODO leakage: `tools/validate_world_content_v1.dart`.
- Targeted deterministic contract proof: `test/tools/why_v1_ssot_v1_test.dart`.
- Bounded cleanup (selected family only): `content/worlds/world0`, `content/worlds/world1`, `content/worlds/world6`, `content/worlds/world7`, `content/worlds/world8`, `content/worlds/world9`, `content/worlds/world10` (`session.md` files only).
- Closeout audit: `docs/_reviews/r42_learning_truth_closeout_audit_v1.md`.
- R42 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `dart run tools/validate_world_content_v1.dart`, `dart run tools/run_content_qa_r2_v1.dart`, `dart test test/tools/why_v1_ssot_v1_test.dart`.

---

# Milestone R43 — Learning Truth Verify-First Runtime Trust Slice (Top-Leak Presentation Gate)

Counter — R43 100/100 (+100%)

Status: completed (closed).

## Goal
- Resolve the highest-EV post-R42 trust bottleneck with a bounded verify-first runtime-presentation slice: determine and fence misleading `Top leak` exposure in non-strategic sessions without broad runtime redesign.

## Scope v1 (strict)
- Verify where and when `Top leak` is surfaced in session/result flows and classify strategic vs non-strategic contexts using existing contracts/data.
- Implement exactly one bounded deterministic runtime-presentation gate only if verification confirms the mismatch.
- Keep scope to one trust-presentation family; no continuation of broad content cleanup families in this milestone.
- No prompt family expansion, no generic `why_v1` rewrite batch, no onboarding/binding architecture rewrite.
- No schema changes, no new dependencies, no feature-family expansion.

## P0 items (ordered)
- P0.1 Verify-first baseline: produce deterministic inventory of `Top leak` presentation in active flows and confirm mismatch severity in non-strategic contexts.
- P0.2 Select one bounded runtime trust rule (show/hide/label gate) with explicit deterministic contract.
- P0.3 Implement only the selected runtime gate and add minimum proving contracts (fail-on-broken, pass-on-valid, precedence-safe behavior).
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Verification evidence confirms the selected mismatch class and bounded target.
- Exactly one runtime-presentation trust rule is shipped if mismatch is confirmed; otherwise bounded NO-OP is documented with proof.
- Deterministic contract coverage proves stable behavior under identical input state.
- No schema/dependency/content rewrite drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted contract run for touched runtime/test surfaces.

## R43 stop rules
- STOP if verification cannot isolate one bounded `Top leak` trust mismatch class.
- STOP if scope drifts into multi-family content cleanup, broad runtime UX redesign, onboarding/binding system rewrite, or personalization expansion.
- STOP if deterministic pass/fail presentation contract cannot be stated clearly.
- STOP as NO-OP if existing runtime behavior is already sufficient and proven.

## Counter rubric
- `25%`: verify-first baseline and mismatch inventory are complete.
- `50%`: one bounded runtime trust-rule contract is selected.
- `75%`: implementation + minimum deterministic contracts + required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Verification anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r39_external_audit_execution_verdict_v1.md`, `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`, `docs/_reviews/r41_learning_truth_closeout_audit_v1.md`, `docs/_reviews/r42_learning_truth_closeout_audit_v1.md`.
- Bounded runtime trust-rule implementation: `lib/personalization/focus_recommendation_router_v1.dart`.
- Deterministic contract proof: `test/personalization/focus_recommendation_router_v1_test.dart`, `test/ui_v2/session_result_screen_contract_test.dart`.
- Closeout audit: `docs/_reviews/r43_runtime_trust_closeout_audit_v1.md`.
- R43 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `dart test test/personalization/focus_recommendation_router_v1_test.dart`.

---

# Milestone R44 — Runtime Trust Guard v2 (Map/Header Top-Leak Context Gate)

Counter — R44 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the highest-EV post-R43 trust mismatch with one bounded runtime/UI presentation rule: prevent misleading `Top leak` wording in non-strategic global map/header contexts while preserving strategic recommendation behavior.

## Scope v1 (strict)
- Verify and classify map/header `Top leak` presentation surfaces that are not session-type recommendations.
- Implement exactly one bounded deterministic presentation gate (show/hide/relabel) for non-strategic global contexts.
- Preserve `SessionResult` campaign recommendation behavior locked in R43.
- Keep this to one runtime/UI trust family only; no renewed content/tooling cleanup families.
- No schema changes, no new dependencies, no broad UI redesign.

## P0 items (ordered)
- P0.1 Baseline: deterministic inventory of all map/header `Top leak` text surfaces and current trigger conditions.
- P0.2 Select one bounded trust rule contract for non-strategic global contexts.
- P0.3 Implement only the selected gate with minimum deterministic contracts proving strategic/non-strategic separation.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- One bounded map/header trust-mismatch class is verified and addressed.
- Deterministic contracts prove non-strategic global surfaces no longer present misleading `Top leak` framing.
- R43 strategic campaign recommendation behavior remains intact.
- No schema/dependency/content rewrite drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted runtime/widget contract run for touched map/result surfaces.

## R44 stop rules
- STOP if verification cannot isolate one bounded map/header presentation mismatch class.
- STOP if scope drifts into broad map redesign, multi-family trust cleanup, onboarding/binding system rewrite, or personalization expansion.
- STOP if deterministic pass/fail UI contract cannot be stated clearly.
- STOP as NO-OP if existing behavior is already sufficient and proven.

## Counter rubric
- `25%`: baseline inventory and bounded rule contract are complete.
- `50%`: one deterministic runtime/UI trust gate is implemented.
- `75%`: targeted contracts and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Verification anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r43_runtime_trust_closeout_audit_v1.md`.
- Bounded runtime trust-rule implementation: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
- Deterministic contract proof: `test/ui_v2/map_top_leak_context_label_contract_test.dart`.
- Closeout audit: `docs/_reviews/r44_runtime_trust_closeout_audit_v1.md`.
- R44 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`.
- Continuity note: R44 closeout required defining `# Milestone R45` before any R45 implementation work; this is now satisfied in the section below.

---

# Milestone R45 — Verify-First Onboarding/Binding Trust Slice (Path Dedup Gate)

Counter — R45 100/100 (+100%)

Status: completed (closed).

## Goal
- Resolve the highest-EV post-R44 deferred weakest-link class by verifying and, if confirmed, fencing onboarding/binding path duplication that can create confusing or competing first-run routes.

## Scope v1 (strict)
- Verify-first inventory of onboarding entry points, binding triggers, and first-run route transitions across map/home/today shell surfaces.
- Use existing routing signals/contracts to classify canonical vs duplicate paths.
- Implement exactly one bounded deterministic trust rule only if mismatch is confirmed (for example: suppress duplicate entry, deterministic precedence gate, or route-binding guard).
- Keep this to one onboarding/binding trust family; no continuation of broad learning-truth content cleanup families in the same milestone.
- No schema changes, no new dependencies, no broad runtime UX redesign, no personalization expansion.

## P0 items (ordered)
- P0.1 Verify-first baseline: deterministic inventory of onboarding/binding entry surfaces and trigger conditions; confirm whether duplicate/conflicting route behavior exists.
- P0.2 Select one bounded deterministic path-dedup rule with explicit precedence/tie-break contract (or bounded NO-OP if behavior is already correct and proven).
- P0.3 Implement only the selected guard if needed and add minimum deterministic contracts proving canonical-path stability.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- One bounded onboarding/binding mismatch class is verified and either fixed with one deterministic guard or closed as bounded NO-OP with evidence.
- Deterministic contract coverage proves identical input state yields identical canonical onboarding/binding routing outcome.
- Existing campaign/session-result and map/header trust behavior from R43-R44 remains intact.
- No schema/dependency/content rewrite drift enters scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted runtime/test contract run for touched onboarding/binding routing surfaces.

## R45 stop rules
- STOP if verification cannot isolate one bounded onboarding/binding mismatch class.
- STOP if scope drifts into multi-family trust cleanup, broad onboarding redesign, map/header redesign, or personalization/system expansion.
- STOP if deterministic precedence/pass-fail contract cannot be stated clearly.
- STOP as NO-OP if existing onboarding/binding behavior is already sufficient and proven.

## Counter rubric
- `25%`: verify-first onboarding/binding inventory and bounded mismatch contract are complete.
- `50%`: one bounded deterministic onboarding/binding trust rule is selected.
- `75%`: implementation (if needed), targeted contracts, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Verification anchors: `docs/_reviews/external_learning_truth_audit_triage_v1.md`, `docs/_reviews/r43_runtime_trust_closeout_audit_v1.md`, `docs/_reviews/r44_runtime_trust_closeout_audit_v1.md`.
- Bounded onboarding/binding trust-rule implementation: `lib/ui_v2/onboarding/onboarding_preferences_service.dart`.
- Deterministic contract proof: `test/ui_v2/onboarding_preferences_service_contract_test.dart`.
- Closeout audit: `docs/_reviews/r45_onboarding_binding_closeout_audit_v1.md`.
- R45 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`.
- Continuity note: R45 closeout required defining `# Milestone R46` before any R46 implementation work; this is now satisfied in the section below.

---

# Milestone R46 — Personalization Re-Entry v2 (Deterministic Routing Refinement)

Counter — R46 100/100 (+100%)

Status: completed (closed).

## Goal
- Resume profile-EV personalization with one bounded deterministic routing refinement after the R40-R45 trust-restoration chain reached diminishing marginal return.

## Scope v1 (strict)
- Verify-first baseline on current adaptive routing stack and already-used signals from R24-R27.
- Select exactly one highest-EV still-unused or underused deterministic signal/refinement using existing persisted/runtime contracts only.
- Implement one bounded precedence/tie-break/fallback refinement in adaptive routing if mismatch/gap is confirmed.
- Keep scope to one personalization family only; no weighted scoring engine, no profile UI/dashboard expansion, no schema changes, no ML.
- Do not reopen completed R40-R45 trust-cleanup families in this milestone.

## P0 items (ordered)
- P0.1 Baseline: inventory current deterministic personalization precedence and identify one bounded underused signal/refinement candidate.
- P0.2 Select one deterministic routing contract (precedence/tie-break/fallback) with explicit bounded insertion point.
- P0.3 Implement only the selected refinement and add minimum deterministic contracts (stable selection, higher-priority preservation, invalid-signal fallback).
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic personalization refinement is verified and shipped (or bounded NO-OP if already fully implemented/proven).
- Deterministic contracts prove identical input/time state yields identical selected followup.
- Existing higher-priority routing behavior remains intact and precedence-safe.
- No schema/dependency/content/runtime-family drift outside the selected refinement.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted routing contract run for touched personalization/test surfaces.

## R46 stop rules
- STOP if baseline cannot isolate one bounded deterministic personalization target.
- STOP if scope drifts into multi-signal scoring, profile UI expansion, schema redesign, trust-cleanup family continuation, or architecture redesign.
- STOP if deterministic precedence/tie-break contract cannot be stated clearly.
- STOP as NO-OP if selected behavior is already sufficient and proven.

## Counter rubric
- `25%`: verify-first baseline and one bounded personalization target are identified.
- `50%`: deterministic routing contract for one selected refinement is finalized.
- `75%`: implementation (if needed), targeted contracts, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline and candidate ranking anchors: `docs/_reviews/r24_profile_ev_baseline_v1.md`, `docs/_reviews/r25_signal_layer_baseline_v1.md`, `docs/_reviews/r38_personalization_closeout_audit_v1.md`.
- Bounded runtime refinement: `lib/services/progress_service.dart` (intake-profile fallback after world-mastery fallback).
- Deterministic contract proof: `test/services/review_queue_v1_test.dart` (intake-profile fallback usage/precedence/invalid-mapping preservation).
- Closeout audit: `docs/_reviews/r46_personalization_closeout_audit_v1.md`.
- R46 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R46 closeout required defining `# Milestone R47` before any R47 implementation work; this is now satisfied in the section below.

---

# Milestone R47 — Personalization Continuation v3 (Deterministic Signal Refinement)

Counter — R47 100/100 (+100%)

Status: completed (closed).

## Goal
- Continue personalization with one bounded deterministic refinement chosen by evidence after R46 re-entry, while avoiding drift back into broad trust/content cleanup inertia.

## Scope v1 (strict)
- Reconcile post-R46 evidence and current adaptive routing stack to identify the next highest-EV underused deterministic personalization refinement.
- Select exactly one bounded precedence/tie-break/fallback refinement using existing signals/contracts only.
- Implement one deterministic adaptive-routing refinement only if baseline confirms a real gap.
- Keep scope to one personalization family only; no weighted scoring, no profile UI/dashboard expansion, no schema changes, no ML.
- Do not reopen R40-R45 trust/content/runtime cleanup families unless a new weakest-link pass explicitly changes direction.

## P0 items (ordered)
- P0.1 Baseline: publish candidate matrix of remaining deterministic personalization refinements and classify include/maybe/exclude with evidence.
- P0.2 Select exactly one bounded refinement target and lock explicit precedence/tie-break/fallback contract.
- P0.3 Implement only the selected refinement and add minimum deterministic contracts (stable selection, higher-priority preservation, invalid-signal fallback).
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic personalization refinement is selected and shipped (or bounded NO-OP if already fully implemented/proven).
- Deterministic contracts prove identical input/time state yields identical selected followup.
- Existing higher-priority adaptive paths remain precedence-safe and unchanged.
- No schema/dependency/content/runtime-family drift outside selected personalization slice.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted routing contract run for touched personalization/test surfaces.

## R47 stop rules
- STOP if baseline cannot isolate one bounded deterministic personalization target.
- STOP if scope drifts into weighted scoring, profile UI expansion, schema redesign, ML, or trust/content cleanup family continuation.
- STOP if deterministic precedence/tie-break contract cannot be stated clearly.
- STOP as NO-OP if selected behavior is already sufficient and proven.

## Counter rubric
- `25%`: baseline matrix and one bounded personalization target are identified.
- `50%`: deterministic contract for one selected refinement is finalized.
- `75%`: implementation (if needed), targeted contracts, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline and continuation anchors: `docs/_reviews/r24_profile_ev_baseline_v1.md`, `docs/_reviews/r25_signal_layer_baseline_v1.md`, `docs/_reviews/r38_personalization_closeout_audit_v1.md`, `docs/_reviews/r46_personalization_closeout_audit_v1.md`.
- Bounded runtime refinement: `lib/services/progress_service.dart` (learning-stats tie-break via `unnecessary_fold_when_check_available` before checkpoint fallback).
- Deterministic contract proof: `test/services/review_queue_v1_test.dart` (tie-break usage, higher-priority preservation, zero-signal fallback determinism).
- Closeout audit: `docs/_reviews/r47_personalization_closeout_audit_v1.md`.
- R47 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R47 closeout required defining `# Milestone R48` before any R48 implementation work; this is now satisfied in the section below.

---

# Milestone R48 — Personalization Continuation v4 (Deterministic Conflict-Resolution Refinement)

Counter — R48 100/100 (+100%)

Status: completed (closed).

## Goal
- Continue profile-EV personalization with one bounded deterministic conflict-resolution refinement after R46-R47 wins, while preserving strict anti-drift boundaries.

## Scope v1 (strict)
- Build an evidence-first baseline over current adaptive routing precedence and remaining underused deterministic signals/contracts.
- Select exactly one bounded deterministic continuation target (signal layer, precedence refinement, or conflict-resolution rule) with explicit insertion point.
- Implement only one adaptive-routing refinement if the baseline confirms a real gap.
- Keep scope to one personalization family only; no weighted scoring, no profile UI/dashboard expansion, no schema changes, no ML.
- Do not reopen R40-R45 trust/content/runtime cleanup families unless a separate weakest-link decision explicitly changes direction.

## P0 items (ordered)
- P0.1 Baseline: publish candidate matrix of remaining deterministic personalization refinements and classify include/maybe/exclude with evidence.
- P0.2 Select exactly one bounded refinement and lock explicit precedence/tie-break/fallback contract.
- P0.3 Implement only the selected refinement and add minimum deterministic contracts (stable selection, higher-priority preservation, invalid-signal fallback, no state leakage).
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic personalization refinement is selected and shipped (or bounded NO-OP if already fully implemented/proven).
- Deterministic contracts prove identical input/time state yields identical selected followup.
- Existing higher-priority adaptive paths remain precedence-safe and unchanged.
- No schema/dependency/content/runtime-family drift outside selected personalization slice.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted routing contract run for touched personalization/test surfaces.

## R48 stop rules
- STOP if baseline cannot isolate one bounded deterministic personalization target.
- STOP if scope drifts into weighted scoring, profile UI expansion, schema redesign, ML, or trust/content cleanup family continuation.
- STOP if deterministic precedence/tie-break contract cannot be stated clearly.
- STOP as NO-OP if selected behavior is already sufficient and proven.

## Counter rubric
- `25%`: baseline matrix and one bounded personalization target are identified.
- `50%`: deterministic contract for one selected refinement is finalized.
- `75%`: implementation (if needed), targeted contracts, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline and continuation anchors: `docs/_reviews/r24_profile_ev_baseline_v1.md`, `docs/_reviews/r25_personalization_closeout_audit_v1.md`, `docs/_reviews/r38_personalization_closeout_audit_v1.md`, `docs/_reviews/r46_personalization_closeout_audit_v1.md`, `docs/_reviews/r47_personalization_closeout_audit_v1.md`.
- Bounded runtime refinement: `lib/services/progress_service.dart` (learning-stats tie-break conflict-resolution gate for non-zero primary mismatch ties only).
- Deterministic contract proof: `test/services/review_queue_v1_test.dart` (relevant-conflict usage, higher-priority preservation, zero-conflict fallback behavior, deterministic repeatability).
- Closeout audit: `docs/_reviews/r48_personalization_closeout_audit_v1.md`.
- R48 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R48 closeout required defining `# Milestone R49` before any R49 implementation work; this is now satisfied in the section below.

---

# Milestone R49 — Personalization Continuation v5 (Deterministic Precedence Harmonization)

Counter — R49 100/100 (+100%)

Status: completed (closed).

## Goal
- Continue profile-EV personalization with one bounded deterministic precedence-harmonization refinement after R46-R48, while avoiding drift into scoring engines, profile UI, or broader system redesign.

## Scope v1 (strict)
- Build an evidence-first baseline over current adaptive-routing stack and unresolved deterministic precedence/conflict edges.
- Select exactly one bounded deterministic continuation target (signal-layer refinement, tie-break refinement, or fallback conflict-resolution) using existing signals/contracts only.
- Implement only one adaptive-routing refinement if baseline confirms a real bounded gap.
- Keep scope to one personalization family only; no weighted scoring, no profile UI/dashboard expansion, no schema changes, no ML.
- Do not reopen R40-R45 trust/content/runtime cleanup families unless a new weakest-link pass explicitly changes direction.

## P0 items (ordered)
- P0.1 Baseline: publish candidate matrix of remaining deterministic personalization conflict/precedence refinements and classify include/maybe/exclude with evidence.
- P0.2 Select exactly one bounded refinement and lock explicit precedence/tie-break/fallback contract.
- P0.3 Implement only the selected refinement and add minimum deterministic contracts (conflict-case usage, higher-priority preservation, invalid-signal fallback, stable repeatability).
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note.

## DoD
- Exactly one bounded deterministic personalization refinement is selected and shipped (or bounded NO-OP if already fully implemented/proven).
- Deterministic contracts prove identical input/time state yields identical selected followup.
- Existing higher-priority adaptive paths remain precedence-safe and unchanged.
- No schema/dependency/content/runtime-family drift outside selected personalization slice.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh`.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted routing contract run for touched personalization/test surfaces.

## R49 stop rules
- STOP if baseline cannot isolate one bounded deterministic personalization target.
- STOP if scope drifts into weighted scoring, profile UI expansion, schema redesign, ML, or trust/content cleanup family continuation.
- STOP if deterministic precedence/tie-break contract cannot be stated clearly.
- STOP as NO-OP if selected behavior is already sufficient and proven.

## Counter rubric
- `25%`: baseline matrix and one bounded personalization target are identified.
- `50%`: deterministic contract for one selected refinement is finalized.
- `75%`: implementation (if needed), targeted contracts, and required gates are green.
- `100%`: closeout audit published with explicit defer list and next focus unblocked.

## Evidence
- Baseline and continuation anchors: `docs/_reviews/r24_profile_ev_baseline_v1.md`, `docs/_reviews/r25_personalization_closeout_audit_v1.md`, `docs/_reviews/r38_personalization_closeout_audit_v1.md`, `docs/_reviews/r46_personalization_closeout_audit_v1.md`, `docs/_reviews/r47_personalization_closeout_audit_v1.md`, `docs/_reviews/r48_personalization_closeout_audit_v1.md`.
- Bounded runtime refinement: `lib/services/progress_service.dart` (skill-tags precedence harmonization: no auto-seed override when tags are absent).
- Deterministic contract proof: `test/services/review_queue_v1_test.dart` (explicit skill-tags usage, higher-priority preservation, deterministic fallthrough under empty skill-tags state).
- Closeout audit: `docs/_reviews/r49_personalization_closeout_audit_v1.md`.
- R49 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R49 closeout required defining `# Milestone R50` before any R50 implementation work; this is now satisfied in the section below.

---

# Milestone R50 — Personalization Continuation v6 (Deterministic Weakest-Link Refinement)

Counter — R50 100/100 (+100%)

Status: completed (closed).

## Goal
- Determine and execute one highest-EV bounded deterministic personalization refinement after R46-R49, using evidence-first weakest-link logic and preserving strict anti-drift boundaries.

## Scope v1 (strict)
- Build a post-R49 candidate matrix across personalization continuation vs trust/content return vs other bounded weakest-link options, with explicit EV/risk/confidence reasoning.
- If personalization remains top by evidence, select exactly one bounded deterministic routing refinement using existing signals/contracts only.
- If evidence points elsewhere or is inconclusive, STOP and publish bounded decision outcome without forcing runtime implementation scope.
- Keep scope to one family only; no weighted scoring, no profile UI/dashboard expansion, no schema changes, no ML.
- Do not reopen R40-R45 trust/content/runtime chains by inertia; require explicit evidence if direction changes.

## P0 items (ordered)
- P0.1 Baseline: publish post-R49 bottleneck comparison matrix (A learning-truth/content-integrity, B personalization continuation, C other bounded weakest-link).
- P0.2 Weakest-link verdict: choose exactly one winner with explicit EV/risk/confidence justification.
- P0.3 If winner is personalization, implement exactly one bounded deterministic refinement with explicit precedence/tie-break/fallback contract and minimum deterministic proof.
- P0.4 Publish closeout audit with open-risk/defer list and next-focus transition note; close R50 in SSOT if gates are green.

## DoD
- One explicit evidence-first weakest-link verdict exists for post-R49 direction.
- If execution proceeds, exactly one bounded deterministic refinement is shipped and proven; otherwise bounded decision STOP is documented.
- Existing higher-priority adaptive paths remain precedence-safe and unchanged.
- No schema/dependency/content/runtime-family drift outside selected bounded scope.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze` and `./tools/fast_loop_world1_v1.sh` for executable changes.
- Run content validators only if content files are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted routing contract run for touched personalization/test surfaces.
- Doc-only decision pass may skip tests when no executable changes are made.

## R50 stop rules
- STOP if baseline cannot isolate one bounded high-confidence winner with acceptable scope risk.
- STOP if scope drifts into weighted scoring, profile UI expansion, schema redesign, ML, or multi-family trust/content/runtime cleanup.
- STOP if deterministic precedence/tie-break/fallback contract cannot be stated clearly for selected implementation target.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R49 baseline matrix and bounded candidate shortlist are published.
- `50%`: weakest-link verdict and single bounded target contract are finalized.
- `75%`: implementation (if needed), minimum deterministic proof, and required gates are green.
- `100%`: closeout audit published, SSOT updated, and next focus unblocked without drift.

## Evidence
- Post-R49 baseline/verdict winner: personalization continuation (bounded deterministic unresolved edge) over learning-truth/content and other bounded runtime classes.
- Selected bounded refinement: intake-profile malformed-payload hardening in adaptive routing fallback.
- Runtime change: `lib/services/progress_service.dart` (`_resolveIntakeProfileRoutingFocusV1` now uses safe intake-profile read that falls through on unusable payload).
- Deterministic proof: `test/services/review_queue_v1_test.dart` (malformed intake payload fallback + repeatable stability; higher-priority and invalid-signal fallthrough contracts remain green).
- Closeout audit: `docs/_reviews/r50_personalization_closeout_audit_v1.md`.
- R50 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R51 decision lock is now defined below.

---

# Milestone R51 — Post-R50 Weakest-Link Decision Lock (Audit-First)

Counter — R51 100/100 (+100%)

Status: completed (closed).

## Goal
- Determine the correct next executable direction after R50 by evidence, not inertia, and lock one bounded implementation-ready direction for R52 (or explicitly lock inconclusive status if evidence remains insufficient).

## Scope v1 (strict)
- Build a post-R50 bottleneck comparison across:
  - A) bounded learning-truth/content-integrity continuation,
  - B) bounded personalization/profile-EV continuation,
  - C) another bounded weakest-link area supported by current evidence.
- Reconcile diminishing returns after R40-R45 trust restoration and fresh outcomes from R46-R50 personalization refinements.
- Produce exactly one weakest-link verdict with explicit EV/risk/confidence reasoning.
- Keep this milestone doc-only: no runtime/test/content implementation changes.
- Do not pre-commit to personalization or trust/content continuation without evidence advantage.

## P0 items (ordered)
- P0.1 Publish post-R50 comparison matrix (A/B/C) with completeness, local EV, system EV, strategic EV, scope risk, and evidence confidence.
- P0.2 Publish a single weakest-link verdict: A, B, C, or inconclusive.
- P0.3 If verdict is conclusive, define one bounded executable target class for R52 with explicit anti-drift boundaries.
- P0.4 If verdict is inconclusive, define R52 as bounded verification/decision continuation without inventing implementation scope.

## DoD
- One explicit post-R50 weakest-link verdict is documented.
- The verdict is evidence-backed and anti-inertia (not automatic continuation).
- R52 direction is bounded and continuity-safe (implementation-ready class or explicit bounded verification path).
- No executable product behavior changes are introduced in R51.
- One authoritative execution line remains in SSOT.

## Gates
- No runtime tests required for doc-only R51 definition/update.
- Keep repository and SSOT continuity consistent (single authoritative execution line, ACTIVE/NEXT coherence).

## R51 stop rules
- STOP if comparison cannot be completed with current evidence without speculative assumptions.
- STOP if the selected direction requires mixing multiple families in one milestone.
- STOP if scope drifts into weighted scoring engines, profile UI expansion, schema redesign, ML, or broad multi-family cleanup.
- STOP if R52 target cannot be stated as one bounded executable class.

## Counter rubric
- `25%`: post-R50 A/B/C bottleneck matrix drafted with EV/risk/confidence fields.
- `50%`: weakest-link verdict selected (or inconclusive verdict explicitly justified).
- `75%`: bounded R52 direction class locked with anti-drift boundaries.
- `100%`: SSOT R51 section finalized with coherent ACTIVE/NEXT continuity and no execution-scope drift.

## Evidence
- Decision lock artifact: `docs/_reviews/r51_post_r50_decision_lock_v1.md`.
- Weakest-link verdict: inconclusive (no single implementation family outranks alternatives with sufficient confidence post-R50).
- R52 lock: bounded verification/decision continuation only (no product behavior implementation scope).
- Continuity note: `# Milestone R52` is now defined below.

## Evidence anchors
- `docs/_reviews/r39_external_audit_execution_verdict_v1.md`
- `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r41_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r42_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r43_runtime_trust_closeout_audit_v1.md`
- `docs/_reviews/r44_runtime_trust_closeout_audit_v1.md`
- `docs/_reviews/r45_onboarding_binding_closeout_audit_v1.md`
- `docs/_reviews/r46_personalization_closeout_audit_v1.md`
- `docs/_reviews/r47_personalization_closeout_audit_v1.md`
- `docs/_reviews/r48_personalization_closeout_audit_v1.md`
- `docs/_reviews/r49_personalization_closeout_audit_v1.md`
- `docs/_reviews/r50_personalization_closeout_audit_v1.md`
- `docs/_reviews/external_learning_truth_audit_triage_v1.md`

---

# Milestone R52 — Post-R50 Winner Isolation (Bounded Verification Continuation)

Counter — R52 100/100 (+100%)

Status: completed (closed).

## Goal
- Convert the R51 inconclusive verdict into one conclusive, evidence-backed, single-family executable direction for R53 without forcing speculative implementation.

## Scope v1 (strict)
- Verification/decision only (doc/tooling-verification family); no runtime/UI/content implementation.
- Isolate one bounded winner class by comparing:
  - one narrowed learning-truth/content-integrity candidate class, and
  - one narrowed personalization residual candidate class.
- Require explicit boundedness proof for both candidates before selecting a winner.
- Produce one implementation-ready target class for R53, or bounded NO-GO if evidence remains insufficient.

## P0 items (ordered)
- P0.1 Define narrowed candidate pair (A-narrowed vs B-narrowed) with deterministic boundaries.
- P0.2 Run evidence comparison with EV/risk/confidence and explicit anti-drift checks.
- P0.3 Select exactly one winner or issue bounded NO-GO.
- P0.4 Publish R52 closeout note locking R53 implementation scope to one family only.

## DoD
- One conclusive winner is selected for R53, or bounded NO-GO is explicitly documented.
- Chosen winner is implementation-ready as one bounded class.
- No product behavior implementation occurs in R52.
- One authoritative execution line remains in SSOT.

## Gates
- No runtime tests required for doc-only R52 verification pass.
- Keep SSOT continuity coherent (ACTIVE/NEXT and single end execution line).

## R52 stop rules
- STOP if candidate narrowing cannot be done without speculation.
- STOP if more than one implementation family is being selected.
- STOP if selected R53 scope is not one bounded executable class.
- STOP if scope drifts into weighted scoring, profile UI, schema redesign, ML, or multi-family cleanup.

## Counter rubric
- `25%`: narrowed candidate pair is defined with boundaries.
- `50%`: evidence comparison completed with explicit EV/risk/confidence.
- `75%`: single winner (or bounded NO-GO) is locked for R53.
- `100%`: R52 closeout published and SSOT continuity updated without drift.

## Evidence
- Direction lock artifact: `docs/_reviews/r52_r53_direction_lock_v1.md`.
- Narrowed A-candidate: exact residual prompt-leak template (`in this <...> spot, choose <action>`).
- Narrowed B-candidate: intake-profile typed-signal normalization in adaptive routing fallback.
- Verdict: B wins (higher system/strategic EV at lower sprawl with implementation-ready bounded scope).
- R53 lock: one-family deterministic personalization refinement only.

---

# Milestone R53 — Personalization Continuation v7 (Deterministic Intake Normalization)

Counter — R53 100/100 (+100%)

Status: completed (closed).

## Goal
- Execute one bounded deterministic personalization refinement from the R52 lock by normalizing intake-profile typed signals in adaptive routing fallback while preserving existing precedence and anti-drift boundaries.

## Scope v1 (strict)
- Touch only one family: intake-profile fallback normalization in adaptive routing.
- Reuse existing signals/contracts only (`focusLabel`, `placementScore`, `skillBand` in intake profile).
- Add bounded coercion handling for string/numeric representations of existing fields.
- Preserve deterministic null-fallthrough for unusable state.
- No weighted scoring, no profile UI/dashboard expansion, no schema/dependency changes, no ML.
- Do not reopen learning-truth/runtime/onboarding families in this milestone.

## P0 items (ordered)
- P0.1 Lock exact coercion/precedence contract for intake-profile fallback (one insertion surface).
- P0.2 Implement only the selected normalization refinement.
- P0.3 Add minimum deterministic contracts:
  - normalized typed state uses intake fallback when applicable,
  - higher-priority layers still win when present,
  - unusable typed state preserves prior fallback behavior,
  - repeated identical input/time yields stable selection.
- P0.4 Publish closeout audit and update SSOT continuity if gates are green.

## DoD
- Exactly one bounded intake-profile normalization refinement is shipped (or bounded NO-OP if already fully covered).
- Deterministic contracts prove precedence safety and stable repeatability.
- No drift beyond selected personalization family.
- One authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add targeted routing contract run for touched personalization/test surfaces.
- Run content validators only if content files are touched unexpectedly:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R53 stop rules
- STOP if intake normalization cannot be stated as one bounded deterministic family.
- STOP if more than one implementation family is being selected.
- STOP if scope drifts into weighted scoring, profile UI expansion, schema redesign, ML, or trust/content/runtime/onboarding cleanup.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: exact intake normalization contract and insertion point are locked.
- `50%`: bounded implementation is complete with one-family scope.
- `75%`: deterministic proof and required gates are green.
- `100%`: closeout audit + SSOT continuity update completed without drift.

## Evidence
- Runtime refinement: `lib/services/progress_service.dart` (`placementScore` normalization for intake fallback from integer-like typed state only).
- Deterministic proof: `test/services/review_queue_v1_test.dart` (string placement normalization use, non-integral numeric fallthrough, repeatability; existing higher-priority precedence contracts remain green).
- Closeout audit: `docs/_reviews/r53_personalization_closeout_audit_v1.md`.
- R53 required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/services/review_queue_v1_test.dart`.
- Continuity note: R54 definition is now provided below from evidence-first weakest-link selection.

---

# Milestone R54 — Learning-Truth Continuation v4 (Bounded Prompt-Leak Family)

Counter — R54 100/100 (+100%)

Status: completed (closed).

## Goal
- Rebalance after the long R46-R53 personalization chain by executing one bounded deterministic learning-truth/content-integrity slice with the highest current non-personalization EV: close the residual narrow prompt-leak template family `in this <...> spot, choose <action>`.

## Scope v1 (strict)
- One family only: narrow prompt-leak template class previously deferred as a standalone bounded candidate.
- Tooling/content only:
  - extend existing prompt-leak guard contracts for this exact template family,
  - perform only violation-driven content cleanup required by the guard.
- No runtime routing personalization changes.
- No weighted scoring, profile UI expansion, schema changes, dependency additions, or ML.
- Do not combine with generic `choose <action>` broad family, placeholder/TODO family continuation, or runtime/onboarding trust families.

## P0 items (ordered)
- P0.1 Baseline: confirm exact remaining footprint of `in this <...> spot, choose <action>` prompt-leak family in active user-facing surfaces.
- P0.2 Contract: lock deterministic guard rule for that exact template class (fail-on-violation, pass-on-valid).
- P0.3 Implementation: update tooling guard and apply bounded violation-only content cleanup.
- P0.4 Proof/closeout: run required gates + targeted guard test, publish closeout audit, and update SSOT continuity if green.

## DoD
- Exactly one bounded prompt-leak family is closed with deterministic guard enforcement.
- Any required cleanup is limited to rows violating the selected template class.
- No drift into multi-family cleanup or runtime/system redesign.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Because selected scope includes content/tooling work, run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted guard contract run for touched validator/guard test surfaces.

## R54 stop rules
- STOP if the selected prompt class cannot be kept as one bounded family.
- STOP if scope expands to generic `choose <action>` broad class or other prompt/leak families.
- STOP if runtime trust/onboarding/personalization/scoring/schema/ML work enters scope.
- STOP as bounded NO-OP if this exact template family is already fully covered and proven.

## Counter rubric
- `25%`: exact residual template footprint is confirmed and bounded.
- `50%`: deterministic guard contract for the selected family is finalized.
- `75%`: bounded guard/cleanup implementation + required gates are green.
- `100%`: closeout audit + SSOT continuity update complete without drift.

## Evidence
- Guard refinement: `tools/why_v1_ssot_v1.dart` (`_kPromptLeakTemplateCueV1` expanded to bounded `in this <...> spot, choose <action>` class).
- Validator wiring reused: `tools/validate_world_content_v1.dart` (drill + `hand_chain_v1` prompt leak checks via existing guard path).
- Targeted guard proof: `test/tools/why_v1_ssot_v1_test.dart` (descriptor variant fail, repaired variant pass).
- Bounded cleanup: selected-family prompt fixes in `content/worlds/world10/v1/tracks/{cash,tournament,mixed}/sessions/**/drills/*.json` (54 files).
- Required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `dart run tools/validate_world_content_v1.dart`, `dart run tools/run_content_qa_r2_v1.dart`, `dart test test/tools/why_v1_ssot_v1_test.dart`.
- Closeout audit: `docs/_reviews/r54_learning_truth_closeout_audit_v1.md`.
- Continuity note: `# Milestone R55` is defined below via post-R54 evidence-first weakest-link selection.

---

# Milestone R55 — Routing Visibility v1 (Bounded “Why Are You Here?” Layer)

Counter — R55 100/100 (+100%)

Status: completed (closed).

## Goal
- Convert already-existing adaptive-routing decisions into one bounded user-visible reason layer so routing value is explainable at decision time without deepening routing logic.

## Scope v1 (strict)
- One family only: bounded routing-visibility presentation for existing route-selection reasons.
- Use existing routing outputs/signals only; no new scoring model, no profile dashboard, no policy engine expansion.
- Limit UI change to one narrow presentation seam (single reason string/chip/line near primary route CTA in the current flow).
- Deterministic reason mapping only (same input state -> same displayed reason).
- No content-integrity multi-family cleanup, no broad strategic/gamification rewrite, no schema/dependency changes, no ML.

## P0 items (ordered)
- P0.1 Baseline: inventory current adaptive-routing reason sources and confirm where routing is user-invisible in active flow.
- P0.2 Contract: lock one deterministic reason-priority mapping from existing route result -> user-visible explanation text.
- P0.3 Implementation: add one bounded “Why are you here?” presentation seam using existing route context only.
- P0.4 Proof/closeout: add minimal deterministic tests for reason mapping/rendering precedence, run required gates, publish closeout audit, and close R55 if green.

## DoD
- Exactly one bounded routing-visibility layer is shipped for existing adaptive-route outcomes.
- Reason output is deterministic and precedence-safe against existing routing order.
- No routing policy/scoring/profile-system expansion and no UI redesign drift.
- Required gates are green and SSOT continuity remains single-line authoritative.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Run targeted tests for touched routing-visibility surface (existing routing contract tests + one visibility contract test).
- STOP on first failure.

## R55 stop rules
- STOP if scope drifts into deep routing refinement, weighted scoring, profile dashboard expansion, schema redesign, or ML.
- STOP if visibility work expands beyond one bounded presentation seam.
- STOP if candidate requires introducing new routing signal families instead of reusing existing outputs.
- STOP as bounded NO-OP if equivalent deterministic routing-visibility output is already fully implemented and proven.

## Counter rubric
- `25%`: baseline visibility gap and deterministic reason contract are locked.
- `50%`: bounded one-seam routing-visibility implementation is complete.
- `75%`: targeted deterministic proof + required gates are green.
- `100%`: closeout audit + SSOT continuity update complete without drift.

## Evidence
- Selected seam implementation: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` (`today_plan_focus_line_v1` uses deterministic `todayPlanRoutingReasonLineV1` mapping from existing rhythm reason + routed next-pack signal).
- Contract proof: `test/ui_v2/today_plan_routing_reason_contract_test.dart` (review-gated mapping, followup b0/b2 mapping, absent-target safe fallback, repeatability).
- Required gates passed: `flutter analyze`, `./tools/fast_loop_world1_v1.sh`, `flutter test test/ui_v2/today_plan_routing_reason_contract_test.dart`.
- Closeout audit: `docs/_reviews/r55_routing_visibility_closeout_audit_v1.md`.
- Continuity note: `# Milestone R56` is defined below and closed as a bounded repo-ops pass.

---

# Milestone R56 — GitHub Actions Cost Reduction v1 (Local-First CI Narrowing)

Counter — R56 100/100 (+100%)

Status: completed (closed).

## Goal
- Reduce GitHub Actions minute burn with bounded workflow narrowing while preserving local-first validation and documented release safety gates.

## Scope v1 (strict)
- Repo-ops only (`.github/workflows/*` plus closeout docs/SSOT continuity).
- Keep documented release/checkpoint workflows intact.
- Narrow high-minute low-EV auto triggers (nightly schedules, feature-branch mirrors, broad push triggers).
- No CI architecture redesign, no new dependencies, no runtime/content/product code changes.

## P0 items (ordered)
- P0.1 Inventory all workflows and classify keep/narrow/disable/delete with purpose/cost/risk.
- P0.2 Select smallest safe reduction set with meaningful minute impact.
- P0.3 Apply bounded trigger narrowing/disable changes only.
- P0.4 Publish closeout note and update SSOT continuity.

## DoD
- High-minute low-EV workflows are narrowed safely without touching product/runtime/content code.
- Documented release path workflows remain preserved.
- Closeout note is published with open risks and defer list.
- One authoritative execution line remains in SSOT.

## Gates
- PRE/POST `git status --porcelain` clean.
- No product tests required (workflow/doc-only pass).

## R56 stop rules
- STOP if branch/release safety cannot be inferred sufficiently from repo evidence.
- STOP if reduction requires broad CI redesign.
- STOP if changes would disable clearly required release/protection checks without safe preservation.
- STOP if scope drifts into product/runtime/content work.

## Counter rubric
- `25%`: workflow inventory and risk classification complete.
- `50%`: safest bounded reduction plan selected.
- `75%`: workflow narrowing changes applied.
- `100%`: closeout note + SSOT continuity update complete.

## Evidence
- Narrowed workflows:
  - `.github/workflows/ci_nightly.yml` (schedule removed; manual only).
  - `.github/workflows/unit-tests-nightly.yml` (schedule removed; manual only).
  - `.github/workflows/phase4-nightly.yml` (schedule removed; manual only).
  - `.github/workflows/ci.yaml` (nightly schedule removed; explicit PR-label/push-marker path preserved).
  - `.github/workflows/precommit.yml` (feature-branch push trigger removed; manual only).
  - `.github/workflows/live_fast_lane.yml` (feature-branch push trigger removed; manual only).
  - `.github/workflows/content_fast_lane.yml` (feature-branch push trigger removed; manual only).
  - `.github/workflows/pure_dart_smoke.yml` (push narrowed to `main` only; manual preserved).
  - `.github/workflows/validate.yml` (push narrowed to `main` only; manual added).
- Preserved workflows:
  - `.github/workflows/r5-release-gate.yml` (documented release wiring).
  - `.github/workflows/r5-tier2-checkpoint.yml` (manual/tag checkpoint path).
- Closeout audit: `docs/_reviews/r56_actions_cost_reduction_closeout_v1.md`.
- Continuity note: `# Milestone R57` is defined below and closed as a bounded World 1 emergency truth/content triage pass.

---

# Milestone R57 — World 1 Emergency Truth & Legality Triage

Counter — R57 100/100 (+100%)

Status: completed (closed).

## Goal
- Verify and close the highest-risk bounded World 1 truth/trust regression class from emergency playtest findings without broad rewrite.

## Scope v1 (strict)
- Verify-first inventory across World 1 legality/runtime, prompt/feedback truth, and map/progression continuity.
- Select exactly one bounded subset by risk priority and evidence.
- Implement only one deterministic fix family.
- Add minimum proving contracts and publish closeout audit.
- No architecture redesign, no multi-family cleanup, no schema/dependency changes.

## P0 items (ordered)
- P0.1 Verify-first inventory of reported regressions (A legality, B content/prompt/feedback, C map/progression).
- P0.2 Select one highest-risk bounded subset based on confirmed repo-state evidence.
- P0.3 Implement only that subset with deterministic contract.
- P0.4 Run required gates, publish closeout audit, and update SSOT continuity.

## DoD
- One bounded World 1 regression class is confirmed and closed with deterministic proof.
- Non-selected classes are explicitly documented as deferred or non-reproducible in current repo state.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Because tooling/content surfaces were touched, run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Run targeted guard contract test for touched fence surface.

## R57 stop rules
- STOP if no single bounded subset can be isolated safely.
- STOP if scope drifts into broad early-world rewrite, onboarding redesign, personalization work, or multi-family cleanup.
- STOP if deterministic contract cannot be stated clearly.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: verify-first inventory complete with A/B/C class evidence.
- `50%`: one bounded subset selected with deterministic contract.
- `75%`: bounded fix + targeted proof complete.
- `100%`: required gates green + closeout audit + SSOT continuity update.

## Evidence
- Selected bounded class: direct-answer prompt leakage in World 1 `action_choice` drills (`"Choose fold/call/raise."`).
- New bounded helper: `tools/why_v1_ssot_v1.dart` (`hasDirectChooseActionPromptLeakV1`).
- World1-scoped validator fence: `tools/validate_world_content_v1.dart` (`prompt_direct_action_leak_world1_v1` under `sessionId.startsWith('w1.') && kind == 'action_choice'`).
- Bounded cleanup: 26 files under `content/worlds/world1/v1/sessions/**/drills/*.json` rewritten to `Choose the best action.`.
- Targeted contract proof: `test/tools/why_v1_ssot_v1_test.dart`.
- Closeout audit: `docs/_reviews/r57_world1_truth_legality_closeout_audit_v1.md`.
- Continuity note: `# Milestone R58` is defined below via post-R57 evidence-first weakest-link selection.

---

# Milestone R58 — Early-Path Learning Truth Continuation v1 (Action-Focus Cue-Leak Closure)

Counter — R58 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the highest-EV bounded post-R57 weakest-link visible after clean install: runtime action-focus cue leakage (`Focus: <action>`) in early action-choice presentation.

## Scope v1 (strict)
- One family only: runtime prompt cue template leakage (`Choose the best action. Focus: <action>.`) in the selected early-path seam.
- Deterministic bounded runtime+guard pass only for the selected family.
- Reuse existing contracts/tooling/tests first; avoid new systems.
- No personalization expansion, no schema/dependency changes, no broad multi-family prompt cleanup.

## P0 items (ordered)
- P0.1 Baseline inventory: deterministically enumerate currently visible early-path cue-leak prompts and isolate one bounded winning family.
- P0.2 Contract lock: define exact pass/fail family rule and bounded insertion seam for runtime closure.
- P0.3 Implementation: apply only selected-family runtime seam cleanup plus minimum deterministic guard/test proof updates.
- P0.4 Proof + closeout: run required gates, add one targeted guard proof run, publish closeout audit, and close R58 if green.

## DoD
- Exactly one bounded post-R57 weakest-link family is selected and closed.
- Selected runtime `Focus: <action>` cue template is removed from the bounded early-path seam under deterministic contract.
- No drift into multi-family cleanup, runtime redesign, or personalization/profile work.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Because tooling/content surfaces are expected, run:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Run targeted guard contract test for touched fence surface.

## R58 stop rules
- STOP if residual scope cannot be kept to one prompt family.
- STOP if evidence fails to confirm a bounded remaining footprint.
- STOP if scope drifts into broad early-world rewrite, generic multi-family prompt cleanup, runtime/UI redesign, personalization/scoring, schema redesign, or ML.
- STOP as bounded NO-OP if selected residual family is already fully closed and proven.

## Counter rubric
- `25%`: post-R57 A/B/C comparison and bounded winner lock are complete.
- `50%`: selected-family baseline + contract finalized with deterministic insertion point.
- `75%`: bounded implementation/cleanup complete with targeted proof.
- `100%`: closeout audit + SSOT continuity update complete without drift.

## Evidence
- Verified dominant visible family: runtime cue leakage in `_spineTaskLineV1` (`"Choose the best action. Focus: <action>."`) in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`.
- Selected bounded closure: neutralize seam prompt to `"Choose the best action."` while preserving recommendation behavior.
- Deterministic helper/test contract added for selected family:
  - `tools/why_v1_ssot_v1.dart` (`hasActionFocusCueLeakV1`)
  - `test/tools/why_v1_ssot_v1_test.dart`
- Runtime seam contract updated:
  - `test/guards/world1_foundations_microtask_contract_test.dart` (asserts no `Focus:` cue).
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Closeout audit: `docs/_reviews/r58_learning_truth_closeout_audit_v1.md`.
- Continuity note: `# Milestone R59` is defined below via verify-first early-path coherence recovery.

---

# Milestone R59 — Early-Path Coherence Recovery v1

Counter — R59 100/100 (+100%)

Status: completed (closed).

## Goal
- Restore first-user early-path coherence by fixing one highest-EV bounded root-cause cluster behind mixed interaction behavior in early runner flow.

## Scope v1 (strict)
- One cluster only: mode-separation mismatch between seat-quiz interaction and hand-loop action-decision interaction.
- Verify-first inventory across entry/mode/action/progression surfaces, then fix only selected cluster.
- Deterministic runtime/test pass only for selected cluster.
- No broad onboarding rewrite, no multi-family content cleanup, no personalization expansion, no schema/dependency changes.

## P0 items (ordered)
- P0.1 Verify-first inventory of early-path coherence from start entry to first runner steps (A/B/C/D classes).
- P0.2 Select exactly one bounded root-cause cluster with explicit justification.
- P0.3 Implement deterministic cluster fix only.
- P0.4 Add minimum proving contracts, run required gates, publish closeout audit, and close R59 if green.

## DoD
- Exactly one bounded root-cause cluster is confirmed and closed.
- Selected cluster fix is deterministic under identical state.
- Adjacent critical behavior remains intact.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Run targeted runner contract test for selected mode-separation fix.

## R59 stop rules
- STOP if no single bounded root-cause cluster can be isolated safely.
- STOP if scope drifts into broad early-world rewrite, onboarding redesign, multi-family cleanup, personalization work, or UI overhaul.
- STOP if more than one independent cluster is being fixed without one shared root cause.
- STOP as bounded NO-OP if selected cluster is already fixed and proven.

## Counter rubric
- `25%`: verify-first A/B/C/D inventory complete.
- `50%`: one bounded root-cause cluster selected + deterministic contract locked.
- `75%`: bounded fix + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence
- Verified inventory outcome:
  - A entry/binding mismatch: no deterministic primary root-cause repro in current start-now/next-pack repo paths.
  - B mode-separation mismatch: confirmed seat chips remained interactive during hand-loop/action mode in runner.
  - C action-contract mismatch: not selected as primary for this milestone.
  - D result/progression mismatch: not selected as primary for this milestone.
- Selected bounded root cause: hand-loop mode leaked seat-selection interaction contract.
- Runtime fix:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Seat taps now gated to seat-quiz mode only (`seatTapEnabledV1`), with aligned semantics enablement.
- Targeted proof:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `world1 hand-loop keeps seat taps disabled to avoid seat/action mode mixing`.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r59_early_path_coherence_closeout_audit_v1.md`.
- Continuity note: `# Milestone R60` is defined below via post-R59 layered recovery comparison.

---

# Milestone R60 — Early-Path Coherence Recovery v2 (Action-Contract Alignment)

Counter — R60 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV early-path coherence layer after R59 by aligning action-contract truth across prompt, legal-action affordances, and action-bar semantics in early runner action steps.

## Scope v1 (strict)
- One layer only: action-contract mismatch surface in early-path action-decision steps.
- Bound to deterministic runtime/test contract alignment:
  - labels vs available buttons,
  - legal-action rendering consistency,
  - stable action-bar semantics/order,
  - prompt/action affordance coherence.
- No entry/binding redesign, no mode-mixing redesign (already closed in R59), no broad teaching-copy rewrite, no progression-system redesign.
- No schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline action-contract inventory for first-user early-path action steps (prompt text, rendered legal actions, expected action, bar ordering/labels).
- P0.2 Isolate one bounded deterministic mismatch family in action-contract layer.
- P0.3 Implement one bounded runtime fix in selected family only.
- P0.4 Add minimum proving contracts and closeout audit; close R60 if gates are green.

## DoD
- Exactly one bounded action-contract mismatch family is selected and closed.
- Prompt/action-bar/legal-action contract is deterministic under identical state for selected family.
- Higher-priority behavior outside selected family remains unchanged.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add one targeted runner/action-contract proof run if runtime/test surfaces are updated.
- Run content validators only if content/tooling surfaces are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R60 stop rules
- STOP if no single bounded action-contract family can be isolated safely.
- STOP if scope drifts into entry/binding redesign, mode-mixing redesign, broad teaching-truth rewrite, progression/map redesign, personalization/scoring, schema redesign, or ML.
- STOP if more than one independent family is being fixed without shared root cause.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R59 layer comparison + action-contract family lock complete.
- `50%`: bounded contract defined with deterministic insertion point.
- `75%`: bounded implementation + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence basis (R60 definition)
- Post-R59 candidate A (action-contract mismatch layer):
  - Completeness: medium (strong existing contracts, but residual first-user trust EV remains in prompt/affordance coherence).
  - EV: highest local/system EV for first 3–5 minute trust after mode-separation closure.
  - Risk: acceptable when constrained to one deterministic family.
  - Confidence: high enough for implementation-ready bounded milestone.
- Post-R59 candidate B (teaching-truth layer):
  - Completeness: medium-high (R57/R58 closed direct cue leakage families; key wording contracts exist).
  - EV: meaningful but secondary to immediate action-affordance truth alignment.
  - Risk: copy-scope expansion risk higher if not tightly bounded.
- Post-R59 candidate C (result/progression coherence layer):
  - Completeness: high (broad existing map/result continuity contracts and prior closures).
  - EV: currently lower than A for immediate first-step trust.
  - Risk: moderate scope spread across surfaces if reopened without new failure evidence.
- Weakest-layer verdict: **A wins**.
- Continuity note: R60 execution closeout evidence is recorded below.

## Evidence (R60 execution closeout)
- Verified action-contract baseline inventory outcome:
  - Selected bounded mismatch family: raise-label truth mismatch between expected/outcome lines and visible action affordance semantics (`RAISE TO` / `RAISE MIN`) in early action-decision steps.
  - Non-selected families remained deferred to avoid multi-family scope drift.
- Deterministic contract implemented:
  - Early truth lines now normalize raise labels from `allowedActions` semantics:
    - raise-to family -> `RAISE TO`
    - raise-min-only family -> `RAISE MIN`
    - fallback preserved for non-matching states.
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Updated `world1SpineOutcomeExpectedLineV1` and `_actionKindLabelV1` for contextual raise label normalization.
- Minimum proving contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `world1 spine expected line normalizes raise label to visible affordance deterministically`
  - `world1 spine incorrect action outcome aligns raise label with action affordance`
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r60_action_contract_closeout_audit_v1.md`
- Continuity note:
  - `# Milestone R61` is defined below via post-R60 layered recovery comparison.

---

# Milestone R61 — Early-Path Coherence Recovery v3 (Teaching-Truth Alignment)

Counter — R61 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV bounded early-path recovery layer after R60 by aligning teaching-truth output (why/correct/expected wording and no-leak clarity) for early action tasks.

## Scope v1 (strict)
- One layer only: teaching-truth coherence in early runner action outcomes.
- Bound to deterministic runtime/test contract alignment for:
  - explanation presence/absence consistency,
  - correct feedback wording coherence,
  - why-layer alignment with action state,
  - no-answer-leak prompt clarity preservation after R57/R58.
- No action-contract redesign (closed in R60), no entry/mode redesign (closed in R59), no broad result/map/progression redesign, no personalization/scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline inventory of teaching-truth mismatches in early action steps (why/correct/expected/coach copy lines and leakage risk).
- P0.2 Isolate one bounded deterministic teaching-truth mismatch family.
- P0.3 Implement one bounded runtime/content fix only for selected family.
- P0.4 Add minimum proving contracts, run required gates, publish closeout audit, and close R61 if green.

## DoD
- Exactly one bounded teaching-truth mismatch family is selected and closed.
- Selected teaching-truth contract is deterministic under identical state.
- Prompt/feedback no-leak guarantees remain intact.
- Behavior outside selected family remains unchanged.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add one targeted runner teaching-truth proof run if runtime/test surfaces are updated.
- Run content validators only if content/tooling surfaces are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R61 stop rules
- STOP if no single bounded teaching-truth mismatch family can be isolated safely.
- STOP if scope drifts into broad early-world rewrite, result/progression redesign, onboarding redesign, personalization/scoring, schema redesign, or ML.
- STOP if more than one independent family is being fixed without shared root cause.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R60 layer comparison + bounded teaching-truth family lock complete.
- `50%`: deterministic contract + insertion point defined.
- `75%`: bounded implementation + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence basis (R61 definition)
- Post-R60 candidate A (teaching-truth layer):
  - Completeness: medium (core contracts exist, but early wrong-answer trust still depends on exact why/correct/expected framing consistency).
  - Local EV: high for first-session trust because this layer directly explains mistakes.
  - System EV: medium-high (improves coherence of learning loop without touching routing architecture).
  - Strategic EV: high (supports truth-first onboarding quality with bounded runtime/test scope).
  - Scope-explosion risk: medium, controllable when constrained to one wording/logic family.
  - Evidence confidence: medium-high from existing closeouts and runner contract surfaces.
  - User-visible impact: high on early mistakes and recovery comprehension.
- Post-R60 candidate B (result/progression coherence layer):
  - Completeness: high (strong map/result continuity and CTA contracts already present across guards and session result tests).
  - Local EV: medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium (multi-surface spill risk across result/map flows).
  - Evidence confidence: high that baseline is currently good-enough.
  - User-visible impact: medium.
- Post-R60 candidate C (another bounded weakest-link area):
  - Candidate considered: additional action-contract or routing-reason expansion.
  - Completeness: medium-high after R55/R60 bounded wins.
  - Local EV: lower than A under current evidence.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if reopened without specific fresh failures.
  - Evidence confidence: medium-low for a stronger immediate winner than A.
  - User-visible impact: medium-low versus direct teaching-truth alignment.
- Weakest-layer verdict: **A wins**.
- Continuity note: R61 execution closeout evidence is recorded below.

## Evidence (R61 execution closeout)
- Verified teaching-truth baseline inventory outcome:
  - Selected bounded mismatch family: correct raise feedback wording was not aligned with post-R60 affordance semantics (`RAISE TO` / `RAISE MIN`).
  - Non-selected families remained deferred to avoid multi-family teaching-copy drift.
- Deterministic contract implemented:
  - On correct early action outcomes with raise selections (`toCall > 0`), `Correct:` wording now resolves via canonical raise-affordance semantics from `allowedActions`.
  - `RAISE TO` and `RAISE MIN` paths are deterministic under identical state.
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Added `world1SpinePreferredRaiseLabelV1(...)` and aligned `world1SpineOutcomeCorrectLineV1(...)` raise copy with affordance semantics.
  - Reused canonical helper in expected/action label paths to keep parity deterministic.
- Minimum proving contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `world1 spine preferred raise label resolves deterministically from allowed actions`
  - `world1 spine correct line aligns raise wording with available affordance`
  - `world1 spine correct outcome aligns raise wording with action affordance`
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r61_teaching_truth_closeout_audit_v1.md`
- Continuity note:
  - `# Milestone R62` is defined below via post-R61 layered recovery comparison.

---

# Milestone R62 — Early-Path Coherence Recovery v4 (Lesson-Induction Clarity)

Counter — R62 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV bounded early-path recovery layer after R61 by improving first-session lesson induction clarity (what the learner is doing and why) without answer leakage or broad copy/platform redesign.

## Scope v1 (strict)
- One layer only: bounded early teaching/UX clarity in World1 foundations induction surfaces.
- Bound to deterministic runtime/test contract alignment for:
  - clearer lesson induction framing,
  - reduced overly mechanical tap-here/do-this feel in selected seam,
  - preserved no-answer-leak wording guarantees.
- No action-contract redesign (R60 closed), no teaching-truth raise wording redesign (R61 closed), no result/progression system redesign, no personalization/scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline inventory of remaining early induction/coach wording seams and first-step framing friction.
- P0.2 Isolate one bounded deterministic clarity mismatch family with highest user-visible EV.
- P0.3 Implement one bounded runtime/content wording/presentation fix only for selected family.
- P0.4 Add minimum proving contracts, run required gates, publish closeout audit, and close R62 if green.

## DoD
- Exactly one bounded lesson-induction clarity mismatch family is selected and closed.
- Selected clarity contract is deterministic under identical state.
- No-answer-leak guarantees remain intact.
- Behavior outside selected family remains unchanged.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add one targeted early-runner clarity proof run if runtime/test surfaces are updated.
- Run content validators only if content/tooling surfaces are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R62 stop rules
- STOP if no single bounded induction-clarity family can be isolated safely.
- STOP if scope drifts into broad copy rewrite, result/progression redesign, onboarding/platform redesign, personalization/scoring, schema redesign, or ML.
- STOP if more than one independent family is being fixed without shared root cause.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R61 layer comparison + bounded induction-clarity family lock complete.
- `50%`: deterministic contract + insertion point defined.
- `75%`: bounded implementation + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence basis (R62 definition)
- Post-R61 candidate A (result/progression coherence layer):
  - Completeness: high (extensive existing contracts for result CTA coherence, map/node state continuity, and up-next traversal).
  - Local EV: medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium (multi-surface coupling across result/map flows).
  - Evidence confidence: high that this layer is currently good-enough for bounded continuation.
  - User-visible impact: medium.
- Post-R61 candidate B (remaining early teaching/UX clarity layer):
  - Completeness: medium (truth and no-leak families are improved, but induction framing still contains mechanical instruction feel in first-user path).
  - Local EV: high.
  - System EV: medium-high (improves first 3–5 minute comprehension without architecture changes).
  - Strategic EV: high (supports trust and learning stickiness after legality/action/teaching-truth closures).
  - Scope-explosion risk: medium, controllable when constrained to one wording/presentation family.
  - Evidence confidence: medium-high from runner/coach seams and existing contract baselines.
  - User-visible impact: high.
- Post-R61 candidate C (another bounded weakest-link area):
  - Candidate considered: additional action-contract or routing-reason expansion.
  - Completeness: medium-high after R55/R60/R61 closures.
  - Local EV: lower than B under current evidence.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if reopened without fresh failure evidence.
  - Evidence confidence: medium-low as a stronger immediate winner than B.
  - User-visible impact: medium-low versus induction clarity.
- Weakest-layer verdict: **B wins**.
- Continuity note: R62 execution closeout evidence is recorded below.

## Evidence (R62 execution closeout)
- Verified induction baseline inventory outcome:
  - Selected bounded mismatch family: repeated low-information seat-quiz idle command framing (`Select a seat.`) in early runner induction seams.
  - Non-selected families remained deferred to avoid multi-family copy/platform drift.
- Deterministic contract implemented:
  - In seat-quiz idle states where confirm is blocked, guidance now renders a purposeful deterministic line:
    - `Seat drill: identify your position, then confirm.`
  - Behavior outside this family remains unchanged.
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Added `_seatQuizIdleGuidanceLineV1()` and replaced bounded idle guidance surfaces (coach fallback + portrait/non-portrait strips).
- Minimum proving contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - Updated `lock in stays disabled until a seat is selected` to assert new guidance and absence of legacy line.
  - Targeted guard retained for adjacent seat-intro placement safety.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r62_lesson_induction_closeout_audit_v1.md`
- Continuity note:
  - `# Milestone R63` is defined below via post-R62 layered recovery comparison.

---

# Milestone R63 — Early-Path Coherence Recovery v5 (Action-Mode Guidance Clarity)

Counter — R63 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV bounded early-path recovery layer after R62 by improving action-mode guidance clarity so first-user tasks feel purposeful and understandable without answer leakage.

## Scope v1 (strict)
- One layer only: remaining early teaching/UX clarity in World1 action-mode guidance seams.
- Bound to deterministic runtime/test contract alignment for:
  - reducing low-meaning repetitive action-mode prompts,
  - clarifying what the learner is practicing in selected seam,
  - preserving no-answer-leak guarantees.
- No mode-separation redesign (R59 closed), no action-contract redesign (R60 closed), no raise wording redesign (R61 closed), no seat-idle induction redesign (R62 closed), no result/progression system redesign, no personalization/scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline inventory of remaining low-meaning/repetitive action-mode guidance seams in first-user flow.
- P0.2 Isolate one bounded deterministic clarity mismatch family with highest user-visible EV.
- P0.3 Implement one bounded runtime/content wording/presentation fix only for selected family.
- P0.4 Add minimum proving contracts, run required gates, publish closeout audit, and close R63 if green.

## DoD
- Exactly one bounded action-mode guidance clarity mismatch family is selected and closed.
- Selected clarity contract is deterministic under identical state.
- No-answer-leak guarantees remain intact.
- Behavior outside selected family remains unchanged.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add one targeted early-runner guidance clarity proof run if runtime/test surfaces are updated.
- Run content validators only if content/tooling surfaces are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R63 stop rules
- STOP if no single bounded action-mode guidance family can be isolated safely.
- STOP if scope drifts into broad copy rewrite, onboarding redesign, multi-family UX cleanup, result/progression redesign, personalization/scoring, schema redesign, or ML.
- STOP if more than one independent family is being fixed without shared root cause.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R62 layer comparison + bounded action-mode guidance family lock complete.
- `50%`: deterministic contract + insertion point defined.
- `75%`: bounded implementation + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence basis (R63 definition)
- Post-R62 candidate A (result/progression coherence layer):
  - Completeness: high (strong existing contracts for result CTA coherence, map/node continuity, and up-next traversal).
  - Local EV: medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium (cross-surface coupling risk).
  - Evidence confidence: high that this layer is currently good-enough for bounded continuation.
  - User-visible impact: medium.
- Post-R62 candidate B (remaining early teaching/UX clarity layer):
  - Completeness: medium (seat-quiz idle induction improved in R62, but action-mode guidance still has repetitive low-meaning seams such as generic command-style prompts).
  - Local EV: high for first 3–5 minute comprehension.
  - System EV: medium-high.
  - Strategic EV: high (maintains trust-first learning flow after R59-R62 closures).
  - Scope-explosion risk: medium, controllable when constrained to one wording/presentation family.
  - Evidence confidence: medium-high from current runner prompt/coach seams and contract coverage.
  - User-visible impact: high.
- Post-R62 candidate C (another bounded weakest-link area):
  - Candidate considered: additional action-contract or routing/progression expansions.
  - Completeness: medium-high after R59-R62 closures.
  - Local EV: lower than B under current evidence.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if reopened without fresh failure evidence.
  - Evidence confidence: medium-low as a stronger immediate winner than B.
  - User-visible impact: medium-low versus guidance clarity.
- Weakest-layer verdict: **B wins**.
- Continuity note: R63 execution closeout evidence is recorded below.

## Evidence (R63 execution closeout)
- Verified action-mode guidance baseline inventory outcome:
  - Selected bounded mismatch family: repetitive low-meaning generic action-mode prompt in World1 spine seam (`Choose the best action.` without practice framing).
  - Non-selected families remained deferred to avoid multi-family UX drift.
- Deterministic contract implemented:
  - In selected World1 spine action-mode seam, task line now renders:
    - `Practice: <Street> decision. Choose the best action.`
  - Uses existing street-label resolver and preserves non-leak guidance.
  - Behavior outside selected family remains unchanged.
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Updated `_spineTaskLineV1(_CampaignActionUiState? state)` to apply bounded purposeful framing.
- Minimum proving contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - Updated tests:
    - `world1 spine prompt is informative and varies across streets`
    - `world1 followup action-state shows polished line without duplicate instruction`
  - Proof asserts street-specific deterministic `Practice:` framing plus retained `Choose the best action.` line.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r63_action_mode_guidance_closeout_audit_v1.md`
- Continuity note:
  - `# Milestone R64` is defined below via post-R63 layered recovery comparison.

---

# Milestone R64 — Early-Path Coherence Recovery v6 (Result/Progression Finish Coherence)

Counter — R64 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the next highest-EV bounded early-path recovery layer after R63 by aligning finish experience coherence (session/level completion framing and next-step continuation clarity) without broad UX redesign.

## Scope v1 (strict)
- One layer only: result/progression finish coherence for early-path World1 flow.
- Bound to deterministic runtime/test contract alignment for:
  - session complete vs level complete framing clarity,
  - replay/next CTA semantics coherence,
  - next-step clarity immediately after early sessions,
  - bounded node-state/result-state continuity only where directly tied to finish experience.
- No entry/mode redesign (R59 closed), no action-contract redesign (R60 closed), no raise teaching-truth redesign (R61 closed), no seat-idle induction redesign (R62 closed), no action-mode guidance redesign (R63 closed), no personalization/scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline inventory of finish-experience seams in early path (session result, level-complete transition, map return/next flow).
- P0.2 Isolate one bounded deterministic finish-coherence mismatch family with highest user-visible EV.
- P0.3 Implement one bounded runtime/UI contract fix only for selected family.
- P0.4 Add minimum proving contracts, run required gates, publish closeout audit, and close R64 if green.

## DoD
- Exactly one bounded finish-coherence mismatch family is selected and closed.
- Selected finish contract is deterministic under identical state.
- Replay/next semantics remain coherent and truthful for selected family.
- Behavior outside selected family remains unchanged.
- Required gates are green and one authoritative execution line remains in SSOT.

## Gates
- Run: `flutter analyze`.
- Run: `./tools/fast_loop_world1_v1.sh`.
- Add one targeted finish-coherence proof run if runtime/test surfaces are updated.
- Run content validators only if content/tooling surfaces are touched:
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`

## R64 stop rules
- STOP if no single bounded finish-coherence family can be isolated safely.
- STOP if scope drifts into broad map/onboarding redesign, multi-family copy rewrite, personalization/scoring, schema redesign, or ML.
- STOP if more than one independent family is being fixed without shared root cause.
- STOP as bounded NO-OP if selected behavior is already fully implemented and proven.

## Counter rubric
- `25%`: post-R63 layer comparison + bounded finish-coherence family lock complete.
- `50%`: deterministic contract + insertion point defined.
- `75%`: bounded implementation + targeted proof complete.
- `100%`: gates green + closeout audit + SSOT continuity update complete.

## Evidence basis (R64 definition)
- Post-R63 candidate A (result/progression finish coherence layer):
  - Completeness: medium-high (strong map/result contracts exist, but finish framing and CTA continuity still span multiple adjacent seams and remain the highest remaining early-path coherence surface).
  - Local EV: high.
  - System EV: high.
  - Strategic EV: high (direct trust impact at session completion and continuation handoff).
  - Scope-explosion risk: medium, controllable when limited to one finish-family seam.
  - Evidence confidence: medium-high from existing runtime surfaces and contract inventory.
  - User-visible impact: high.
- Post-R63 candidate B (remaining early teaching/UX clarity layer):
  - Completeness: medium-high after R62/R63 bounded closures (seat-quiz induction and action-mode guidance seams improved).
  - Local EV: medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if continued without fresh dominant failure evidence.
  - Evidence confidence: medium-low as the stronger immediate winner than A.
  - User-visible impact: medium.
- Post-R63 candidate C (another bounded weakest-link area):
  - Candidate considered: additional action-contract or routing-level refinement.
  - Completeness: high after R59/R60/R61/R63 closures and existing routing continuity contracts.
  - Local EV: low-medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if reopened by inertia.
  - Evidence confidence: low as a stronger immediate winner than A.
  - User-visible impact: medium-low.
- Weakest-layer verdict: **A wins**.
- Continuity note: R64 execution closeout evidence is recorded below.

## Evidence (R64 execution closeout)
- Verified finish/progression baseline inventory outcome:
  - Selected bounded mismatch family: ambiguous session-result primary CTA semantics (`CONTINUE` used across distinct next actions).
  - Non-selected families remained deferred to avoid multi-surface finish/map redesign drift.
- Deterministic contract implemented:
  - Session-result primary CTA label is now deterministic and action-aligned:
    - review path -> `REVIEW`
    - next progression path -> `NEXT LESSON`
    - no progression path -> `FINISH`
    - map-return recommendation path -> `BACK TO MAP`
  - Routing behavior remains unchanged.
- Runtime implementation:
  - `lib/ui_v2/screens/session_result_screen.dart`
  - Added `_primaryCtaLabelV1(...)` and wired primary label to deterministic mapping.
- Minimum proving contracts:
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - Added targeted contract:
    - `session result primary CTA label is NEXT LESSON when no review queue is present`
  - Existing review/progression contracts remained intact.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r64_finish_coherence_closeout_audit_v1.md`
- Continuity note:
  - `# Milestone R65` is defined below via post-R64 evidence-first comparison.

---

# Milestone R65 — Post-Recovery Fresh-State Checkpoint v1 (Early-Path Revalidation Lock)

Counter — R65 100/100 (+100%)

Status: completed (closed).

## Goal
- Determine whether further early-path implementation is still justified after the R58-R64 recovery chain by running one bounded fresh-state revalidation checkpoint, then lock exactly one next move (implementation seam or bounded NO-GO) from current evidence.

## Scope v1 (strict)
- One family only: post-recovery fresh-state reassessment for first-user early path (implementation-light, verify-first).
- Bound to:
  - deterministic inventory of first-user flow after clean state,
  - explicit pass/fail comparison of remaining implementation seams,
  - one bounded direction lock for R66.
- No product/runtime/content behavior changes in R65 unless an SSOT continuity fix is required.
- No broad roadmap replacement, no personalization restart by inertia, no map/onboarding redesign, no scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Reconcile post-R58-R64 evidence set (closeouts + current runtime/test contracts) and produce deterministic first-user flow checkpoint inventory.
- P0.2 Compare exactly three candidates:
  - A) another bounded early-path implementation seam,
  - B) bounded fresh-state/recovery-checkpoint validation direction,
  - C) another bounded weakest-link area only if clearly stronger.
- P0.3 Select one verdict only (`A` / `B` / `C` / `inconclusive`) and lock one bounded R66 direction.
- P0.4 Publish closeout evidence doc and update SSOT continuity without introducing product-scope drift.

## DoD
- Post-recovery candidate comparison is explicit and evidence-backed.
- Exactly one weakest-link verdict is chosen and justified.
- R66 direction is locked as one bounded executable class or one bounded verification/NO-GO path.
- SSOT keeps one authoritative execution line and coherent ACTIVE/NEXT continuity.
- No runtime/test/content feature changes are introduced by R65 execution closeout.

## Gates
- PRE/POST `git status --porcelain` clean.
- No tests required for doc-only R65 definition/update batches.
- If any non-doc surface is touched unexpectedly, STOP and re-scope before proceeding.

## R65 stop rules
- STOP if post-recovery evidence cannot support bounded A/B/C comparison without speculation.
- STOP if more than one implementation family is being selected.
- STOP if R66 cannot be stated as one bounded executable class or one bounded verification/NO-GO path.
- STOP if scope drifts into forced implementation continuation by inertia.

## Counter rubric
- `25%`: post-R64 evidence reconciliation + candidate comparison complete.
- `50%`: explicit weakest-link verdict selected and bounded.
- `75%`: exact R66 direction lock drafted with anti-drift boundaries.
- `100%`: SSOT continuity finalized with one authoritative execution line and closeout evidence recorded.

## Evidence basis (R65 definition)
- Candidate A (another bounded early-path implementation seam):
  - Completeness: medium-high after R58-R64 closures.
  - Local EV: medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if forced without fresh failure evidence.
  - Evidence confidence: medium-low as immediate winner.
  - User-visible impact: medium.
- Candidate B (bounded fresh-state / recovery-checkpoint validation direction):
  - Completeness: medium (needed to verify post-recovery real user-visible state after substantial chain changes).
  - Local EV: high.
  - System EV: high.
  - Strategic EV: high (prevents repair-by-inertia drift, improves next milestone targeting confidence).
  - Scope-explosion risk: low.
  - Evidence confidence: high.
  - User-visible impact: high indirect impact via better next bounded execution choice.
- Candidate C (another bounded weakest-link area):
  - Completeness: medium-high across previously active trust/personalization seams.
  - Local EV: low-medium.
  - System EV: medium.
  - Strategic EV: medium.
  - Scope-explosion risk: medium-high if reopened without dominant evidence.
  - Evidence confidence: low as stronger immediate winner than B.
  - User-visible impact: medium-low.
- Weakest-layer verdict: **B wins**.
- R66 direction lock requirement from R65:
  - Run one bounded fresh-install first-user revalidation milestone only.
  - Lock exactly one of:
    - single dominant implementation seam for follow-on execution, or
    - bounded NO-GO continuation if confidence remains insufficient.
  - Anti-drift boundary: no multi-family implementation bundling during this checkpoint.

## Evidence (R65 execution closeout)
- Validated bounded fresh-state route (repo-backed):
  - map/start-now entry reason seam -> first campaign pack launch -> first runner steps -> first session result -> return/progression implication.
  - Surfaces reconciled:
    - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
    - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
    - `lib/ui_v2/screens/session_result_screen.dart`
    - `lib/services/progress_service.dart`
    - `test/guards/world1_foundations_microtask_contract_test.dart`
    - `test/ui_v2/session_result_screen_contract_test.dart`
    - `test/guards/world_campaign_map_home_contract_test.dart`
- Post-recovery inventory outcome:
  - still-fixed/no-longer-active: R58-R64 closed families remain backed by current contracts.
  - residual: no single implementation-winning seam reached high-confidence dominance.
  - unconfirmed: older broad breakage assumptions not supported by current repo-state route/contracts.
  - newly dominant: need for bounded fresh-install evidence capture over immediate implementation.
- Ranked next-direction verdict:
  - A (another early-path implementation seam): medium EV, lower confidence.
  - B (progression/result continuation): medium-low EV as immediate winner after R64 closure.
  - C (map/progression seam): medium-low EV without fresh failure evidence.
  - D (bounded NO-GO / verification continuation): highest EV and confidence with low scope risk.
  - Weakest-link verdict: **D wins**.
- Closeout audit:
  - `docs/_reviews/r65_fresh_state_checkpoint_closeout_v1.md`
- Continuity note:
  - `# Milestone R66` is defined below from the locked R65 direction.

---

# Milestone R66 — Fresh-Install Early-Path Evidence Capture v1 (Bounded NO-GO/Go Lock)

Counter — R66 100/100 (+100%)

Status: completed (closed).

## Goal
- Execute one bounded fresh-install first-user evidence-capture pass to determine whether a single implementation seam now clearly wins, or whether bounded NO-GO continuation remains correct.

## Scope v1 (strict)
- Verification-only milestone.
- Bound to deterministic first-user route capture:
  - entry/start-now,
  - first launched early session/pack,
  - first several runner steps,
  - first finish/result exit,
  - return/progression implication.
- No runtime/content feature implementation in R66.
- No multi-family cleanup, no roadmap replacement, no personalization/scoring/schema expansion.

## P0 items (ordered)
- P0.1 Execute bounded fresh-install route validation against current contracts and surfaces.
- P0.2 Classify findings into: still-fixed, residual, unconfirmed, newly dominant.
- P0.3 Compare candidates and lock exactly one outcome:
  - single implementation-ready seam for R67, or
  - bounded NO-GO continuation.
- P0.4 Publish closeout evidence and SSOT continuity update.

## DoD
- Fresh-install route is explicitly validated and documented.
- Findings are classified with repo-state support only (no stale assumption carry-over).
- Exactly one direction is locked for R67.
- One authoritative execution line remains intact.

## Gates
- PRE/POST `git status --porcelain` clean.
- If R66 remains doc-only, no tests required.
- If any proof/test surface is touched, run minimum targeted checks plus:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`

## R66 stop rules
- STOP if route definition cannot remain bounded to first-user early path.
- STOP if stale assumptions are treated as active without repo-state support.
- STOP if more than one independent implementation family is selected.
- STOP if R67 cannot be locked as one bounded executable seam or one bounded NO-GO path.

## Counter rubric
- `25%`: bounded route definition + evidence surface lock complete.
- `50%`: post-capture issue inventory classified.
- `75%`: single R67 direction lock drafted with anti-drift boundaries.
- `100%`: closeout evidence published + SSOT continuity finalized.

## Evidence (R66 execution closeout)
- Bounded first-user route validated from repo-backed surfaces:
  - entry/start-now (`today_plan_start_cta` / `world_campaign_next_pack_cta`) on map,
  - first campaign pack launch via `_openCampaignPack(...)`,
  - first runner action steps in `World1FoundationsMicroTaskRunnerScreen`,
  - first result/finish in `SessionResultScreen`,
  - return/progression implication via map/home contracts.
- Surfaces reconciled:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - `lib/ui_v2/screens/session_result_screen.dart`
  - `lib/services/progress_service.dart`
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - `test/guards/world_campaign_map_home_contract_test.dart`
- Current-truth inventory summary:
  - still-fixed/no-longer-issue: R58-R64 selected families remain closed and contract-backed.
  - residual: no single high-confidence implementation winner; remaining seams are distributed low-severity clarity/polish candidates.
  - unconfirmed: broad pre-recovery failure assumptions not supported by current route/contracts.
  - newly dominant: verification confidence calibration before further implementation.
- R67 direction lock:
  - bounded NO-GO on immediate implementation.
  - R67 will run one bounded verification continuation to isolate one implementation-ready seam with high confidence, or reaffirm bounded NO-GO.
- Closeout audit:
  - `docs/_reviews/r66_fresh_install_revalidation_closeout_v1.md`
- Continuity note:
  - `# Milestone R67` is defined below from the locked R66 direction.

---

# Milestone R67 — Fresh-Install Evidence Lock v2 (Single-Seam Isolation Gate)

Counter — R67 100/100 (+100%)

Status: completed (closed).

## Goal
- Isolate one and only one dominant bounded implementation seam (if any) from fresh-install first-user evidence; otherwise reaffirm bounded NO-GO without forcing implementation.

## Scope v1 (strict)
- Verification-first only on first-user early-path route.
- Must compare candidate seams and lock exactly one outcome:
  - one implementation-ready bounded seam, or
  - bounded NO-GO continuation.
- No product feature implementation in R67 unless a single dominant seam is isolated by evidence.
- No multi-family bundling, no roadmap replacement, no personalization/scoring/schema expansion.

## P0 items (ordered)
- P0.1 Re-run bounded fresh-install route verification on current runtime/test surfaces.
- P0.2 Build deterministic seam ranking with confidence and scope-risk criteria.
- P0.3 Lock exactly one next move for R68 (single seam or bounded NO-GO).
- P0.4 Publish closeout evidence and maintain SSOT continuity.

## DoD
- Candidate ranking is evidence-backed and bounded.
- Exactly one R68 direction is locked.
- No forced implementation without dominant seam evidence.
- One authoritative execution line remains intact.

## Gates
- PRE/POST `git status --porcelain` clean.
- If doc-only, no tests required.
- If proof surfaces are touched, run minimum targeted checks plus:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`

## R67 stop rules
- STOP if bounded route cannot be maintained.
- STOP if more than one independent implementation family is selected.
- STOP if stale assumptions override current repo-backed evidence.
- STOP if R68 cannot be locked as one bounded implementation seam or one bounded verification path.

## Counter rubric
- `25%`: bounded route + evidence surfaces reconfirmed.
- `50%`: deterministic seam ranking completed.
- `75%`: single R68 direction lock drafted with anti-drift boundaries.
- `100%`: closeout evidence published + SSOT continuity finalized.

## Evidence (R67 execution closeout)
- Canonical first-user route locked (fresh-install):
  - map entry -> `today_plan_start_cta` / `world_campaign_next_pack_cta`
  - `_handleCampaignStartNowActionV1()`
  - `_resolveEarliestIncompleteWorld1PackIdV1()` -> first unresolved canonical id
  - runner launch via `_openCampaignPack(...)`
  - early runner steps -> first result screen -> return/progression implication.
- Route-truth finding:
  - `kWorld1CanonicalModuleOrder` is Act0-first (`world1_act0_table_literacy` then Act0 chain before spine).
  - This is a confirmed route truth that can invalidate seam selection if future work assumes spine-first path.
- Candidate seam mapping summary:
  - A) facing-bet action-contract seam: plausible adjacent branch; not confirmed as dominant observed-issue source in canonical route.
  - B) finish/result duplication seam: result screen is definitely on route, but dominant issue causality from this branch is unproven.
  - C) action-mode highlight/visual bleed seam: plausible adjacent branch; no strong route-branch symptom proof.
  - D) stronger seam: entry-path pack-branch mismatch risk (Act0-first route truth vs spine-target drift) is confirmed.
- Seam classification outcome:
  - CONFIRMED current-route seam: D (route branch truth seam), plus route presence of B without defect-causality confirmation.
  - PLAUSIBLE but unproven adjacent branches: A, C.
  - NOT SUPPORTED as confirmed issue source: any branch promoted without direct route-branch symptom proof.
- R68 direction lock:
  - bounded NO-GO on implementation; R68 must continue evidence capture to map one exact observed symptom to one exact branch/state before implementation.
- Closeout audit:
  - `docs/_reviews/r67_route_screen_truth_lock_v1.md`
- Continuity note:
  - `# Milestone R68` is defined below from the locked R67 direction.

---

# Milestone R68 — Observed-Symptom Branch Proof v1 (Implementation Gate)

Counter — R68 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove one exact observed first-user symptom maps to one exact runtime branch/state seam so the next implementation milestone cannot target an adjacent seam by mistake.

## Scope v1 (strict)
- Doc-only evidence continuation.
- One symptom only, one branch only, one candidate implementation seam lock only.
- Must remain inside canonical first-user route established in R67.
- No runtime/content feature implementation in R68.
- No multi-family seam bundling, no roadmap redesign, no personalization/scoring/schema expansion.

## P0 items (ordered)
- P0.1 Bind one observed symptom to one route step in canonical first-user path.
- P0.2 Map symptom to exact screen/state/helper seam with explicit proof and missing-proof list.
- P0.3 Lock exactly one outcome for R69:
  - single implementation-ready seam, or
  - bounded NO-GO continuation.
- P0.4 Publish closeout and maintain SSOT continuity.

## DoD
- One exact symptom-to-branch mapping is documented with current-route proof.
- Exactly one R69 direction is locked.
- No implementation scope is forced without branch-proof confidence.
- One authoritative execution line remains intact.

## Gates
- PRE/POST `git status --porcelain` clean.
- Doc-only: no tests required.
- If any proof/test surface is touched, run minimum targeted checks plus:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`

## R68 stop rules
- STOP if symptom cannot be bounded to canonical route.
- STOP if more than one implementation seam is selected.
- STOP if branch is marked confirmed without explicit route/screen/state proof.
- STOP if scope drifts into implementation work.

## Counter rubric
- `25%`: one bounded symptom and canonical step lock complete.
- `50%`: branch/state/seam proof mapping completed.
- `75%`: single R69 direction lock drafted with anti-drift boundaries.
- `100%`: closeout evidence published + SSOT continuity finalized.

## Evidence (R68 execution closeout)
- Canonical Act0-first route proof confirmed:
  - start-now dispatcher `_handleCampaignStartNowActionV1()`,
  - first-pack resolver `_resolveEarliestIncompleteWorld1PackIdV1()`,
  - canonical order starts with `world1_act0_table_literacy`,
  - launch path `_openNextCampaignPackFromSsoT()` -> `_openCampaignPack(...)`.
- Candidate seam mapping outcome:
  - A) action-bar legality/affordance: plausible adjacent, not confirmed dominant on first Act0 route step.
  - B) finish/result duplication: result screen is on route but dominant symptom causality unproven.
  - C) highlight/bleed: plausible adjacent branch, not symptom-confirmed.
  - D) stronger Act0-first seam: confirmed command-style guidance branch with visible `Tap the highlighted seat.` output in early seat-quiz path.
- Exact symptom->branch lock:
  - symptom: command-style low-meaning first-user guidance (`Tap the highlighted seat.`),
  - route step: first Act0 seat-quiz guidance states,
  - seam: seat-quiz instruction fallback branch in `world1_foundations_microtask_runner_screen.dart`.
- Closeout audit:
  - `docs/_reviews/r68_observed_symptom_branch_proof_v1.md`
- Continuity note:
  - `# Milestone R69` is defined below from the locked R68 seam.

---

# Milestone R69 — Act0 Seat-Quiz Guidance Truth-Fix v1 (Single-Seam Execution)

Counter — R69 100/100 (+100%)

Status: completed (closed).

## Goal
- Replace one confirmed command-style first-user Act0 guidance seam with a more meaningful deterministic learning line, without touching adjacent branches.

## Scope v1 (strict)
- One seam only:
  - Act0 seat-quiz instruction fallback branch currently rendering `Tap the highlighted seat.`.
- Bound to:
  - one deterministic wording/presentation family update in runner,
  - minimum proof contracts for selected branch.
- No action-bar legality redesign.
- No result/finish CTA redesign.
- No multi-surface copy sweep.
- No personalization/scoring/schema/dependency changes.

## P0 items (ordered)
- P0.1 Baseline and confirm selected branch/state in Act0-first route.
- P0.2 Define deterministic guidance contract for selected seam.
- P0.3 Implement one bounded seam fix only.
- P0.4 Add minimum targeted proof, publish closeout, and maintain SSOT continuity.

## DoD
- Selected Act0 seat-quiz guidance seam is updated and deterministic.
- Adjacent seams (A/B/C from R68) remain unchanged.
- Route/branch proof remains intact.
- Required gates are green and one authoritative execution line remains.

## Gates
- PRE `git status --porcelain` clean.
- Run:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Add one targeted runner contract proof run for selected seam.
- Run content validators only if content/tooling surfaces are touched unexpectedly.

## R69 stop rules
- STOP if selected branch cannot be kept as one bounded seam.
- STOP if more than one independent seam is being fixed.
- STOP if scope drifts into action-contract/result/progression redesign or broad copy cleanup.
- STOP if deterministic contract cannot be stated clearly.

## Counter rubric
- `25%`: selected branch baseline + contract lock complete.
- `50%`: bounded seam implementation complete.
- `75%`: targeted proof + gates green.
- `100%`: closeout evidence published + SSOT continuity finalized.

## Evidence (R69 execution closeout)
- Locked seam reconfirmed and updated:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Act0 seat-quiz fallback guidance branch no longer emits `Tap the highlighted seat.`.
  - New deterministic purposeful fallback line: `Seat drill: identify the highlighted position.`.
- Bounded wording-family implementation:
  - Added shared seam constant `kAct0SeatQuizFallbackGuidanceTitleV1`.
  - Rewired only locked fallback branch family references to this constant.
  - No action-bar/result/highlight/progression seam behavior changed.
- Minimum proving contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - Added targeted contract:
    - `act0 seat-quiz fallback guidance title is purposeful and deterministic`
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r69_act0_guidance_closeout_audit_v1.md`

---

# Milestone R70 — Blindspot Hardening + Action Seam Recovery Strike v1

Counter — R70 100/100 (+100%)

Status: completed (closed).

## Goal
- Remove two deterministic tooling blindspots that let obvious early-world prompt/feedback defects pass.
- Fix one exact user-visible action-layer seam in early runner flow.
- Keep scope tightly bounded and deterministic.

## Scope v1 (strict)
- Tooling track:
  - add exactly two guard families:
    - prompt `Focus: <action>` leak detection,
    - contradictory `feedback_correct_v1` soft-pass phrase detection.
  - apply only violation-driven world0/world1/world2 cleanup if failures appear.
- Runtime track:
  - one exact action-layer seam only in World1 foundations runner.
- No broad content rewrite, no action-bar redesign, no progression/result redesign, no personalization/schema/ML expansion.

## P0 items (ordered)
- P0.1 Add two deterministic tooling guards in existing validator path.
- P0.2 Run validator and clean only direct world0/world1/world2 violations caused by new guards.
- P0.3 Select and fix one exact runtime action-layer seam.
- P0.4 Add minimum proofs and close milestone with SSOT continuity.

## DoD
- Both new guard classes are active, deterministic, and test-covered.
- Early-world cleanup stays bounded to direct guard failures (or explicit no-op if none).
- Exactly one runtime seam is fixed with deterministic contract proof.
- Required gates are green and one authoritative execution line remains.

## Gates
- PRE/POST `git status --porcelain` clean.
- Required:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Add targeted tooling/runtime tests for touched surfaces.

## R70 stop rules
- STOP if tooling scope expands beyond the two exact blindspots.
- STOP if cleanup expands beyond direct world0/world1/world2 validator failures from those blindspots.
- STOP if runtime scope expands beyond one exact action-layer seam.
- STOP if more than one independent runtime seam is fixed.
- STOP if scope drifts into broad UX/progression/personalization/schema work.

## Counter rubric
- `25%`: tooling guards implemented and validator-wired.
- `50%`: violation-driven cleanup completed (or explicit bounded no-op).
- `75%`: one runtime action seam fixed + targeted proof green.
- `100%`: full gates green + closeout audit + SSOT continuity finalized.

## Evidence (R70 execution closeout)
- Tooling blindspot hardening complete:
  - `tools/why_v1_ssot_v1.dart`
    - `Focus: <action>` guard pattern widened to exact family:
      - `Focus:\s*(fold|call|raise|check|bet|jam|all-in)` (case-insensitive).
    - primary-correct contradiction guard tightened to exact required phrase:
      - `worse than our recommended play`.
  - `tools/validate_world_content_v1.dart`
    - added `prompt_action_focus_leak_v1` checks for:
      - top-level drill `prompt`,
      - `hand_chain_v1` step prompts.
  - `test/tools/why_v1_ssot_v1_test.dart` updated with deterministic coverage for both additions.
- Early-world cleanup result:
  - `dart run tools/validate_world_content_v1.dart` returned no world0/world1/world2 violations from new guard classes.
  - cleanup bounded NO-OP (no direct failing files to edit).
- Runtime seam fixed (one exact family):
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - in spine action-chip branch, `BET` affordance is now suppressed only for facing-bet states that already expose a raise-family affordance.
  - preserves adjacent branches and avoids action-bar redesign.
  - proof strengthened in:
    - `test/guards/world1_foundations_microtask_contract_test.dart`
    - added assertion that deterministic call/fold/raise-to facing-bet set does not render `BET`.
- Gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- Closeout audit:
  - `docs/_reviews/r70_blindspot_and_action_seam_closeout_v1.md`

---

# Milestone R71 — Authoritative Surface Consolidation v1 (First-User Flow)

Counter — R71 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove whether weak visible delta came from fixing secondary seams instead of authoritative first-user surfaces.
- If proven, fix one bounded duplicated/parallel presentation root cause only.

## Scope v1 (strict)
- Audit only first-user phases:
  - entry/map,
  - Act0 seat-quiz/guidance,
  - early action-decision,
  - finish/result,
  - map/progression return.
- Allow one bounded consolidation fix only if duplication/parallel drift is proven.
- No broad redesign, no multi-phase refactor, no feature expansion.

## P0 items (ordered)
- P0.1 Build first-user phase map with exact screens/state families/helpers.
- P0.2 Classify each phase as authoritative/duplicated/insufficient.
- P0.3 Decide one root-cause verdict (A/B/C) from evidence.
- P0.4 Apply one bounded consolidation fix only if B is proven; otherwise lock next seam/proof step.

## DoD
- First-user phase map is explicit and repo-backed.
- Authoritative vs duplicated classification is explicit per phase.
- One exact root-cause verdict is recorded.
- If fixed, exactly one bounded consolidation seam is changed and minimally proven.
- Required gates are green and one authoritative execution line remains.

## Gates
- PRE/POST `git status --porcelain` clean.
- Because executable code changed:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - targeted tests for touched seam.

## R71 stop rules
- STOP if scope expands into broad refactor/redesign.
- STOP if more than one root cause/fix is selected.
- STOP if implementation touches multiple phases.
- STOP if duplication root cause is not clearly proven.

## Counter rubric
- `25%`: phase map and seam inventory complete.
- `50%`: authoritative/duplicated classification complete.
- `75%`: one root-cause verdict locked and bounded action drafted.
- `100%`: bounded consolidation (if applicable) + proofs + SSOT continuity finalized.

## Evidence (R71 execution closeout)
- Phase-map and authoritative-surface audit complete (entry/map, Act0 guidance, action-decision, result, progression-return).
- Root-cause verdict: **B (bounded duplicated/parallel presentation root cause proven)**.
  - Proven duplicated phase:
    - Act0 seat-quiz guidance family in `world1_foundations_microtask_runner_screen.dart`.
  - Why proven:
    - multiple parallel branches could emit guidance for same phase family (target instruction, idle guidance, preview/fallback/header paths, overlay/override paths),
    - prior narrow fixes could hit secondary path while dominant text remained largely unchanged.
- One bounded consolidation fix applied:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - introduced authoritative helper `_seatQuizGuidanceForTargetV1(...)` and routed seat-quiz target/preview/idle guidance family through it.
  - removed command-style `This is ... Tap it.` emissions for the consolidated family.
  - kept compatibility wrapper to avoid multi-phase drift.
- Minimal proof updated:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - strengthened `lock in stays disabled until a seat is selected` contract to assert highlighted-position guidance family and no old command-style phrase.
  - targeted seat-quiz instruction/target matching contract remains green.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Closeout audit:
  - `docs/_reviews/r71_authoritative_surface_audit_v1.md`

---

# Milestone R72 — Authoritative Path Registry + Duplication Audit v1

Counter — R72 100/100 (+100%)

Status: completed (closed).

## Goal
- Establish authoritative ownership across main first-user phases and critical secondary flows.
- Prove duplication/shadow/legacy seams with exact overlap evidence.
- Provide a concrete consolidation registry and plan to prevent future wrong-target fixes.

## Scope v1 (strict)
- Audit + consolidation plan only (doc-first).
- Required phases:
  - entry/map/home/today-plan,
  - start-now route resolution,
  - Act0 onboarding/seat guidance,
  - seat-quiz phase,
  - action phase,
  - result/finish/up-next,
  - return/progression continuity,
  - checkpoint/review queue/world transition/track handoff.
- No broad runtime refactor.

## P0 items (ordered)
- P0.1 Build full authoritative phase map with route/screen/helper/state/test owners.
- P0.2 Classify each phase: clean/wrong/duplicated/shadow/insufficient.
- P0.3 Publish explicit ownership registry with “target vs avoid” files.
- P0.4 Produce bounded consolidation plan and deterministic guard strategy.

## DoD
- All required phases have explicit authoritative ownership mapping.
- Duplication/shadow claims include exact overlapping-responsibility evidence.
- Registry is concrete enough to guide future fix targeting.
- Consolidation plan is grouped into must/freeze/archive/as-is/proof-needed.
- One authoritative execution line remains.

## Gates
- PRE/POST `git status --porcelain` clean.
- Doc-only: no tests required.

## R72 stop rules
- STOP if this becomes a broad refactor.
- STOP if duplication claims are not evidence-backed.
- STOP if more than one large implementation action is bundled.
- STOP if output cannot identify authoritative vs avoid paths concretely.

## Counter rubric
- `25%`: phase map completed.
- `50%`: duplication/shadow classification completed with proof notes.
- `75%`: ownership registry completed.
- `100%`: consolidation plan + guard strategy + closeout + SSOT continuity complete.

## Evidence (R72 execution closeout)
- Full authoritative phase mapping completed across all required primary + secondary flows.
- Confirmed project-wide ownership picture:
  - map/start-now and progression ownership is authoritative and clean,
  - runner action and result ownership are authoritative and clean,
  - checkpoint/review/track ownership remains anchored in map/result entry + `ProgressService`.
- Confirmed duplicated/shadow hotspot:
  - Act0 seat-quiz guidance family had parallel responsibility history; R71 consolidation established authoritative helper ownership.
- Published registry and consolidation plan:
  - `docs/_reviews/r72_authoritative_path_registry_audit_v1.md`
  - includes target/avoid ownership rows, freeze/deprecate candidates, archive-later candidates, and proof-needed seams.

---

# Milestone R73 — Authoritative Action-Bar Legality Guard (Facing-Bet Semantics)

Counter — R73 100/100 (+100%)

Status: completed (closed).

## Goal
- Ship one bounded resilience guard on the authoritative World1 action-phase surface so facing-bet states never render misleading `CHECK`/generic `BET` affordances.

## Scope v1 (strict)
- One runtime seam only:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - authoritative action-chip builder for campaign spine action phase.
- One test surface only:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
- No action-bar redesign, no finish/progression work, no content rewrite.

## P0 items (ordered)
- P0.1 Confirm authoritative action-chip seam and bounded insertion point.
- P0.2 Enforce facing-bet legality contract (`CHECK` + generic `BET` not rendered).
- P0.3 Preserve legal raise-family affordance and non-facing behavior.
- P0.4 Add minimal deterministic contract proof and run required gates.

## DoD
- Facing-bet state does not render `CHECK`.
- Facing-bet state does not render generic `BET`.
- Legal aggressive affordance remains present where expected.
- Non-facing behavior remains contract-green.
- Required gates are green and one authoritative execution line remains.

## Gates
- PRE/POST `git status --porcelain` clean.
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## R73 stop rules
- STOP if scope expands beyond one facing-bet legality family.
- STOP if implementation drifts into redesign or adjacent seams.
- STOP if more than one runtime seam is changed.

## Counter rubric
- `25%`: authoritative seam confirmed.
- `50%`: bounded legality guard implemented.
- `75%`: targeted contracts updated and deterministic.
- `100%`: all gates green + closeout audit + SSOT continuity finalized.

## Evidence (R73 execution closeout)
- Runtime seam fix:
  - in `_buildCampaignActionChips(...)`, facing-bet semantics now suppress generic `BET` display by relabeling the aggressive chip to raise-family wording (`RAISE TO`) for that state family.
  - `CHECK` suppression under facing-bet state remains enforced.
- Contract proof:
  - strengthened facing-bet preflop action-state invariant to require `BET` absent while preserving legal aggressive affordance.
  - expected-action tap matcher updated to deterministically handle aggressive chip naming parity (`BET` or `RAISE*`) on bet-kind expected steps.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`
- Closeout audit:
  - `docs/_reviews/r73_action_bar_legality_closeout_v1.md`

---

# Milestone R74 — Authoritative User-Visible Surface Registry v1

Counter — R74 100/100 (+100%)

Status: completed (closed).

## Goal
- Consolidate one practical, project-level authoritative ownership registry for major user-visible phases so future fixes land on real product seams instead of secondary/shadow paths.

## Scope v1 (strict)
- Doc-only registry consolidation using verified evidence from R67-R73 and current runtime/test ownership surfaces.
- Cover required phases:
  - entry/map/home/today-plan,
  - start-now/route resolution/first-pack launch,
  - Act0 onboarding and seat guidance,
  - runner seat phase,
  - runner action phase,
  - result/finish/up-next,
  - return/progression continuity,
  - checkpoint/review/world transition/track handoff.
- No runtime refactor, archive/delete execution, or feature work.

## P0 items (ordered)
- P0.1 Build explicit phase registry with route/screen/helper/state/test owners.
- P0.2 Classify branches per phase (authoritative/secondary/fallback/legacy-risk/avoid/proof-gap).
- P0.3 Publish practical future-fix target-vs-avoid guidance per phase.
- P0.4 Record deferred consolidation guidance (addressed hotspots, residual risks, future retirement candidates).

## DoD
- One reusable registry document exists and covers all required user-visible phases.
- Labels are evidence-backed; no inflated legacy/shadow tags without support.
- Each phase includes explicit “MUST target” and “AVOID unless re-authorized” guidance.
- Deferred consolidation guidance is concrete and bounded.
- One authoritative execution line remains in SSOT.

## Gates
- PRE/POST `git status --porcelain` clean.
- Doc-only milestone: no tests required.

## R74 stop rules
- STOP if this turns into broad refactor/cleanup.
- STOP if phase labels are not evidence-backed.
- STOP if registry is too vague to guide real bug-fix targeting.

## Counter rubric
- `25%`: full phase coverage drafted.
- `50%`: branch classification completed with evidence basis.
- `75%`: future-fix target/avoid guidance completed.
- `100%`: deferred consolidation guidance + closeout + SSOT continuity finalized.

## Evidence (R74 execution closeout)
- Consolidated authoritative ownership and branch classification into one practical registry:
  - `docs/_reviews/r74_authoritative_user_visible_surface_registry_v1.md`
- Registry aligns route/screen/helper/state ownership across map, runner, result, and progression service.
- Registry explicitly carries forward proven duplication facts:
  - Act0 seat-quiz guidance hotspot (proven and addressed in R71).
- Registry flags residual risks as unproven where evidence is insufficient (no over-labeling).
- Continuity note:
  - `# Milestone R75` is not yet defined; define it before any R75 execution work.

---

# Milestone R75 — Authoritative Early Action Truth Contradiction Fix (Illegal Expected/Why Family)

Counter — R75 100/100 (+100%)

Status: completed (closed).

## Goal
- Eliminate one P0 contradiction family on the authoritative early action path: illegal expected-action label (notably `Expected: CHECK` while facing a live bet) and resulting semantic mismatch with why-line family.

## Scope v1 (strict)
- One authoritative runtime helper chain only in:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- One targeted contract surface only in:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
- No broad content sweep, no action-bar redesign, no result/progression redesign.

## P0 items (ordered)
- P0.1 Confirm one contradiction family and authoritative seam.
- P0.2 Enforce legality-normalized expected-action rendering for that family.
- P0.3 Enforce expected/why mismatch coherence for same family.
- P0.4 Add minimal deterministic proof and run required gates.

## DoD
- Facing-bet contradiction family can no longer render `Expected: CHECK`.
- Expected label and mismatch reasoning share one legality-normalized expected-action resolver.
- Why-line remains semantically coherent with legal family in selected state.
- Required gates are green and SSOT continuity remains single-line authoritative.

## Gates
- PRE/POST `git status --porcelain` clean.
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## R75 stop rules
- STOP if scope expands beyond one contradiction family.
- STOP if more than one independent runtime seam is changed.
- STOP if this turns into broad feedback/content cleanup.

## Counter rubric
- `25%`: contradiction family and seam confirmed.
- `50%`: bounded truth contract implemented.
- `75%`: targeted deterministic proof added.
- `100%`: gates green + closeout audit + SSOT continuity finalized.

## Evidence (R75 execution closeout)
- Root cause confirmed:
  - explicit expected-action precedence could bypass legality for live `toCall` state and emit illegal expected family.
- Runtime fix:
  - `world1SpineExpectedActionKindV1(...)` now normalizes illegal explicit expected actions against state (`toCall`) + allowed-action family.
  - `world1SpineOutcomeExpectedLineV1(...)` now renders from normalized expected-action resolver only.
  - `_isExpectedActionMismatchV1(...)` now compares selected action against normalized expected action (not explicit-only).
- Targeted proof:
  - added contract checks:
    - facing-bet explicit check source cannot render `Expected: CHECK`,
    - why-line remains in call/raise family for selected facing-bet contradiction scenario.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`
- Closeout audit:
  - `docs/_reviews/r75_action_truth_contradiction_closeout_v1.md`
- Continuity note:
  - `# Milestone R76` is not yet defined; define it before any R76 execution work.

---

# Milestone R76 — Surviving Authoritative Early Action Truth Contradiction Fix v1

Counter — R76 100/100 (+100%)

Status: completed (closed).

## Goal
- Eliminate the surviving contradiction still visible on authoritative early action feedback after R75 by fixing the exact sibling branch/state family and proving non-recurrence under contract.

## Scope v1 (strict)
- One authoritative runtime seam family only in:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- One targeted contract surface only in:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
- No broad feedback/content cleanup, no action-bar redesign, no progression/result redesign.

## P0 items (ordered)
- P0.1 Reproduce and isolate surviving contradiction family (same-family vs sibling-family verdict required).
- P0.2 Add failing repro-grade contract first.
- P0.3 Implement one bounded truth-precedence fix for selected family.
- P0.4 Prove exact recurrence class is closed on authoritative path.

## DoD
- Surviving contradiction family is explicitly classified (runtime/content/mixed and same vs sibling relative to R75).
- Repro-grade contract fails before fix and passes after fix.
- Selected mismatch branch expected/why semantics are legality-coherent under identical state.
- Required gates are green and SSOT continuity stays authoritative.

## Gates
- PRE/POST `git status --porcelain` clean.
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## R76 stop rules
- STOP if exact surviving family cannot be distinguished from adjacent families.
- STOP if repro-grade failing contract is not added first.
- STOP if more than one independent runtime seam is changed.
- STOP if scope drifts into broad feedback/content cleanup.

## Counter rubric
- `25%`: surviving contradiction family isolated and classified.
- `50%`: repro-grade contract added and confirmed failing pre-fix.
- `75%`: one bounded runtime fix implemented.
- `100%`: gates green + closeout audit + SSOT continuity finalized.

## Evidence (R76 execution closeout)
- Surviving family confirmed as **sibling branch** to R75:
  - first-decision EngineV2 mismatch branch still sourced expected action from explicit metadata in authoritative outcome path.
- Runtime fix:
  - introduced mismatch expected-action resolver hook and switched first-decision mismatch branch to legality-normalized expected action.
- Repro-grade contract:
  - `world1 spine mismatch expected action normalizes facing-bet explicit check in authoritative mismatch branch`
  - failed pre-fix (`expected raise`, `actual check`) and passes post-fix.
- Required gates PASS:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`
- Closeout audit:
  - `docs/_reviews/r76_surviving_action_truth_closeout_v1.md`
- Continuity note:
  - `# Milestone R77` is not yet defined; define it before any R77 execution work.

---

# Milestone R77 — Scenario Truth Foundation v1 + World1 Repro Matrix v1 + Phase Contracts v1

Counter — R77 100/100 (+100%)

Status: completed (closed).

## Goal
- Establish concrete World1-scoped scenario-truth foundations so future fixes land on authoritative first-user seams with stronger anti-regression guarantees.

## Scope v1 (strict)
- Doc-first, World1 pilot only:
  - scenario truth foundation,
  - ownership boundaries and anti-regression rules,
  - World1 scenario inventory,
  - focused repro matrix,
  - phase contracts,
  - validator/normalizer responsibility split,
  - bounded migration path.
- No broad runtime refactor, no broad content rewrite, no Worlds2-10 migration, no archive/delete execution.

## P0 items (ordered)
- P0.1 Scenario Truth Foundation v1 definition (minimal practical contract fields).
- P0.2 Ownership/anti-regression boundary lock for migration-era runtime guards.
- P0.3 World1 scenario inventory by family and migration priority.
- P0.4 Focused high-EV repro matrix for first-user pilot risks.
- P0.5 Phase contracts for map/start-now, Act0, seat, action, outcome, result, progression return.
- P0.6 Validator/normalizer plan and World1-only migration path lock.

## DoD
- Artifacts are concrete, World1-scoped, and actionable for implementation sequencing.
- Anti-regression boundaries clearly separate validation-time truth vs runtime migration guards.
- Repro matrix is focused and tied to authoritative renderer/seam ownership.
- Phase contracts define allowed vs forbidden outputs per first-user phase.

## Gates
- PRE/POST `git status --porcelain` clean.
- Doc-only milestone: no tests required.

## R77 stop rules
- STOP if this becomes broad World1 rewrite or architecture essay.
- STOP if Worlds2-10 implementation scope is introduced.
- STOP if schema/contract design grows beyond practical pilot needs.
- STOP if phase contracts or repro matrix are too vague to guide implementation.

## Counter rubric
- `25%`: foundation contract + boundaries drafted.
- `50%`: inventory + repro matrix drafted with authoritative ownership links.
- `75%`: phase contracts + validator/normalizer split drafted.
- `100%`: migration path + closeout artifacts + SSOT continuity finalized.

## Evidence (R77 execution closeout)
- Scenario truth foundation artifact:
  - `docs/_reviews/r77_scenario_truth_foundation_v1.md`
- World1 pilot inventory artifact:
  - `docs/_reviews/r77_world1_scenario_inventory_v1.md`
- Focused repro matrix artifact:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md`
- First-user phase contracts artifact:
  - `docs/_reviews/r77_world1_phase_contracts_v1.md`
- World1-only migration path locked:
  - Phase A foundation -> Phase B pilot migration -> Phase C fresh-install validation -> Phase D consider wider rollout.
- Continuity note:
  - `# Milestone R78` executes the first bounded World1 scenario truth pilot migration.

---

# Milestone R78 — World1 Scenario Truth Pilot Migration v1

Counter — R78 100/100 (+100%)

Status: completed (closed).

## Goal
- Execute the first real World1 Scenario Truth migration so the two highest-EV contradiction families stop relying on scattered runtime truth.

## Scope v1 (strict)
- Pilot families only:
  - `action_choice / early decision`
  - `hand-loop mismatch / footer feedback`
- Allowed:
  - bounded runtime truth-path migration on authoritative runner seam,
  - bounded validator strengthening for pilot families,
  - targeted contracts.
- Not allowed:
  - broad World1 rewrite,
  - Worlds2-10 migration,
  - broad result/progression redesign,
  - archive/delete cleanup.

## DoD
- Both pilot families flow through one scenario-truth compiler path as primary truth source for expected/why/feedback/focus context in covered runtime surfaces.
- Pilot validator checks enforce:
  - illegal expected-action detection,
  - expected/why coherence,
  - acceptable/legal coherence,
  - required contextual focus presence,
  - pilot family completeness.
- Highest-EV pilot contradiction classes are guarded by direct contract and validator proof.
- Deterministic behavior preserved outside pilot families.

## Gates
- PRE/POST `git status --porcelain` clean.
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `dart run tools/validate_world_content_v1.dart`
- `dart run tools/run_content_qa_r2_v1.dart`
- targeted pilot contracts:
  - `flutter test test/guards/world1_scenario_truth_pilot_contract_test.dart`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## R78 stop rules
- STOP if scope expands beyond the two pilot families.
- STOP if runtime remains undeclared primary pedagogical truth for migrated pilot families.
- STOP if anti-regression boundaries are unclear.
- STOP on first sign of scope creep.

## Counter rubric
- `25%`: pilot family scope and authoritative seams confirmed.
- `50%`: pilot scenario-truth compiler and bounded runtime consumption implemented.
- `75%`: validator checks for pilot truth invariants implemented.
- `100%`: gates green, repro-matrix effect recorded, closeout audit and SSOT continuity finalized.

## Evidence (R78 execution closeout)
- Pilot closeout audit:
  - `docs/_reviews/r78_world1_scenario_truth_pilot_closeout_v1.md`
- Pilot truth compiler:
  - `lib/campaign/world1_scenario_truth_pilot_v1.dart`
- Authoritative runtime adoption:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Validator strengthening:
  - `tools/validate_world_content_v1.dart`
- Targeted pilot proof:
  - `test/guards/world1_scenario_truth_pilot_contract_test.dart`
- Repro matrix updated:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md`

---

# Milestone R79 — World1 Fresh-Install Route Truth Lock v1

Counter — R79 100/100 (+100%)

Status: completed (closed).

## Goal
- Lock and prove the first-user Start Now route truth on authoritative map/progress seams:
  - `Start Now -> Act0-first -> runner ownership`.

## Scope v1 (strict)
- Authoritative surfaces only:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/services/progress_service.dart`
- Minimum contract strengthening only where needed.
- No Scenario Truth family expansion; no result/finish scope.

## DoD
- Fresh-install/zero-progress Start Now path deterministically opens `world1_act0_table_literacy`.
- Earliest-incomplete World1 ladder is contract-locked through Act0 -> spine boundary.
- Start Now ownership remains map/progress seam and is regression-guarded.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted route-truth contract:
  - `flutter test test/guards/world_campaign_map_home_contract_test.dart`

## Evidence (R79 execution closeout)
- Closeout audit:
  - `docs/_reviews/r79_world1_fresh_install_route_truth_lock_closeout_v1.md`
- Contract strengthening:
  - `test/guards/world_campaign_map_home_contract_test.dart`
- Repro matrix status update:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md` (`W1-RM-003` now route-truth guarded).
- Continuity note:
  - `# Milestone R80` closes result/finish coherence on the authoritative seam.

---

# Milestone R80 — World1 Result/Finish Coherence Lock v1

Counter — R80 100/100 (+100%)

Status: completed (closed).

## Goal
- Close the remaining World1 pilot seam risk after R78/R79:
  - `W1-RM-005` result/finish coherence on authoritative result/progression seam.

## Scope v1 (strict)
- Authoritative surfaces only:
  - `lib/ui_v2/screens/session_result_screen.dart`
  - `lib/services/progress_service.dart`
  - minimal targeted contracts
- No new Scenario Truth family migration and no broad result/map redesign.

## DoD
- Authoritative finish chain is proof-locked:
  - one coherent completion framing family,
  - deterministic next-step/return handoff,
  - no duplicate conflicting finish states on primary seam.
- Progression write/update behavior on result seam is contract-guarded for idempotent completion behavior.
- `W1-RM-005` updated from open to guarded.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted result/finish seam contract:
  - `flutter test test/ui_v2/session_result_screen_contract_test.dart`

## Evidence (R80 execution closeout)
- Closeout audit:
  - `docs/_reviews/r80_world1_result_finish_coherence_lock_closeout_v1.md`
- Contract strengthening:
  - `test/ui_v2/session_result_screen_contract_test.dart`
- Repro matrix status update:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md` (`W1-RM-005` now guarded by result/finish coherence lock).
- Continuity note:
  - `# Milestone R81` delivers one bounded Gold Learning Slice on a World1-first action path.

---

# Milestone R81 — Gold Learning Slice v1 (Explain -> Do -> Confirm)

Counter — R81 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove one canonical product learning slice with short pre-click teaching context on a bounded World1-first path.

## Scope v1 (strict)
- Single bounded path only:
  - `world1_spine_campaign_v1` first actionable step.
- Authoritative seam only:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - targeted guard tests.
- No broad theory system or multi-path migration.

## DoD
- Selected slice demonstrates `Explain -> Do -> Confirm`:
  - short contextual setup,
  - required focus cue,
  - action task,
  - factual `Why` on incorrect,
  - immediate reinforcement cue on correct.
- Flow remains deterministic and bounded.
- Contract coverage fails if the slice regresses into blind-click behavior.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted slice contract:
  - `flutter test test/guards/world1_gold_learning_slice_v1_contract_test.dart`

## Evidence (R81 execution closeout)
- Closeout audit:
  - `docs/_reviews/r81_world1_gold_learning_slice_closeout_v1.md`
- Runtime slice implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R82` expands the same path from one slice to a bounded adjacent cluster.

---

# Milestone R82 — Gold Learning Cluster v1 (bounded adjacent expansion)

Counter — R82 100/100 (+100%)

Status: completed (closed).

## Goal
- Extend R81 from one canonical slice to a small adjacent cluster on the same World1-first path, proving the pattern is reusable and still deterministic.

## Scope v1 (strict)
- Same path only:
  - `world1_spine_campaign_v1` early adjacent actionable cluster (steps 1-3).
- Authoritative seam only:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - targeted guard tests.
- No broad rollout, no new schema program, no multi-world expansion.

## DoD
- Covered cluster steps keep:
  - short pre-click setup line,
  - explicit required-focus cue,
  - action task continuity,
  - factual `Why` on incorrect path.
- Compact reinforcement remains selective (non-spam) on expected covered-correct path.
- Deterministic behavior remains stable outside covered cluster.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted cluster contract:
  - `flutter test test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- directly affected deterministic runner contract:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## Evidence (R82 execution closeout)
- Closeout audit:
  - `docs/_reviews/r82_world1_gold_learning_cluster_closeout_v1.md`
- Runtime cluster expansion:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R83` formalizes the production authoring contract after the bounded runtime proof.

---

# Milestone R83 — Gold Learning Authoring Contract v1

Counter — R83 100/100 (+100%)

Status: completed (closed).

## Goal
- Lock a compact production authoring standard for early gold-learning steps based on R81/R82 proven behavior.

## Scope v1 (strict)
- Docs/contract surfaces only.
- No additional runtime rollout.
- No broad content rewrite or schema expansion.
- No multi-world changes.

## DoD
- Canonical early-step production contract is documented and finalized:
  - short setup/context,
  - explicit focus cue,
  - action/task,
  - factual incorrect why,
  - selective compact correct reinforcement.
- Copy constraints and anti-patterns are explicitly locked.
- Future bounded rollout guidance is explicit.

## Gates
- Doc-only milestone: no test execution required.

## Evidence (R83 execution closeout)
- Authoring contract:
  - `docs/_reviews/r83_gold_learning_authoring_contract_v1.md`
- Closeout note:
  - `docs/_reviews/r83_world1_gold_learning_authoring_contract_closeout_v1.md`
- Continuity note:
  - `# Milestone R84` applies the contract to one bounded literacy-oriented slice.

---

# Milestone R84 — Gold Learning Literacy Slice v1 (understand -> act)

Counter — R84 100/100 (+100%)

Status: completed (closed).

## Goal
- Deliver one bounded literacy-oriented gold slice that explicitly teaches `what this is` and `why it matters` before action.

## Scope v1 (strict)
- Single bounded host step on existing authoritative seam:
  - `world1_spine_campaign_v1` step 1 (index 0).
- Runtime seam + targeted contract only.
- No broad rollout, no multi-street/sizing, no schema expansion.

## DoD
- Selected slice now demonstrates:
  - short concept setup,
  - short value framing (`Why it matters`),
  - explicit focus cue,
  - action/task,
  - factual incorrect `Why`,
  - compact selective reinforcement behavior.
- Contract fails if literacy setup disappears or slice regresses to blind-tap.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted literacy contract:
  - `flutter test test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- directly affected deterministic runner contract:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## Evidence (R84 execution closeout)
- Closeout audit:
  - `docs/_reviews/r84_world1_gold_learning_literacy_slice_closeout_v1.md`
- Runtime literacy slice update:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R85` expands literacy framing to the smallest adjacent cluster on the same seam.

---

# Milestone R85 — Gold Learning Literacy Cluster v1

Counter — R85 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove literacy-oriented gold framing is reusable beyond one slice via the smallest adjacent cluster on the same World1-first path.

## Scope v1 (strict)
- Same path only:
  - `world1_spine_campaign_v1` literacy-covered adjacent cluster (step indexes `0-1`).
- Authoritative runner seam + targeted contracts only.
- No broad rollout, no schema expansion, no theory framework.

## DoD
- Covered cluster steps consistently retain:
  - short concept setup,
  - short `Why it matters` framing,
  - explicit focus cue,
  - action task,
  - factual incorrect `Why`.
- Contract proves no unexpected literacy leakage onto uncovered adjacent step.
- Deterministic behavior remains stable outside covered cluster.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted literacy cluster contract:
  - `flutter test test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- directly affected deterministic runner contract:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## Evidence (R85 execution closeout)
- Closeout audit:
  - `docs/_reviews/r85_world1_gold_learning_literacy_cluster_closeout_v1.md`
- Runtime cluster gate update:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_gold_learning_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R86` should stay bounded to one compact rollout or enforcement step.

---

# Milestone R86 — Concept-First Gold Micro-Slice v1 (understand the concept, then act)

Counter — R86 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove one bounded concept-first micro-slice where concept understanding is shown before action (`Understand -> Act -> Confirm`).

## Scope v1 (strict)
- Single host only on authoritative runner seam:
  - `world1_act0_table_literacy` step index `0` (first seat concept drill).
- Runtime + targeted contract only.
- No broad rollout, no theory framework, no schema expansion.

## DoD
- Selected micro-slice now shows:
  - short concept setup (`what this is`),
  - short value framing (`Why it matters`),
  - explicit focus cue (`Notice`),
  - identify/select action task,
  - factual incorrect `Why`,
  - compact correct reinforcement.
- Contract fails if concept framing/why regresses or slice falls back to blind-tap behavior.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted concept-first contract:
  - `flutter test test/guards/world1_concept_first_micro_slice_v1_contract_test.dart`
- directly affected deterministic runner contract:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## Evidence (R86 execution closeout)
- Closeout audit:
  - `docs/_reviews/r86_world1_concept_first_gold_micro_slice_closeout_v1.md`
- Runtime micro-slice update:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_concept_first_micro_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R87` should prove bounded adjacent concept-first reuse.

---

# Milestone R87 — Concept-First Gold Cluster v1 (bounded adjacent reuse)

Counter — R87 100/100 (+100%)

Status: completed (closed).

## Goal
- Prove concept-first teaching is reusable beyond one micro-slice by expanding to the smallest adjacent cluster on the same early authoritative path.

## Scope v1 (strict)
- Same host path only:
  - `world1_act0_table_literacy` concept-first covered step indexes `0-1`.
- Authoritative runner seam + targeted contract only.
- No broad rollout, no theory framework, no schema expansion.

## DoD
- Covered cluster steps consistently retain:
  - short concept setup,
  - short `Why it matters`,
  - explicit `Notice` focus cue,
  - identify/select action,
  - factual incorrect `Why`,
  - compact correct `Reinforce` where expected.
- Contract proves concept-first framing does not leak to uncovered adjacent step.
- Deterministic behavior remains stable outside covered cluster.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted concept-first cluster contract:
  - `flutter test test/guards/world1_concept_first_micro_slice_v1_contract_test.dart`
- directly affected deterministic runner contract:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart`

## Evidence (R87 execution closeout)
- Closeout audit:
  - `docs/_reviews/r87_world1_concept_first_gold_cluster_closeout_v1.md`
- Runtime cluster gate update:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Targeted anti-regression proof:
  - `test/guards/world1_concept_first_micro_slice_v1_contract_test.dart`
- Continuity note:
  - `# Milestone R88` should lock reset/start-now route truth on authoritative seam.

---

# Milestone R88 — Fresh Reset / Start Now Runtime Path Audit and Lock

Counter — R88 100/100 (+100%)

Status: completed (closed).

## Goal
- Resolve and lock authoritative truth for `dev reset -> Start Now -> first pack` using runtime evidence on the map/progress seam.

## Scope v1 (strict)
- Authoritative reset + route seams only:
  - `lib/services/progress_service.dart`
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - minimal targeted contract proof.
- No teaching rollout, no map/result redesign, no broad refactor.

## DoD
- Authoritative ownership chain is proven:
  - reset clear state and Start Now read state are aligned.
- After authoritative reset on progressed state, Start Now deterministically routes to:
  - `world1_act0_table_literacy`.
- Contract fails if reset/read state diverges or Start Now skips Act0-first after reset.

## Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- targeted reset/start-now truth contract:
  - `flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "reset spine progress clears Start-Now read state and routes fresh to act0 table first"`
- directly affected deterministic map/progression contract:
  - `flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "campaign START NOW launches earliest incomplete world1 node"`

## Evidence (R88 execution closeout)
- Closeout audit:
  - `docs/_reviews/r88_fresh_reset_start_now_runtime_path_audit_lock_closeout_v1.md`
- Targeted anti-regression proof:
  - `test/guards/world_campaign_map_home_contract_test.dart`
- Continuity note:
  - `# Milestone R89` should remain a compact bounded post-R88 step.

---

# Milestone switching rule
- Only one milestone counter is ACTIVE at a time.
- Finish the ACTIVE milestone to 100/100, then switch ACTIVE counter to the next milestone in order (R0 -> R1 -> R2 -> R3 -> R4 -> R5 -> R6 -> R7 -> R8 -> R9 -> R10 -> R11 -> R12 -> R13 -> R14 -> R15 -> R16 -> R17 -> R18 -> R19 -> R20 -> R21 -> R22 -> R23 -> R24 -> R25 -> R26 -> R27 -> R28 -> R29 -> R30 -> R31 -> R32 -> R33 -> R34 -> R35 -> R36 -> R37 -> R38 -> R39 -> R40 -> R41 -> R42 -> R43 -> R44).
- Current execution state: ACTIVE=R89; NEXT=R90; R88 completed (closed); R0-R88 completed (closed).
- Do not start new milestone work early, except doc-only planning.

END OF DOCUMENT.
