# W2 Payoff/Progression Repair v1

Status: ACCEPTED - technical payoff/progression repair ready for closure.
Created: 2026-06-29.

## 1. Verdict

`w2_payoff_progression_repair_ready`

W2 now has W2-specific technical payoff/progression proof wired through
existing progression and runner chrome contracts. The repair is sufficient to
return to W2 8.0 Certification Closure.

This is not W2 8.0 by itself, not W2 9.0, not launch readiness, not Human QA,
not monetization, and not broad W2 migration.

## 2. Source truth

Inspected docs:

- `AGENTS.md`: active repo boundary, Act0 route truth, graphify, and forbidden
  scope.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W2 launch-facing title is
  `Hand Discipline`.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active next-wave
  pointer and top-1 route ledger.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W2 score, blocker, and
  score-cap rules.
- `docs/_reviews/w2_8_0_certification_review_correctness_payoff_gate_v1.md`:
  accepted baseline and named payoff/progression blocker.
- `docs/_reviews/w2_canonical_coverage_expansion_pr3_source_truth_decision_v1.md`:
  third W2 canonical family and approved-raise boundaries.
- `docs/_reviews/w2_canonical_coverage_expansion_pr2_v1.md`: facing-price
  continue/release discipline family.
- `docs/_reviews/w2_canonical_certification_pilot_v1.md`: first W2 canonical
  hand-discipline family.
- `docs/_reviews/w1_payoff_progression_certification_v1.md`: W1 technical
  payoff/progression benchmark.

Inspected code/tests:

- `lib/canonical/progression_route_story_v1.dart`
- `lib/canonical/progression_handoff_context_v1.dart`
- `lib/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart`
- `lib/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart`
- `test/canonical/progression_route_story_v1_test.dart`
- `test/canonical/progression_handoff_context_v1_test.dart`
- `test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
- `test/ui_v2/act0_profile_evidence_consumer_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`

Inspected fixtures:

- `test/fixtures/content_factory_mvp/w2_canonical_certification_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w2_facing_price_discipline_canonical_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w2_approved_raise_discipline_canonical_pr3_v1.json`

Advisory navigation:

- `graphify query "W2 payoff progression repair session completion Hand Discipline progression_route_story"`

## 3. W2 payoff/progression blocker recap

The accepted W2 8.0 Certification Review found no P0/P1/P2 fixture-level poker
correctness issues across the three canonical W2 families, but blocked a clean
bounded 8.0 because W2 completion/progression proof was still generic. W2 had
campaign progression posture, yet it did not clearly tell the learner what Hand
Discipline skill was trained or why the next W2 step continued that skill.

## 4. Current W2 payoff/progression state

Before repair:

- W2 runner completion copy began with generic table-reading language.
- W2 handoff status said `World 2 table reads`.
- W2 route reason asked the learner to read visible table truth before choosing.
- W2 had next-session progression, but not W2-specific Hand Discipline payoff.

After repair:

- W2 completion copy states that World 2 trained fold, call, and raise
  discipline from position, price, and approved pressure cues.
- W2 handoff status says `World 2 Hand Discipline`.
- W2 handoff headline says the stage shift builds Hand Discipline from
  position, price, and approved pressure cues.
- W2 route reason connects World 1 foundations to fold/call/raise discipline in
  World 2.
- The runner still emits the next W2 session label and does not open W3-W12.

## 5. Repair decision

Changed:

- `lib/canonical/progression_route_story_v1.dart`
  - W2 stage-shift headline value.
  - W2 status line.
  - W2 reason line.
  - W2 completion body lead.
- Focused tests for W2 runner completion copy, route story, and handoff context.
- SSOT ledgers and active next-wave pointer.

Why this is minimal:

- The repair uses the existing canonical progression story contract already
  consumed by the runner chrome and handoff context.
- No new UI surface, route family, telemetry event, profile system, content
  fixture, or authoring pipeline was added.
- The learner-facing route title remains `Hand Discipline`.

Intentionally not changed:

- No W3-W6 migration.
- No W7-W12 admission.
- No screenshots or Human QA execution.
- No telemetry expansion.
- No monetization or launch copy.
- No broad W2 content authoring.

## 6. Certification matrix after repair

| Dimension | Evidence | Pass / Conditional / Fail | Risk | Required action |
| --- | --- | --- | --- | --- |
| completion clarity | Runner chrome now emits W2-specific completion gain copy for `w2.s01`. | Pass | Copy is technical, not human-validated. | Recheck in certification closure. |
| skill proof | Copy names fold/call/raise discipline from position, price, and approved pressure cues. | Pass | It proves the three canonical families, not broad W2 migration. | Keep claims tied to canonical families. |
| error/repair closure | Canonical fixtures still carry three repair focuses and no new repair system was invented. | Conditional | Runtime mistake-to-repair closure was not expanded in this wave. | Leave durable repair proof for later gates. |
| progression signal | Runner keeps the next W2 session label and handoff context explains the W2 stage shift. | Pass | Meso/macro progression remains thin. | Run W2 8.0 Certification Closure next. |
| premium value signal | Completion copy now communicates an earned learning gain without badges or fake mastery. | Pass | Premium feel is copy-level only. | No monetization claim. |
| claim safety | Tests forbid `8.0`, `9.0`, launch, GTO, and solver claims in W2 completion copy. | Pass | Public/store copy not reviewed. | Keep launch claims blocked. |
| W1 non-regression | W1 runner and session-result payoff tests remain in the focused validation set. | Pass | W1 Human QA remains unexecuted. | Preserve W1 payoff proof. |
| technical compatibility | Existing progression story, handoff, and runner chrome contracts carry the repair. | Pass | No architecture expansion was added. | Certification closure can decide score movement to 8.0. |

## 7. Tests / validation

Code/config changed, so focused tests were required.

Focused tests:

- `flutter test test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart test/canonical/progression_route_story_v1_test.dart test/canonical/progression_handoff_context_v1_test.dart`
  - Proves W2 completion payoff copy, safe progression, route story, and handoff
    wording.
- `flutter test test/ui_v2/act0_profile_evidence_consumer_v1_test.dart test/ui_v2/act0_telemetry_sink_v1_test.dart`
  - Proves current W1 profile evidence and completion telemetry proof behavior
    was not regressed.

Stale W1 tests with archived-surface imports were not used as acceptance
evidence because they currently fail to compile against the active repo state
independently of this W2 repair.

Required validation:

- `dart format --set-exit-if-changed` on touched Dart/test files.
- `flutter analyze`.
- `graphify hook-check`.
- `git diff --check`.
- `git diff --cached --check`.
- Direct ASCII, trailing-whitespace, CRLF, and final-newline checks.

No screenshots were taken.

## 8. W2 8.0 implication

W2 can now return to `W2 8.0 Certification Closure`.

This repair closes the named technical payoff/progression blocker, but W2 does
not automatically become 8.0 in this wave. The closure wave must decide whether
the combined W2 evidence now earns clean bounded 8.0.

## 9. W2 9.0 blockers

W2 cannot reach 9.0 until all of these are closed:

- live novice Human QA execution;
- broader correctness/learning validation;
- no unresolved P0/P1 findings;
- durable learning/progression proof;
- launch claim safety.

## 10. Ledger impact

Recommended conservative movement:

- W2: `6.0 -> 7.2`.
- W1-W12 Volume I Premium Product Readiness: `6.6 -> 6.7`.
- Progression / dopamine: `6.2 -> 6.3`.
- Overall top-1 readiness: unchanged at `6.2`.
- Learning effect: unchanged at `6.0`.
- Content depth: unchanged at `5.4`.
- Monetization readiness: unchanged at `2.0`.

Reason: the wave closes a named technical W2 payoff/progression blocker using
existing contracts and tests. It does not perform certification closure, Human
QA, broad W2 migration, public launch review, or monetization work.

## 11. Route impact

- No route changes.
- No learner-facing title changes.
- W2 remains `Hand Discipline`.
- W3-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed.
- W13-W36 remain post-launch/deferred.

## 12. Active repair queue update

Closed:

- W2 payoff/progression technical repair.

Active:

- W2 8.0 Certification Closure.

Must-not-skip:

- W2 certification closure before any 8.0 claim.
- Human QA before 9.0, launch, or external learning-effect claims.
- W3-W6 route/content blockers before scaling beyond W2.

Deferred:

- W2 broad migration.
- W3-W6 canonicalization.
- W7-W12 admission.
- W13-W36 production.
- Monetization.
- Store/public beta.

Blockers:

- Human novice QA execution unavailable.
- Durable cross-session learning/progression proof remains incomplete.
- Broad W2 migration remains incomplete.

## 13. Next implementation decision

`W2 8.0 Certification Closure`

The payoff/progression blocker is cleared enough for certification closure. Do
not scale to W3 until W2 8.0 closure either passes or records the exact
remaining blocker.

## 14. Evidence DoD status

Passed checks for this wave:

- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- direct ASCII check
- direct trailing-whitespace/CRLF/final-newline checks
- `dart format --set-exit-if-changed` on touched Dart/test files
- focused Flutter tests
- `flutter analyze`

Direct ASCII scope: the new review artifact and added diff lines are ASCII.
Legacy middle-dot session separators outside this repair remain in existing
tests/source and were not broadened in this wave.

No screenshots were required or taken.

## 15. Anti-theater check

What risk moved?

- W2 no longer has generic-only technical completion/progression copy. The
  existing W2 runner and handoff contracts now show a specific Hand Discipline
  payoff and next-step signal.

What did not move?

- Human QA, launch readiness, monetization, broad W2 migration, W3-W6
  migration, W7-W12 admission, W13-W36, and durable learning proof did not move.

Did this clear W2 payoff/progression?

- Yes, for the bounded technical repair gate.

Did W2 reach 8.0?

- No. The next wave must run W2 8.0 Certification Closure.

Was Human QA executed?

- No.

Did this claim launch readiness?

- No.

Is next step closure or more repair?

- Closure: `W2 8.0 Certification Closure`.
