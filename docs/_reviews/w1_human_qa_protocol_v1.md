# W1 Human QA Protocol v1

Status: ACCEPTED protocol artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_human_qa_protocol_ready`

The W1 Human QA gate is now protocol-ready and execution-deferred.

This artifact defines the novice tester profile, session script, observation
questions, scoring rubric, severity model, pass/fail thresholds, W1 9.0 gate,
and reuse path for later Volume I testing.

Human QA was not executed in this wave. W1 remains `8.0`, not 9.0, not
launch-ready, and not externally validated.

## 2. Source Truth

Inspected docs and why:

- `AGENTS.md`: repo scope, active root, Act0 boundary, graphify rules, and
  validation expectations.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  route/readiness authority split.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W1-W12 launch target,
  top-1 claim boundaries, and human QA before public learning claims.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active
  long-horizon ledger and W1 Human QA Protocol pointer.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1 score, scoring rules,
  Human QA status, and remaining W1 9.0 blockers.
- `docs/_reviews/w1_8_0_certification_review_v1.md`: accepted W1 8.0
  certification decision and W1 9.0/10.0 gate list.
- `docs/_reviews/w1_poker_correctness_review_protocol_v1.md`: correctness
  review protocol, Human QA separation, and novice-understanding risks.
- `docs/_reviews/w1_bet_size_vocabulary_correctness_repair_v1.md`: accepted
  repair that cleared the P1 bet-size correctness blocker before Human QA.
- `docs/_reviews/w1_coverage_expansion_pr3_v1.md`: accepted six-family W1
  fixture coverage, 36-task evidence, and route-safety boundary.

Advisory navigation:

- `graphify query "W1 Human QA Protocol novice QA gate W1 9.0 payoff progression next non-human blocked wave"`

## 3. Current W1 State

- W1 holds `8.0` as a certification-passed candidate.
- W1 has six schema-backed concept families:
  `position_action_order`, `starting_hand_discipline`,
  `seat_role_orientation`, `card_board_orientation`,
  `bet_size_vocabulary_preview`, and `world1_checkpoint_synthesis`.
- The intended W1 coverage fixture set has 36/36 coverage-countable tasks.
- W1 L2/L3 validation and foundation validation pass for the accepted fixture
  evidence.
- W1 Poker Correctness Review found no P0 blocker.
- The only P1 found by that review, the bet-size vocabulary source boundary,
  was repaired in `w1_bet_size_vocabulary_correctness_repair_v1`.
- Human QA remains required because validators and correctness review cannot
  prove novice comprehension, perceived learning, confusion points, or desire
  to continue.
- W1 also still needs payoff/progression certification before any 9.0 or
  launch-ready language.

## 4. QA Tester Profile

Target tester:

- beginner or novice poker learner;
- not a poker expert, solver user, coach, or advanced study-tool user;
- understands ordinary app navigation;
- can speak aloud or write short answers in English;
- has not recently authored or reviewed Sharky W1 content.

Recommended later batch:

- 3-5 testers;
- one W1 session per tester;
- one observer per session;
- one consolidated issue review after the batch.

Tester exclusion:

- do not use product authors, engineers, poker experts, or anyone who already
  knows the expected W1 answers well;
- do not coach the tester during tasks except for app-control help that does
  not explain poker content.

## 5. QA Session Script

### 5.1 Setup

Observer says:

> This is a poker learning app test. We are testing whether the app explains
> itself clearly, not whether you are good at poker. Please think aloud when
> something feels confusing.

Record before start:

- tester poker experience: none / beginner / casual / experienced;
- confidence reading a poker table from 1-5;
- confidence choosing simple poker actions from 1-5;
- expected time available;
- device and app version or commit tested.

### 5.2 First-Run Pass

Tester does:

- starts W1 from the normal learner-facing entry;
- completes the selected W1 representative route or certified W1 sample path;
- reads prompts and feedback normally;
- does not receive poker hints from the observer.

Observer records:

- time to understand the first actionable task;
- every visible pause longer than 10 seconds;
- every wrong answer and whether feedback helps recovery;
- every verbal confusion point;
- every moment where the tester says they are guessing;
- every place where app controls, copy, or feedback block progress;
- whether the tester can continue without observer explanation.

### 5.3 Concept-Family Checks

After each W1 concept-family segment, ask:

1. What was this part trying to teach?
2. What did you look at before answering?
3. Did the feedback explain why your answer was right or wrong?
4. Was any word or poker term unclear?
5. Did you feel like you were learning or guessing?

Apply this to the six W1 families:

- position/action order;
- starting-hand discipline;
- seat-role orientation;
- card/board orientation;
- bet-size vocabulary preview;
- checkpoint synthesis.

### 5.4 End Questions

Ask at the end:

1. In your own words, what is the main W1 lesson?
2. What table clue would you look for first in a new hand?
3. What was the most confusing moment?
4. Which feedback message helped most?
5. Did you feel more confident than before starting?
6. Would you continue to the next session or world?
7. What would you change before recommending this to another beginner?

## 6. QA Metrics and Scoring Rubric

Record per tester:

| Metric | Scale | Pass shape |
| --- | --- | --- |
| comprehension score | 0-3 per family | average at least 2, no family at 0 |
| confusion count | integer | no repeated P1 pattern across families |
| task friction | low / medium / high | no high friction caused by content meaning |
| feedback usefulness | 1-5 | average at least 4 |
| perceived progress | 1-5 | average at least 4 |
| desire to continue | yes / maybe / no | at least 3 of 5 say yes in a five-person batch |
| confidence before/after | 1-5 delta | non-negative average delta, target +1 |
| time-to-understand first task | seconds | no tester blocked beyond 60 seconds without app-control issue |
| issue count | P0/P1/P2/Info | zero P0, no repeated P1 across families |

Comprehension score:

- `3`: tester explains the family in their own words and names the relevant
  table clue.
- `2`: tester understands the basic job after seeing feedback.
- `1`: tester can repeat the answer but cannot explain why.
- `0`: tester cannot explain the task, feedback, or main idea.

Feedback usefulness score:

- `5`: explains the answer clearly and helps future decisions.
- `4`: mostly clear, minor wording friction.
- `3`: understandable but not useful for transfer.
- `2`: confusing or too generic.
- `1`: misleading or not understood.

## 7. Pass/Fail Thresholds

W1 cannot pass Human QA if any of these occur:

- any P0 comprehension blocker appears;
- repeated P1 confusion appears in more than one concept family;
- testers cannot explain the main W1 lesson in their own words;
- testers report that they are guessing instead of learning;
- feedback is not understood;
- the observer must teach poker concepts outside the app for testers to
  continue;
- three or more testers in a five-person batch answer "no" to continuing.

W1 may pass Human QA only if:

- zero P0 issues are observed;
- no unresolved repeated P1 issue remains;
- each concept family averages at least `2` comprehension;
- feedback usefulness averages at least `4`;
- perceived progress averages at least `4`;
- at least 3 of 5 testers would continue;
- all P2 issues have owners or are explicitly deferred as non-blocking.

## 8. Severity Model

P0:

- blocks understanding or teaches the wrong idea;
- prevents the tester from continuing without external explanation;
- makes the tester believe a materially wrong W1 concept.

P1:

- materially confusing or misleading;
- causes guessing instead of learning;
- repeats across testers or across more than one concept family;
- weakens confidence in a core W1 lesson.

P2:

- copy, pacing, wording, or interaction polish issue;
- understandable but less clear than it should be;
- does not block the W1 lesson.

Info:

- observation only;
- preference, isolated hesitation, or non-blocking comment;
- useful for later polish but not a gate blocker.

## 9. W1 9.0 Gate

This protocol makes the Human QA gate ready. It does not pass the gate.

W1 cannot reach 9.0 until:

- live Human QA execution runs with eligible novice testers;
- the batch passes the thresholds in this protocol;
- P0 and repeated P1 issues are repaired or explicitly resolved by evidence;
- payoff/progression certification is completed or separately accepted;
- W1 remains claim-safe: no launch-ready, learning-effect, or public beta
  claims before human evidence exists.

## 10. Deferred Execution Plan

Human QA execution is deferred because no human testers are currently
available.

When testers become available:

1. Select 3-5 eligible novice testers.
2. Run one W1 session per tester using this script.
3. Record raw observations, answers, issue severity, and scores.
4. Consolidate repeated issues by concept family.
5. Create a follow-up artifact:
   `docs/_reviews/w1_human_qa_execution_results_v1.md`.
6. Repair P0/P1 findings before any W1 9.0 claim.
7. If thresholds pass, update W1 Human QA from
   `protocol_ready / execution_deferred` to `executed_passed`.

## 11. Reuse for Volume I

The same protocol shape can later be reused across W2-W12 by changing:

- concept-family list;
- representative route/sample path;
- expected main lesson;
- world-specific vocabulary risks;
- pass/fail notes for bridge-limited or locked worlds.

Reuse rules:

- do not execute W2-W12 QA in this W1 protocol wave;
- do not treat W1 QA pass as Volume I QA pass;
- keep bridge-limited W2-W6 claims separate from canonical W1 claims;
- keep W7-W12 closed/non-routed until later route-admission evidence exists.

## 12. Next Active Non-Human-Blocked Wave

Recommended next active wave:

`W1 Payoff/Progression Certification`

Reason:

- Human QA execution is blocked until testers are available.
- The Human QA protocol is now ready, so the next useful Codex-owned W1 gate
  is payoff/progression certification.
- Payoff/progression proof is an explicit remaining W1 9.0 blocker.
- This next wave can inspect existing W1 completion/progress evidence without
  live testers, content authoring, route changes, UI work, or W2-W12 expansion.

Not selected:

- `W2-W6 Canonical/Bridge Decision`: important, but W1 still has a direct
  non-human 9.0 blocker.
- `W2-W6 Canonical Realignment Plan`: premature before W1's own
  payoff/progression gate is classified.
- `W1 Technical 8.5 Closure`: too vague compared with the named
  payoff/progression blocker.

## 13. Ledger Impact

- W1 stays `8.0`.
- Human QA status becomes `protocol_ready / execution_deferred`.
- Human QA execution remains unrun.
- W1-W12 Volume I Premium Product Readiness remains `6.2`.
- Overall Top-1 Readiness remains `6.0`.
- Learning effect remains `6.0`.
- No W1-W12 score movement is proposed.

## 14. Route Impact

- No route changes.
- No learner-facing title changes.
- W1 remains learner-playable.
- W2-W6 remain bridge-limited.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain deferred/post-launch.

## 15. Evidence DoD Status

Required checks for this protocol wave:

- `graphify hook-check`
- `git diff --check`
- direct ASCII check
- direct trailing-whitespace/CRLF check

No screenshots are required. No Dart tests are required because no tooling,
runtime, content fixture, or product code changed.

## 16. Anti-Theater Check

What risk moved:

- The Human QA gate moved from undefined/deferred to protocol-ready and
  execution-deferred.
- Future novice QA can now run as one efficient W1 batch with concrete
  thresholds and severity rules.

What did not move:

- Human QA did not execute.
- W1 did not reach 9.0.
- W1 did not become launch-ready.
- Learning-effect claims did not move.
- W1-W12 score did not move.
- No route, UI, telemetry, monetization, store, screenshot, or content scope
  changed.

What can proceed without humans:

- `W1 Payoff/Progression Certification` can proceed as the next
  non-human-blocked wave.
