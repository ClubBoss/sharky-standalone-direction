# L2/L3 Content Validator Expansion v1

## 1. Verdict

`l2_l3_content_validator_ready`

The L2/L3 validator expansion is ready for its bounded purpose. It adds an
executable companion validator that reports L2 coverage metrics and enforces
L3 route-admission claim safety over schema-shaped fixtures.

This is validator/tooling work only. It does not author content, migrate broad
content, open W7-W12, change routes, change UI, change telemetry, change
monetization, touch Modern Table, or make W13-W36 launch-available.

## 2. Source truth

Focused files inspected and why:

- `AGENTS.md`: active repo boundary, Act0 route truth, no archive/donor roots,
  and validation policy.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch scope and
  W13-W36 deferral.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active next wave,
  score context, and anti-drift rules.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: world readiness and
  conservative score movement rules.
- `docs/_reviews/tiny_content_factory_import_export_mvp_v1.md`: accepted
  factory MVP and next-step handoff.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md`: accepted W2-W6
  bridge_or_legacy route/content normalization.
- `docs/_reviews/l2_volume_i_w1_w12_world_coverage_report_v1.md`: accepted L2
  coverage blocker report and W1-W12 truth classification.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: schema fields, route gate
  values, source truth values, and coverage thresholds.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0-L4 validation ladder,
  L2 thresholds, and L3 route/content rules.
- `tools/content_schema_foundation_validator_v1.dart`: L0/L1 base validator
  reused by the companion validator.
- `tools/content_factory_import_export_mvp_v1.dart`: factory MVP fixture
  generation shape.
- `test/tools/content_schema_foundation_validator_v1_test.dart`: base
  validator test style.
- `test/tools/content_factory_import_export_mvp_v1_test.dart`: factory MVP
  test style.
- Existing fixtures under `test/fixtures/content_schema_foundation/` and
  `test/fixtures/content_factory_mvp/`: L0, L1, and factory proof inputs.

## 3. Problem statement

The factory MVP proved that selected source tasks can become deterministic
schema-shaped fixtures. That does not prove world coverage, transfer breadth,
repair readiness, route admission, or launch claim safety.

Without L2/L3 checks, future agents could mistake one factory fixture, locked
content, bridge_or_legacy content, or authored-but-not-routed proof for
launch-ready content.

## 4. Validator decision

Decision:

- Created a focused companion tool:
  `tools/content_schema_l2_l3_validator_v1.dart`.

Reason:

- The existing foundation validator is the L0/L1 field/value checker.
- L2/L3 adds report semantics, coverage thresholds, and route-admission
  posture. Keeping it separate preserves the stable L0/L1 tool.

L2 reports:

- tasks by world;
- coverage-countable tasks by world;
- concept family counts;
- same-signal group counts;
- transfer surface counts;
- repair focus counts;
- preview-only exclusions;
- source truth distribution;
- validation status distribution;
- migration source presence.

L3 blocks:

- W7-W10 learner-playable claims;
- W11-W12 learner-playable claims without route admission metadata;
- W13-W36 launch-available or prelaunch-required claims;
- bridge_or_legacy launch coverage claims.

Deferred:

- L4 poker correctness.
- Broad source migration.
- Production route admission.
- Full W1-W12 content migration.

## 5. L2 coverage contract

Metrics:

- `totalTasks`
- `coverageCountableTasks`
- `previewOnlyTasks`
- `conceptFamilyCounts`
- `sameSignalGroupCounts`
- `transferSurfaceCounts`
- `repairFocusCounts`
- `sourceTruthStatusCounts`
- `validationStatusCounts`
- `migrationSourceCount`

Thresholds:

- A same-signal group needs at least 5 non-preview reps before becoming a
  coverage-ready candidate.
- A transfer-ready concept needs at least 2 distinct non-preview transfer
  surfaces.
- A repair-ready concept needs non-preview repair reps with `repair_focus_id`.

Exclusions:

- `preview_only: true` never counts toward coverage, transfer, repair, or
  mastery readiness.
- `bridge_or_legacy` content is reportable but not canonical launch coverage.
- Inferred filename, folder, registry, or test coverage does not count.

## 6. L3 route admission contract

Route/admission rules:

- W7-W10 fail if marked `learner_playable`.
- W11-W12 fail if marked `learner_playable` without explicit route admission
  metadata.
- W13-W36 fail if marked `launch_available` or `prelaunch_required`.
- Locked, internal, planned, blocked, or authored-but-not-routed records do
  not count as route-ready.
- `bridge_or_legacy` records stay `bridge_or_legacy_limited` unless a later
  migration/admission path changes them.
- Route-admission status is reported separately from content coverage status.

## 7. Fixtures used

Existing fixtures:

- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
  - proves L0 schema shape remains valid.
- `test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`
  - proves L1 migrated sample still validates.
- `test/fixtures/content_factory_mvp/w1_import_export_sample_v1.json`
  - proves factory W1 output stays schema-shaped.
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_import_export_sample_v1.json`
  - proves W2 bridge_or_legacy output stays reportable but limited.

New minimal fixture:

- `test/fixtures/content_schema_foundation/w1_l2_l3_coverage_ready_fixture_v1.json`
  - proves L2 same-signal threshold, transfer breadth, repair field presence,
    migration metadata counting, and preview-only exclusion.

Fail cases are synthetic in tests to avoid committing invalid route/content
fixtures as reusable source truth.

## 8. Test coverage

Added:

- `test/tools/content_schema_l2_l3_validator_v1_test.dart`

Tests prove:

- L2 coverage metrics count world/concept/same-signal/transfer/repair fields.
- `preview_only` tasks are excluded from coverage counts.
- W1 synthetic fixture can become coverage-ready under the L2 thresholds.
- W2 factory bridge fixture is reportable but not canonical launch coverage.
- W7 learner-playable claims fail.
- W11 learner-playable without route admission metadata fails.
- W13 launch-available claims fail.
- Thin same-signal, transfer, and repair fields fail.
- CLI exits non-zero for invalid L3 route claims.

## 9. Volume I ledger impact

Updated:

- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

World scores:

- No individual world score moved.

Aggregate score movement:

- W1-W12 Volume I Premium Product Readiness: `5.5 -> 5.6`
- Overall Top-1 Readiness: `5.3 -> 5.4`
- Architecture scalability: `7.6 -> 7.8`

Unchanged:

- Full W1-W36 Long-Horizon Readiness: `3.0`
- Content depth: `4.5`
- Learning effect: `6.0`
- Monetization readiness: `2.0`

Reason: executable L2/L3 checks reduce claim-safety and tooling risk. They do
not add real migrated coverage, learner-visible value, correctness review, or
human QA.

## 10. Route impact

- No active route truth changed.
- No learner-facing title changed.
- No world became playable, locked, or routed differently.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain post-launch/live expansion, not launch-available.
- No monetization, store, public beta, paywall, or entitlement changed.

## 11. Active repair queue update

Closed:

- L2 coverage reporting over schema-shaped fixtures.
- L3 route-admission claim checks over schema-shaped fixtures.
- Bridge_or_legacy reporting as limited, not canonical launch coverage.

Active:

- W1 World Coverage Expansion Pilot.
- W1-W6 Schema Migration Pilot, only after the W1 path stays validator-backed.
- Validator-led factory expansion across W2-W6.

Must-not-skip:

- L2/L3 validator pass before broad authoring.
- W2-W6 route/content normalization fields in every bridge sample.
- Human QA Protocol before external beta or claims.
- W1-W12 correctness review before premium claims.

Deferred:

- New W1-W6 content authoring.
- W5-W12 expansion.
- W7-W12 opening.
- W13-W36 content production.
- Monetization.
- Store/public beta.

Blockers:

- Real migrated W1-W6 coverage is incomplete.
- Content factory remains tiny.
- Human novice QA is unavailable.
- Poker correctness protocol is not complete.

## 12. Score delta proposal

- W1-W12 Volume I Premium Product Readiness: `5.5 -> 5.6`
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`
- Overall Top-1 Readiness: `5.3 -> 5.4`
- Architecture scalability: `7.6 -> 7.8`
- Content depth: unchanged at `4.5`
- Learning effect: unchanged at `6.0`
- Monetization readiness: unchanged at `2.0`

## 13. Next-step recommendation

Recommended next step:

`W1 World Coverage Expansion Pilot`

Why:

- L2/L3 validator is ready.
- W1 is the lowest-risk canonical path.
- W2 bridge content is now explicitly limited and should not be the first
  coverage expansion claim.
- Broad authoring remains unsafe until a real W1 migration/coverage slice
  passes the new checks.

## 14. Wave DoD status

- [x] L2 coverage reporting exists.
- [x] L3 route admission checks exist.
- [x] Focused tests pass.
- [x] Fixtures cover pass and fail cases.
- [x] `preview_only` exclusion tested.
- [x] Locked/non-routed route gate tested.
- [x] `bridge_or_legacy` handling tested.
- [x] No content authored.
- [x] No broad migration.
- [x] No route opening.
- [x] Next step selected.

## 15. Evidence DoD status

Commands and results:

- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart`
  - Red before implementation: failed because
    `tools/content_schema_l2_l3_validator_v1.dart` did not exist.
  - Green after implementation: 5 tests passed, exit 0.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_schema_foundation/w1_l2_l3_coverage_ready_fixture_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_import_export_sample_v1.json`
  - Result: W1 `coverage_ready=true`, W2
    `route_admission=bridge_or_legacy_limited`, exit 0.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_schema_foundation/w1_l2_l3_coverage_ready_fixture_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_import_export_sample_v1.json`
  - Result: both fixtures OK, exit 0.
- `dart format --set-exit-if-changed tools/content_schema_l2_l3_validator_v1.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`
  - Result: 2 files checked, 0 changed, exit 0.
- `flutter analyze`
  - Result: no issues found, exit 0.
- `graphify hook-check`
  - Result: passed, exit 0.
- `git diff --check`
  - Result: passed, exit 0.
- Direct ASCII check on changed markdown/json/dart/test files.
  - Result: no findings, exit 1 from grep.
- Direct trailing-whitespace and CRLF check on changed files.
  - Result: no findings, exit 0.

Screenshots were not run because this wave has no UI or visual scope.

## 16. Anti-theater check

What risk moved:

- Coverage readiness and route admission now have executable checks.
- Bridge_or_legacy factory output is explicitly limited, not coverage-ready.
- W7-W12 and W13-W36 invalid route/launch claims are blocked by tests.

What did not move:

- No active content was migrated.
- No broad W1-W6 coverage was created.
- No W5-W12 expansion started.
- No W7-W12 route opened.
- No W13-W36 launch availability changed.
- No learner-visible value, human QA, poker correctness, monetization, or
  store readiness changed.

This is code-backed and test-backed tooling progress. It enables a W1 World
Coverage Expansion Pilot; it does not enable broad authoring yet.
