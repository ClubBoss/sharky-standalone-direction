# W2 Canonical Certification Pilot v1

Status: ACCEPTED.
Created: 2026-06-28.
Verdict: `w2_canonical_certification_pilot_ready`.

## 1. Identity

This artifact certifies one narrow W2 canonical pilot slice for the existing
Hand Discipline route.

It does not certify all W2 content, W2 8.0, W2 9.0, W3-W6, or launch
readiness.

## 2. Files Changed

- `tools/content_factory_import_export_mvp_v1.dart`
- `test/tools/content_factory_import_export_mvp_v1_test.dart`
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`
- `test/fixtures/content_factory_mvp/w2_canonical_certification_pilot_v1.json`
- `docs/_reviews/w2_canonical_certification_pilot_v1.md`
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

## 3. Artifact Digest

The pilot exports six existing W2 source tasks into one schema-backed fixture:

- fixture: `w2_canonical_certification_pilot_v1`
- world: `world_2`
- route title: `Hand Discipline`
- concept family: `hand_discipline_position_price_defaults`
- same-signal group: `w2.hand_discipline.position_price_action_defaults`
- repair focus: `position_price_hand_discipline`
- source truth: `migrated`
- safe claim status: `canonical_pilot`
- launch coverage claimed: `false`

Source tasks:

- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_fold_early.json`
- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_call_vs_open.json`
- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_raise_btn.json`
- `content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_fold_utg_open.json`
- `content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_call_btn_defend.json`
- `content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_raise_btn_open.json`

## 4. W2 Canonicalization Decision

W2 can safely produce one canonical certification pilot now.

The selected source group is route-aligned because the six tasks ask for
disciplined fold/call/raise defaults across position and facing-price
situations. That is closer to Hand Discipline than the older broad
table-reading bridge fixture.

This decision does not reclassify the existing W2 bridge fixture. Bridge and
canonical evidence must remain separated.

## 5. Fixture/Test Summary

The factory now exposes `exportW2CanonicalCertificationPilotV1`.

The focused factory test verifies deterministic export, six unique W2 tasks,
preserved source paths, route/title ownership, canonical-pilot claim status,
launch-claim blocking, transfer surfaces, same-signal group, repair focus, and
the expected fold/call/raise sequence.

## 6. L2/L3 Result

Canonical pilot alone:

- fixtures: 1
- worlds: 1
- tasks: 6
- coverage countable tasks: 6
- `coverage_ready`: true
- `transfer_ready`: true
- `repair_ready`: true
- route admission: `learner_playable_route_ready`

W2 bridge plus canonical pilot together:

- fixtures: 2
- worlds: 1
- tasks: 9
- coverage countable tasks: 9
- `coverage_ready`: false
- `transfer_ready`: true
- `repair_ready`: true
- route admission: `bridge_or_legacy_limited`

That combined result is intentional. The old bridge fixture still caps broad
W2 claims.

## 7. W2 Certification Impact

W2 has entered the W1-style certification path for one concept family.

W2 is not 8.0 because only one canonical concept family is proven, broad W2
coverage is not migrated, poker correctness review is not complete,
payoff/progression is not certified, Human QA has not run, and the older
bridge fixture remains claim-limited.

W2 is not 9.0 or launch-ready because Human QA, correctness, full route/content
coverage proof, and durable learning proof remain incomplete.

## 8. Score Delta Proposal

Proposed conservative movement:

- W2: `4.7 -> 5.1`
- W1-W12 Volume I Premium Product Readiness: `6.3 -> 6.4`
- Content depth: `5.1 -> 5.2`
- Overall Top-1 Readiness: `6.1 -> 6.2`

The movement is justified by validator-backed canonical W2 route-ready
evidence for one concept family. It is small because broad W2 coverage and all
human/correctness/payoff gates remain open.

## 9. Route Impact

No runtime route, title, Act0 entry, table UI, telemetry, monetization, or
public launch surface changed.

W3-W6 remain bridge-limited. W7-W12 remain closed or non-routed. W13-W36 remain
long-horizon only.

## 10. Validation

Required validation for this wave:

- focused factory/export tests
- focused L2/L3 validator tests
- factory regeneration
- foundation validation
- L2/L3 validation for canonical-only and bridge-plus-canonical cases
- Dart formatting
- Flutter analysis
- graphify hook check
- diff whitespace checks

## 11. Forbidden Scope Proof

This wave did not perform broad W2 migration, W3-W6 migration, content
authoring, route/title runtime changes, W7-W12 opening, UI work, telemetry
changes, monetization work, screenshots, Modern Table work, store/public beta
work, Human QA execution, solver/GTO work, or external dependency changes.

## 12. Anti-Theater Check

The claim is intentionally narrow: one canonical W2 concept-family slice is
route-ready when evaluated by itself.

The wave preserves the negative control: bridge evidence still reports
`bridge_or_legacy_limited` when included with the canonical fixture.

## 13. Next-Step Decision

Recommended next wave:

`W2 Canonical Coverage Expansion PR2`

Rationale: W2 now has one route-ready canonical pilot, so the next highest-EV
step is to add more W2 canonical concept-family breadth under the same
validator path. W3-W6 migration, route-title realignment, W7-W12 opening,
Human QA execution, monetization, and launch claims remain out of sequence.
