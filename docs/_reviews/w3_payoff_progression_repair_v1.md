# W3 Payoff/Progression Repair v1

Status: ACCEPTED - technical payoff/progression repair ready for closure.
Created: 2026-06-29.

## 1. Verdict

`w3_payoff_progression_repair_ready`

W3 now has W3-specific technical payoff/progression proof wired through the
existing progression story, handoff context, and runner chrome contracts. The
repair is sufficient to return to W3 Bounded 8.0 Certification Closure.

This is not W3 8.0 by itself, not W3 9.0, not launch readiness, not Human QA,
not monetization, and not broad W3 migration.

## 2. Source truth

Inspected docs:

- `AGENTS.md`: active repo boundary, Act0 route truth, graphify, and forbidden
  scope.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W3 launch-facing title is
  `Position Thinking`.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active next-wave
  pointer and top-1 route ledger.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W3 score, blocker, and
  score-cap rules.
- `docs/_reviews/w3_8_0_certification_review_two_family_bounded_scope_v1.md`:
  accepted baseline and named payoff/progression blocker.
- `docs/_reviews/w3_source_ownership_remap_v1.md`: two-family bounded W3 source
  ownership scope.
- `docs/_reviews/w2_payoff_progression_repair_v1.md`: nearest repair pattern.
- `docs/_reviews/w2_8_0_certification_closure_v1.md`: bounded closure
  precedent after payoff/progression repair.
- `docs/_reviews/w1_payoff_progression_certification_v1.md`: technical
  payoff/progression benchmark.

Inspected code/tests:

- `lib/canonical/progression_route_story_v1.dart`
- `lib/canonical/progression_handoff_context_v1.dart`
- `lib/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart`
- `test/canonical/progression_route_story_v1_test.dart`
- `test/canonical/progression_handoff_context_v1_test.dart`
- `test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`

Inspected fixtures:

- `test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`

## 3. W3 payoff/progression blocker recap

The accepted W3 8.0 Certification Review found no P0/P1/P2 fixture-level poker
correctness issues across the two canonical-owned W3 families, but blocked a
clean bounded 8.0 because W3 completion/progression proof was still generic.
W3 had campaign/session progression, yet it did not clearly tell the learner
what Position Thinking skill was trained or why the next W3 step continues
that skill.

## 4. Current W3 payoff/progression state

Before repair:

- W3 runner completion copy said World 3 kept the same first-action framework in
  view.
- W3 handoff status said `World 3 preflop framework`.
- W3 route reason described a generic simple open / call / fold framework.
- W3 had next-session progression, but not W3-specific Position Thinking
  payoff.

After repair:

- W3 completion copy states that World 3 trained Position Thinking through
  position-first choices and hand-bucket action frames.
- W3 handoff status says `World 3 Position Thinking`.
- W3 handoff headline says the stage shift builds Position Thinking from seat,
  hand bucket, and action-frame cues.
- W3 route reason connects World 2 table truth to Position Thinking through
  position-first choices plus hand-bucket action frames.
- W3 review cadence copy names the next World 3 Position Thinking session.
- The runner still emits the next W3 session label and does not open W4-W12.

## 5. Repair decision

Changed:

- `lib/canonical/progression_route_story_v1.dart`
  - W3 stage-shift headline value.
  - W3 status line.
  - W3 reason line.
  - W3 completion body lead.
  - W3 review cadence line.
- Focused tests for W3 runner completion copy, route story, and handoff
  context.
- SSOT ledgers and active next-wave pointer.

Why this is minimal:

- The repair uses the existing canonical progression story contract already
  consumed by runner chrome and handoff context.
- No new UI surface, route family, telemetry event, profile system, content
  fixture, or authoring pipeline was added.
- The learner-facing route title remains `Position Thinking`.

Intentionally not changed:

- No W3 PR4 or third-family fixture.
- No W4-W6 migration.
- No W7-W12 admission.
- No screenshots or Human QA execution.
- No telemetry expansion.
- No monetization or launch copy.
- No broad W3 content authoring.

## 6. Certification matrix after repair

| Dimension | Evidence | Pass / Conditional / Fail | Risk | Required action |
| --- | --- | --- | --- | --- |
| completion clarity | Runner chrome now emits W3-specific completion gain copy for `w3.s01`. | Pass | Copy is technical, not human-validated. | Recheck in certification closure. |
| skill proof | Copy names Position Thinking through position-first choices and hand-bucket action frames. | Pass | It proves the two bounded canonical families, not broad W3 migration. | Keep claims tied to the bounded two-family scope. |
| error/repair closure | Canonical fixtures still carry two repair focuses and no new repair system was invented. | Conditional | Runtime mistake-to-repair closure was not expanded in this wave. | Leave durable repair proof for later gates. |
| progression signal | Runner keeps the next W3 session label and handoff context explains the W3 stage shift. | Pass | Meso/macro progression remains thin. | Run W3 Bounded 8.0 Certification Closure next. |
| premium value signal | Completion copy now communicates an earned learning gain without badges or fake mastery. | Pass | Premium feel is copy-level only. | No monetization claim. |
| claim safety | Tests forbid `8.0`, `9.0`, launch, GTO, solver, and Human QA claims in W3 payoff surfaces. | Pass | Public/store copy not reviewed. | Keep launch claims blocked. |
| W1/W2 non-regression | Existing W2 route-story/handoff/chrome tests remain in the focused validation set. | Pass | W1 Human QA remains unexecuted. | Preserve W1/W2 proof boundaries. |
| technical compatibility | Existing progression story, handoff, and runner chrome contracts carry the repair. | Pass | No architecture expansion was added. | Certification closure can decide score movement to 8.0. |

## 7. Tests / validation

Code/config changed, so focused tests were required.

Red phase:

- `flutter test test/canonical/progression_route_story_v1_test.dart test/canonical/progression_handoff_context_v1_test.dart test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
  - Failed before repair on generic W3 stage, handoff, and completion copy.

Focused tests after repair:

- `flutter test test/canonical/progression_route_story_v1_test.dart test/canonical/progression_handoff_context_v1_test.dart test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
  - Proves W3 completion payoff copy, safe progression, route story, and
    handoff wording.

Required validation:

- `dart format --set-exit-if-changed` on touched Dart/test files.
- `flutter analyze`.
- `graphify hook-check`.
- `git diff --check`.
- `git diff --cached --check`.
- Direct ASCII, trailing-whitespace, CRLF, and final-newline checks.

No screenshots were taken.

## 8. W3 bounded 8.0 implication

W3 can now return to `W3 Bounded 8.0 Certification Closure`.

This repair closes the named technical payoff/progression blocker, but W3 does
not automatically become 8.0 in this wave. The closure wave must decide whether
the combined two-family W3 evidence now earns clean bounded 8.0.

## 9. W3 9.0 blockers

W3 cannot reach 9.0 until all of these are closed:

- live novice Human QA execution;
- broader correctness/learning validation;
- no unresolved P0/P1 findings;
- durable learning/progression proof;
- broad W3 migration or explicitly bounded launch-safe claim scope;
- launch claim safety.

## 10. Ledger impact

Recommended conservative movement:

- W3: `6.0 -> 7.0`.
- W1-W12 Volume I Premium Product Readiness: `7.0 -> 7.1`.
- Progression / dopamine: `6.3 -> 6.4`.
- Overall top-1 readiness: unchanged at `6.3`.
- Learning effect: unchanged at `6.0`.
- Content depth: unchanged at `5.6`.
- Monetization readiness: unchanged at `2.0`.

Reason: the wave closes a named technical W3 payoff/progression blocker using
existing contracts and tests. It does not perform certification closure, Human
QA, broad W3 migration, public launch review, or monetization work.

## 11. Route impact

- No route changes.
- No learner-facing title changes.
- W3 remains `Position Thinking`.
- W3 remains a two-family bounded scope until closure decides 8.0.
- W4-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed.
- W13-W36 remain post-launch/deferred.

## 12. Active repair queue update

Closed:

- W3 payoff/progression technical repair.

Active:

- W3 Bounded 8.0 Certification Closure.

Must-not-skip:

- W3 certification closure before any clean 8.0 claim.
- Human QA before 9.0, launch, or external learning-effect claims.
- W3 broad migration or bounded-scope wording before broad W3 claims.

## 13. Next implementation decision

Run `W3 Bounded 8.0 Certification Closure`.

The closure should use:

- W3 two-family certification review evidence;
- W3 payoff/progression repair evidence;
- W3 bridge/canonical negative-control evidence;
- focused validation outputs from this repair.

Do not open W4, W7-W12, monetization, telemetry expansion, or Human QA inside
that closure unless a future prompt explicitly changes scope.

## 14. Evidence DoD status

Met:

- W3-specific payoff copy exists in the canonical progression story.
- W3 next-step handoff copy exists through the existing handoff context.
- W3 session completion payoff copy exists through runner chrome.
- Focused tests prove W3 copy and W2 non-regression in the touched seams.
- Ledger and long-horizon route point to the closure gate.

Not met:

- No Human QA.
- No durable cross-session learning proof.
- No broad W3 migration.
- No public launch/store/monetization proof.
- No W3 8.0 closure verdict yet.

## 15. Anti-theater check

This repair does not claim more than it proves.

It proves a technical payoff/progression copy and handoff repair through
existing contracts. It does not claim broad W3 coverage, W3 9.0, launch
readiness, paid value, human validation, solver-level correctness, or durable
learning transfer.
