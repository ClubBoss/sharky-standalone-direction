# W6 Range Correctness Posture + Canonical Pilot Plan v1

Status: REVIEW ARTIFACT.
Branch: `codex/w6-range-correctness-posture-canonical-pilot-plan-v1`.
Baseline: `84645028` (`w4_w5_bounded_certification_closure_passed`).
Verdict: `w6_range_correctness_posture_blocked_by_source_gap`.

## 1. Verdict

W6 correctness posture is ready, but the canonical pilot fixture is deferred.

The safe first family remains `range_bucket_by_board_fit` from `w6.s01` only,
but current `w6.s01` source does not provide six safe existing-source tasks
that ask the learner to classify hand/board fit into plain buckets without
action prescription, blocker wording, or under-specified strategy context.

No W6 canonical fixture was created.

Next wave: `W6 Range Bucket Source Repair Plan v1`.

## 2. Accepted context

Accepted technical state:

- W1: technical 8.5 candidate.
- W2: bounded technical 8.0 candidate.
- W3: bounded technical 8.0 candidate.
- W4: bounded technical 8.0 candidate for Bet Purpose / Price two-family
  scope.
- W5: bounded technical 8.0 candidate for Board Awareness two-family scope.
- W6: Range Thinking, bridge-limited, score `5.3`.
- W1-W12 readiness: `7.7`.
- Overall top-1 readiness: `6.5`.

Accepted route/title truth:

- W4: `Bet Purpose / Price`.
- W5: `Board Awareness`.
- W6: `Range Thinking`.
- W7-W10 remain locked.
- W11-W12 remain authored-but-not-routed.
- W13-W36 remain post-launch / long-horizon.

## 3. Learning Outcome Gate scoring-note patch

Added a scoring-rule note to `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`.

The note locks:

- `8.0` means bounded technical certification candidate only.
- `8.5` means technical plus payoff/progression certified only.
- `9.0+` requires World Learning Outcome Guarantee Gate, Human QA, and
  correctness/claim safety.
- `9.5+` / launch-grade requires all 9.0 items plus external novice proof.

The gate itself is not executed in this wave and produces no score movement.

## 4. W6 source truth

Reviewed exact W6 source only:

- `content/worlds/world6/v1/world.md`
- `content/worlds/world6/v1/index.md`
- `content/worlds/world6/v1/sessions/index.md`
- `content/worlds/world6/v1/sessions/w6.s01/session.md`
- `content/worlds/world6/v1/sessions/w6.s01/notes.md`
- `content/worlds/world6/v1/sessions/w6.s01/drills/*`
- `test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`

`w6.s01` source truth:

- Session title: Range Buckets Intro.
- Source objective: sort likely hands into broad range buckets instead of
  treating the spot as one exact hand.
- Source bucket vocabulary: strong, medium, weak, missed.
- Existing source also includes action-choice reps, seat/board anchors, and
  one hole-card tap with blocker wording.

Source gap:

- The source describes bucket classification at the session level, but the
  available six `range_bucket_classifier_v1` drill files give the bucket first
  and ask for an action.
- The clean canonical pilot requested by this wave needs the learner to
  classify bucket/board fit, not infer an action from a pre-given bucket.
- One `w6.s01` drill uses blocker wording and is excluded.
- No six existing-source `w6.s01` tasks can be migrated without either
  changing the learner job or carrying under-specified action advice into a
  canonical claim.

## 5. W6 correctness posture

The first W6 pilot must be bucket/board-fit recognition only.

Allowed posture:

- plain-language range bucket recognition;
- strong, medium, weak, missed bucket vocabulary;
- board-fit or board-texture context only when source explicitly defines it;
- beginner classification, not precise strategy.

Forbidden posture:

- no opponent range construction;
- no blocker reasoning;
- no polarization strategy;
- no solver/GTO language;
- no frequencies, percentages, Nash, equilibrium, or balance language;
- no "always", "never", or "optimal" strategy advice;
- no betting prescription that is correct only under unstated stack, position,
  price, or prior-action context;
- no stack-depth, tournament, ICM, exploit, or track-specialization policy.

W6 Range Thinking is introduced here as plain-language reading and
classification, not solver-grade strategy.

## 6. Canonical pilot family

Planned family:

- `range_bucket_by_board_fit`

Allowed source:

- `w6.s01` Range Buckets Intro only.

Required future learner action:

- Given a hand category and board texture / board-fit context, classify the
  situation into a plain beginner bucket: strong, medium, weak, missed, or
  source-owned equivalent terms.

Current family decision:

- Planned but not created.
- The family remains the correct first W6 canonical target after source repair.

## 7. Explicit exclusions: polarization and blockers

Explicit exclusions:

- `w6.s05` River Polarization is excluded from pilot scope.
- River Polarization may only be treated as concept introduction later.
- Any strategic implication from polarization requires separate expert
  correctness review.
- `w6.s08` Blockers is fully excluded from pilot scope.
- Blocker reasoning must not appear in any W6 pilot task or feedback.
- Future blocker or polarization work requires separate correctness/expert
  review.

## 8. Fixture created or deferred

Deferred.

No file was created at:

- `test/fixtures/content_factory_mvp/w6_range_bucket_by_board_fit_canonical_pilot_v1.json`

Reason:

- Current `w6.s01` source has bucket vocabulary but does not provide six safe
  existing-source bucket/board-fit classification tasks.
- Using the six existing `range_bucket_classifier_v1` drills would turn a
  pre-given bucket into an action recommendation, which violates the
  correctness posture and the wave stop conditions.
- Rewriting those tasks into bucket classifiers would be new content and is
  out of scope.

## 9. Bridge preservation

Existing W6 bridge fixture remains unchanged:

- `source_truth_status`: `bridge_or_legacy`
- `safe_claim_status`: `limited_bridge`
- `launch_coverage_claimed`: `false`

Validation confirms it remains bridge-limited:

```text
content_schema_l2_l3_validator_v1: fixtures=1 worlds=1 tasks=3 coverage_countable=3
content_schema_l2_l3_validator_v1: world_6 tasks=3 coverage_countable=3 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

No canonical W6 pilot exists, so no bridge plus canonical negative-control run
was applicable in this wave.

## 10. Terminal gate protection

W6 terminal gate before W7-W10 is preserved; no W7-W10 scope items were
introduced.

Focused guard passed:

```text
flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart
```

Confirmed:

- W7-W12 world cards remain locked and non-selectable.
- Learner-facing progression does not promote W7-W10 after W6 completion.
- Stale active W7-W10 pack state is not returned to the learner route.

## 11. Validation

Passed:

- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`
- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart`

Final hygiene checks are recorded in section 16.

## 12. Claim safety

Allowed claims:

- W6 has a correctness posture for a future first canonical pilot.
- The safe first target is `range_bucket_by_board_fit` from `w6.s01` only.
- Existing W6 bridge evidence remains reportable but bridge-limited.
- W6 terminal gate before W7-W10 is preserved.

Forbidden claims:

- No W6 canonical fixture exists.
- W6 is not canonical route-ready.
- W6 does not move to 7.0, 8.0, 9.0, launch-ready, or Human-QA-validated.
- No blocker, polarization, solver/GTO, range-construction, stack-depth,
  tournament, ICM, exploit, W7-W12, monetization, telemetry, UI, screenshot,
  or external dependency claim is supported.

## 13. Score / ledger impact

No score movement:

- W6 remains `5.3`.
- W1-W12 readiness remains `7.7`.
- Overall top-1 readiness remains `6.5`.
- Content depth remains `5.9`.
- Progression / dopamine remains `6.5`.
- Learning effect remains `6.0`.
- Monetization readiness remains `2.0`.

Future W6 caps:

- `5.5` max after a single safe pilot family alone.
- `7.0` max after two-family canonical evidence plus range/polarization
  correctness review.
- `8.0` max only after two-family evidence, payoff/progression certification,
  and expert correctness review for polarization/range advantage where
  applicable.
- `9.0` requires World Learning Outcome Guarantee Gate, Human QA, and full
  correctness claim safety.

## 14. Route impact

No runtime route, title, navigation, terminal gate, W7-W12 route, UI, or copy
change was made.

W6 remains Range Thinking and bridge-limited.

## 15. Active repair queue update

Completed current wave:

- `W6 Range Correctness Posture + Canonical Pilot Plan v1`

Recommended next wave:

- `W6 Range Bucket Source Repair Plan v1`

Reason: the correctness posture and safe family are now explicit, but source
must be repaired or authored later before a canonical fixture can be created
honestly.

## 16. Evidence DoD status

Passed:

- W6 bridge foundation validator.
- W6 bridge L2/L3 validator.
- W7-W10 route-lock / terminal-gate guard.
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- direct ASCII / diff-only ASCII
- trailing whitespace / CRLF / final-newline checks

Not applicable:

- W6 canonical L2/L3 validator on canonical fixture.
- W6 bridge plus canonical negative control.
- focused exporter/factory tests.
- `dart format` on touched Dart/test files.
- `flutter analyze`.

Reason: no fixture, Dart, factory, validator, or test file was changed.

No screenshots were taken.

## 17. Anti-theater check

Pass.

This wave does not pretend source vocabulary is enough for canonical coverage.
It records the exact source gap, preserves bridge/canonical separation,
protects the W6 terminal gate, and adds the scoring rule that prevents 8.0 or
8.5 from being misread as learner outcome proof.

## 18. Next wave decision

Selected:

`W6 Range Bucket Source Repair Plan v1`

Required next decision:

- author or repair exactly six `w6.s01` source tasks for
  `range_bucket_by_board_fit`; or
- document that W6 must remain bridge-limited until a later W6 source-authorship
  wave.
