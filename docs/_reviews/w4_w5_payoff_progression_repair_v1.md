# W4-W5 Payoff/Progression Repair v1

Status: REVIEW ARTIFACT.
Branch: `codex/w4-w5-payoff-progression-repair-v1`.
Baseline: `999c98dd` (`w4_w5_certification_payoff_gate_passed_needs_payoff_repair`).
Verdict: `w4_w5_payoff_progression_repair_ready_recommends_closure`.

## 1. Verdict

W4 and W5 now have W1/W2/W3-style technical completion payoff and next-step
progression proof through the existing progression story, handoff context, and
runner chrome contracts.

This repair is sufficient to route W4/W5 to bounded certification closure. It
is not itself W4/W5 8.0, not 9.0, not launch readiness, not Human QA, not
monetization, and not broad W4/W5 or W6 canonical coverage.

Next wave: `W4-W5 Bounded Certification Closure v1`.

## 2. Source Truth

Authority reviewed:

- `AGENTS.md`.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`.
- `docs/_reviews/w4_w5_certification_payoff_gate_v1.md`.
- `docs/_reviews/w4_w5_canonical_coverage_expansion_pr2_v1.md`.
- `docs/_reviews/w4_w5_canonical_pilot_batch_v1.md`.
- W2/W3 payoff/progression repair artifacts as pattern references.
- Focused progression and runner chrome contracts/tests.

Accepted route/title truth remains:

- W4: `Bet Purpose / Price`.
- W5: `Board Awareness`.
- W6: `Range Thinking`, still bridge-limited and not canonicalized here.

## 3. Accepted Gate Findings

The accepted gate established:

- W4/W5 canonical-only sets are bounded route-ready.
- W4/W5 bridge plus canonical evidence remains bridge-limited.
- W4 correctness has no P0/P1/P2 finding.
- W5 correctness has no P0/P1/P2 finding.
- Bounded two-family technical claims are safe.
- No 8.0, 9.0, launch, Human QA, solver/GTO, monetization, or broad-world
  claim is supported.
- The remaining blocker was missing W4/W5-specific payoff/progression proof.

## 4. W4 Payoff/Progression Repair

Changed:

- `lib/canonical/progression_route_story_v1.dart`
  - Added W4 completion payoff lead copy for Bet Purpose / Price.
  - Added W4-to-W5 stage-shift and reason copy through the W5 route target.
- `lib/canonical/progression_handoff_context_v1.dart`
  - Allows any route target with a specific stage-shift headline to carry
    continuation headline/reason copy.
- Focused tests cover W4 completion and W4-to-W5 handoff.

W4 completion payoff now states that World 4 trained Bet Purpose / Price by
connecting why a bet is made, price, and action before the click. This is
bounded to the accepted W4 families:

- `price_given_before_action`
- `intent_action_discipline`

It does not claim broad sizing mastery, solver/GTO correctness, Human QA,
launch readiness, or 8.0 closure.

## 5. W5 Payoff/Progression Repair

Changed:

- `lib/canonical/progression_route_story_v1.dart`
  - Added W5 completion payoff lead copy for Board Awareness.
  - Added W5-to-W6 stage-shift and reason copy through the W6 route target.
- Focused tests cover W5 completion and W5-to-W6 handoff.

W5 completion payoff now states that World 5 trained Board Awareness by reading
dry, wet, paired, connected, and shifting boards before action. This is bounded
to the accepted W5 families:

- `board_texture_classification`
- `board_shift_awareness`

It does not claim broad board mastery, W6 canonical status, solver/GTO
correctness, Human QA, launch readiness, or 8.0 closure.

## 6. Handoff / Next-Step Proof

W4 handoff:

- `world5_spine_campaign_v1` now emits:
  - `Stage shift - World 4 Bet Purpose / Price -> World 5 Board Awareness`
  - a Board Awareness headline and reason line.

W5 handoff:

- `world6_spine_campaign_v1` now emits:
  - `Stage shift - World 5 Board Awareness -> World 6 Range Thinking`
  - a Range Thinking headline and reason line.

Route guard:

- `test/guards/w7_w10_route_status_alignment_contract_test.dart` still passes.
- W7-W10 remain locked/non-selectable.
- W6 remains the next learner route truth, but this wave does not canonicalize
  W6 or change W6 bridge-limited status.

## 7. Tests / Validation

Red phase observed:

- Focused progression tests failed before implementation because W4/W5
  completion copy and W5/W6 handoff copy were still generic.

Focused passing tests:

- `flutter test test/canonical/progression_route_story_v1_test.dart test/canonical/progression_handoff_context_v1_test.dart test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart`

Static and content validation:

- `dart format lib/canonical/progression_route_story_v1.dart lib/canonical/progression_handoff_context_v1.dart test/canonical/progression_route_story_v1_test.dart test/canonical/progression_handoff_context_v1_test.dart test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `flutter analyze`

## 8. Closure-Readiness Check

W4/W5 are ready for bounded certification closure review because:

- canonical-only coverage remains two-family bounded and route-ready;
- bridge plus canonical negative control remains bridge-limited;
- correctness gate remains no P0/P1/P2;
- claim safety remains bounded;
- payoff/progression is now technically passed;
- route/title truth remains W4 Bet Purpose / Price and W5 Board Awareness;
- W6 is referenced only as the next Range Thinking route and remains
  bridge-limited.

The closure wave must still decide whether the combined evidence earns bounded
technical 8.0. This repair does not make that claim.

## 9. Claim Safety

Allowed claims:

- W4 has technical Bet Purpose / Price payoff/progression proof for its
  two-family bounded scope.
- W5 has technical Board Awareness payoff/progression proof for its two-family
  bounded scope.
- W4-to-W5 handoff points to Board Awareness.
- W5-to-W6 handoff points to Range Thinking without changing W6 route status.

Forbidden claims:

- W4/W5 are not 8.0 in this wave.
- W4/W5 are not 9.0.
- W4/W5 are not launch-ready.
- W4/W5 are not Human-QA-validated.
- W4/W5 are not broad world mastery.
- W6 is not canonicalized.
- No bridge evidence is counted as canonical.
- No solver, GTO, monetization, public beta, or launch claim is supported.

## 10. Score / Ledger Impact

Conservative movement:

- W4: `6.3 -> 7.2`.
- W5: `6.3 -> 7.2`.
- W1-W12 readiness: `7.5 -> 7.6`.
- Progression / dopamine: `6.4 -> 6.5`.

No movement:

- Content depth remains `5.9`.
- Overall top-1 readiness remains `6.4`.
- Learning effect remains `6.0`.
- Monetization readiness remains `2.0`.
- Human QA and launch readiness remain unchanged.

Reason: the wave closes the named technical W4/W5 payoff/progression blocker
using existing contracts and focused tests. It does not perform bounded
certification closure, Human QA, broad migration, launch review, learning
transfer measurement, or monetization work.

## 11. Route Impact

No runtime route, title, navigation, monetization route, launch surface, or W6
route admission changed.

W4 remains `Bet Purpose / Price`.
W5 remains `Board Awareness`.
W6 remains `Range Thinking` and bridge-limited.
W7-W10 remain locked.
W11-W12 remain authored but not routed.

## 12. Active Repair Queue Update

Completed current wave:

- `W4-W5 Payoff/Progression Repair v1`

Recommended next wave:

- `W4-W5 Bounded Certification Closure v1`

Reason: W4/W5 now have source/schema/correctness/claim-safety and
payoff/progression proof for the bounded two-family scope. The next honest gate
is closure, not W4-only repair, W5-only repair, W4-W5 Coverage PR3, or W6
canonicalization.

## 13. Evidence DoD Status

Passed:

- `dart format` on touched Dart/test files.
- focused W4/W5 payoff/progression tests.
- W7-W10 route-lock guard.
- W4/W5 foundation validator.
- W4/W5 canonical L2/L3 validator.
- W4/W5 bridge plus canonical negative control.
- `flutter analyze`.
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- direct ASCII / diff-only ASCII
- trailing whitespace / CRLF / final-newline checks

No screenshots were taken.

## 14. Anti-Theater Check

This is not theater because the repair changes the exact generic progression
surfaces named by the accepted gate, proves those changes with failing-then-
passing focused tests, preserves bridge negative controls, and keeps 8.0
closure separate.

This remains bounded because it creates no fixtures, does not touch W6 source,
does not open W7-W12, does not redesign progression, and does not make launch,
9.0, Human QA, solver/GTO, monetization, or broad-world claims.

## 15. Next Wave Decision

`W4-W5 Bounded Certification Closure v1`
