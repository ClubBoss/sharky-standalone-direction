# W1 Payoff/Progression Certification v1

Status: ACCEPTED - technical certification passed.
Date: 2026-06-28.
Branch: `codex/w1-payoff-progression-certification-v1`.
Baseline: `3cdda8d8` (`docs: define w1 human qa protocol`).

## 1. Identity

This artifact evaluates whether W1 produces a clear end-of-world learning payoff
and a credible progression signal after the accepted W1 8.0 certification,
poker-correctness, bet-size vocabulary repair, and Human QA Protocol waves.

Verdict:

`w1_payoff_progression_certified_technical_pass`

Meaning:

- W1 has enough runtime-backed payoff/progression proof to clear the
  non-human-blocked W1 payoff gate.
- W1 remains below launch-ready status because live novice Human QA has not
  executed and full W1 schema-owned migration remains incomplete.
- This is not a 9.0 claim, external beta claim, public learning-effect claim,
  monetization claim, or W1-W12 launch claim.

## 2. Evidence Sources Reviewed

- `lib/ui_v2/screens/session_result_screen.dart`
- `lib/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart`
- `lib/ui_v2/runner/runner_completion_surface_contract_v1.dart`
- `lib/canonical/learner_journey_finish_framing_v1.dart`
- `lib/canonical/progression_route_story_v1.dart`
- `test/ui_v2/session_result_world1_onboarding_payoff_test.dart`
- `test/guards/world1_result_whats_next_block_contract_test.dart`
- `test/ui_v2/act0_profile_evidence_consumer_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `docs/_reviews/w1_8_0_certification_review_v1.md`
- `docs/_reviews/w1_poker_correctness_review_protocol_v1.md`
- `docs/_reviews/w1_bet_size_vocabulary_correctness_repair_v1.md`
- `docs/_reviews/w1_human_qa_protocol_v1.md`
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

## 3. Payoff/Progression Matrix

| Question | Evidence | Result |
| --- | --- | --- |
| Does the result screen say what the learner gained? | W1 early-entry payoff copy says the learner can identify Button, small blind, and big blind without guessing; later early packs name fold/call/raise and street-flow gains. | Pass |
| Does the result screen show the next learning step? | `session_result_world1_onboarding_payoff_test.dart` asserts "Next up: First action choices", "Next lesson ready: World 1 - Pack 2 of 7 - First action choices.", and the `NEXT LESSON` CTA. | Pass |
| Does the next step explain why it matters at a table? | The same test asserts real-table value copy that connects seat/blind clarity to reasoned first preflop action. | Pass |
| Is progression tied to canonical route structure? | `world1_foundations_runner_progression_chrome_adapter_v1.dart` resolves pack order through canonical truth nodes and emits world/pack/step chrome plus next-session labels. | Pass |
| Does the result surface avoid generic completion theater? | It includes a "What's next" block, continuation line, why line, specific CTA, and narrow visual anchor rather than only XP/accuracy. | Pass |
| Is there proof beyond the result screen? | Profile evidence projection/consumer tests assert one read-only evidence signal with counted proof such as `3/5 correct in Action reading`. | Pass, bounded |
| Is copy claim-safe? | Profile evidence tests forbid mastery, badge, AI, GTO, solver, strongest/weakest, premium, and achievement overclaim copy in the evidence block. | Pass |
| Is there auditable completion telemetry? | Act0 telemetry tests assert `world_complete` with `world_id = world_1` and `source_surface = act0_completion`. | Pass |
| Is the payoff human-validated? | Human QA Protocol is ready but execution is deferred. | Blocked outside this wave |
| Is durable concept-family proof accumulation complete? | Profile can show a current evidence signal, but durable cross-session concept-family accumulation remains a later contract. | Partial |

## 4. Findings

P0: None.

P1: None for this gate.

P2: Durable progression proof remains limited. The app can show a safe local
evidence signal and completion telemetry, but it still does not prove durable
cross-session concept-family accumulation, transfer improvement, or novice
understanding.

P2: W1 payoff is technically credible but not human validated. Live novice QA
must still decide whether new users understand the payoff, the next step, and
the reason they should continue.

## 5. Certification Decision

W1 payoff/progression is technically certified as a bounded pass.

The gate closes because W1 now has:

- specific learner-gain copy at completion;
- specific next-capability copy;
- route-aware next lesson labels;
- table-value explanation;
- a visible continuation block and next CTA;
- profile-side read-only proof language;
- completion telemetry;
- tests guarding the main result, profile, copy-safety, telemetry, and narrow
  width result surface contracts.

No code/config/copy repair is required in this wave.

## 6. Repairs

None.

The reviewed implementation already carries the narrow proof required by this
gate. Adding more UI in this wave would risk broadening scope into dashboard,
badge, mastery, or durable progression work that the current route has not
admitted.

## 7. W1 9.0 Implication

This certification permits W1 to move from `8.0` to a technical `8.5`
candidate.

It does not permit W1 to reach `9.0`.

Remaining 9.0 blockers:

- live novice Human QA execution;
- full W1 schema-owned migration beyond the six certified concept families;
- durable progression/profile proof beyond a current local evidence signal;
- no external beta, launch, monetization, or learning-effect claim before the
  Human QA gate passes.

## 8. Score Delta Proposal

Recommended control-plane movement:

- W1 technical readiness: `8.0 -> 8.5`.
- W1-W12 Volume I Premium Product Readiness: `6.2 -> 6.3`.
- Overall Top-1 Readiness: `6.0 -> 6.1`.
- Progression / dopamine: `6.0 -> 6.2`.

Reason:

This wave closes a named W1 certification gate using existing runtime and test
evidence. The movement is larger than a pure docs-only classification because
the proof already exists in product surfaces and tests, but it remains capped
below 9.0 because no live novice QA or durable concept-family accumulation was
added.

## 9. Route Impact

The active W1 non-human-blocked gate moves from:

`W1 Payoff/Progression Certification`

to:

`W2-W6 Canonical/Bridge Decision`

Rationale:

- W1 correctness and payoff/progression are no longer the highest non-human
  blocker.
- W1 Human QA remains blocked by unavailable testers.
- W2-W6 remain bridge-limited, title/content-offset, and claim-limited.
- Resolving whether W2-W6 stay bridge support or become canonical launch
  worlds is now the highest control-plane risk before broader authoring,
  W7-W12 admission, or monetization.

## 10. Validation Scope

This is a docs-only certification wave.

No Dart product code, config, copy, assets, fixtures, or tests were modified.
Therefore no Dart formatting, Flutter test, Flutter analyze, screenshot, or
runtime capture is required by this prompt.

Required validation remains:

- `graphify hook-check`
- `git diff --check`
- direct ASCII check on edited docs
- direct trailing-whitespace and CRLF check on edited docs

## 11. Forbidden Scope Proof

This wave did not:

- create a badge, achievement art, level, rating, radar, score, or fake mastery
  system;
- add a broad dashboard;
- add monetization, paywall, price, trial, restore, or purchase behavior;
- open W7-W12;
- create or migrate new content;
- alter poker logic;
- alter telemetry schemas;
- change Act0 routing;
- capture screenshots or generated evidence media.

## 12. Anti-Theater Check

The certification is intentionally narrow.

Accepted:

- a learner can see what they gained;
- a learner can see the next lesson;
- a learner can see why the next lesson matters;
- profile can show one safe local evidence signal;
- telemetry can record world completion.

Not accepted:

- the learner has human-validated understanding;
- W1 is launch-ready;
- W1 has durable proof accumulation;
- W1-W12 is a complete premium product;
- public learning-effect or commercial claims are safe.

## 13. Next-Step Decision

Recommended next wave:

`W2-W6 Canonical/Bridge Decision`

The next wave should decide, using route truth and current schema evidence,
whether W2-W6 remain explicit bridge support or require canonical title/content
realignment before more migration and authoring. It should not reopen W1
payoff/progression unless live Human QA finds a concrete comprehension failure.
