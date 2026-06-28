# Wave 6.3 - Content Factory MVP / L1 Migrated Sample Pilot v1

## 1. Verdict

`wave6_3_content_factory_mvp_l1_sample_ready`

Wave 6.3 proves the first tiny L1 migrated-content sample can be represented
in the Wave 6.1 schema shape and validated by the Wave 6.2 checker without
touching runtime content.

This is a non-runtime pilot. It does not author new content, migrate active
content, normalize W2-W6, open W7-W12, or change route truth.

## 2. Source Truth

Files inspected and why:

- `AGENTS.md`: active repo boundary, Act0 route truth, testing policy, and
  graphify validation constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  validator/tooling orientation.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Wave 6.3 handoff, quick
  public/store beta pause, and top-1 anti-theater requirements.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active Wave 6.3
  state and must-not-skip list.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: canonical schema fields,
  route/content truth values, and coverage rules.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0-L4 validation ladder
  and Wave 6.3 handoff.
- `docs/_reviews/wave6_1_content_schema_foundation_v1.md`: accepted schema
  foundation verdict and route/content truth handling.
- `docs/_reviews/wave6_2_content_validation_rules_v1.md`: accepted L0
  validation verdict and still-open L1 migrated-content item.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  W1 is broad but implicit-schema; starting-hand discipline is a safe schema
  pilot candidate.
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json`:
  selected existing W1 source task for the migrated sample.
- `content/worlds/world1/v1/sessions/w1.s01/drills/index.md`: confirms
  `choose_fold` is an action-choice basic release rep after reading seat and
  action order.
- `tools/content_schema_foundation_validator_v1.dart`: L0 validator extended
  only enough to surface migration source metadata.
- `test/tools/content_schema_foundation_validator_v1_test.dart`: focused
  validator proof.

## 3. Problem Statement

Wave 6.2 proved the schema checker can validate a hand-authored L0 fixture.
That is not enough to start factory or migration work, because a real source
slice still needs a safe path into schema-shaped content.

Wave 6.3 therefore needed one validator-backed migrated sample from existing
W1 content before any route/content normalization, W1-W6 authoring, W5-W12
expansion, or route admission work.

## 4. Pilot Decision

W1 was chosen because it is route-current, lowest-risk, and explicitly
preferred by the prompt.

Source slice:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json`

Why this slice is safe:

- It is an existing W1 action-choice task.
- It has a simple source expected action: `fold`.
- The session index already describes it as a basic release rep after reading
  seat and action order.
- It avoids W2-W6 route/content drift and W7-W12 route locks.

Why this is non-runtime:

- The migrated sample lives only under `test/fixtures/`.
- No active content file was edited.
- No app route, registry, pack, UI, telemetry, or runtime loader consumes it.

## 5. L1 Fixture Summary

Fixture path:

- `test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`

Key fields:

- `fixture_level`: `l1_migrated_sample`
- `source_truth_status`: `migrated`
- `validation_status`: `source_validated`
- `route_gate_status`: `learner_playable`
- `concept_family_id`: `starting_hand_discipline`
- `repair_focus_id`: `release_weak_continue`
- `same_signal_group_id`:
  `w1.starting_hand_discipline.release_under_pressure`
- `migration_source.source_path`:
  `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json`

The fixture preserves the source action meaning by mapping source expected
action `fold` to schema `correct_action: fold`.

## 6. Validator Changes

Changed:

- `ContentSchemaFoundationValidationResultV1` now exposes
  `migrationSourcePaths` and `migrationSourceCount`.
- The validator collects `migration_source.source_path` from task records.
- CLI output includes `migration_sources=<count>`.

Not changed:

- No runtime content loading.
- No full L2 world coverage reporting.
- No L3 route admission gate.
- No L4 poker correctness gate.
- No W2-W6 normalization.
- No W7-W12 route exception.

## 7. Test Coverage

Updated:

- `test/tools/content_schema_foundation_validator_v1_test.dart`

Focused proof:

- L0 fixture still passes.
- L1 migrated sample passes.
- L1 sample exposes migration source metadata.
- Missing required field fails.
- Invalid status fails.
- Duplicate `task_id` fails.
- `preview_only: true` is excluded from coverage-countable totals.
- W7-W12 `learner_playable` fails.
- Non-ASCII fails.
- Migration metadata does not create a runtime dependency.
- CLI exits non-zero for an invalid fixture.

## 8. Route Impact

- No active route truth changed.
- No playable, locked, or routed status changed.
- W7-W10 remain `locked_not_learner_playable`.
- W11-W12 remain `authored_but_not_routed`.
- Quick public/store beta remains paused.

## 9. Files Changed

- `docs/_reviews/wave6_3_content_factory_mvp_l1_migrated_sample_v1.md`
  - docs/control-plane review artifact.
- `tools/content_schema_foundation_validator_v1.dart`
  - tooling.
- `test/tools/content_schema_foundation_validator_v1_test.dart`
  - test.
- `test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`
  - non-runtime fixture.

No product code, active content source, route file, generated output, UI,
telemetry, monetization, server, or screenshot artifact was changed.

## 10. Wave DoD Status

- [x] L1 migrated sample created.
- [x] L1 sample validates.
- [x] L0 fixture still validates.
- [x] Validator is isolated and non-runtime.
- [x] Source-reference metadata is surfaced without runtime dependency.
- [x] No runtime migration.
- [x] No content authoring.
- [x] No route opening.
- [x] Next factory/normalization handoff defined.

## 11. Evidence DoD Status

Commands and results:

- `flutter test test/tools/content_schema_foundation_validator_v1_test.dart`
  - Red before implementation: failed because
    `migrationSourceCount` and `migrationSourcePaths` were missing.
  - Green after implementation: 9 tests passed, exit 0.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`
  - Result: L0 fixture OK with `tasks=1 coverage_countable=1
    migration_sources=0`; L1 fixture OK with `tasks=1 coverage_countable=1
    migration_sources=1`; exit 0.
- `dart format --set-exit-if-changed tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart`
  - Result before artifact: 2 files checked, 0 changed, exit 0.
  - Final run: 2 files checked, 0 changed, exit 0.
- `flutter analyze`
  - Result: no issues found, exit 0.
- `graphify hook-check`
  - Result: passed, exit 0.
- `git diff --check`
  - Result: passed, exit 0.
- Direct ASCII check on changed markdown/fixture/code files.
  - Command:
    `LC_ALL=C grep -n '[^ -~]' docs/_reviews/wave6_3_content_factory_mvp_l1_migrated_sample_v1.md tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`
  - Result: no findings, exit 1 from grep.
- Direct trailing-whitespace and CRLF check on changed files.
  - Command:
    `perl -ne 'print "$ARGV:$.:CRLF\n" if /\r/; print "$ARGV:$.:TRAILING\n" if /[ \t]$/; close ARGV if eof' docs/_reviews/wave6_3_content_factory_mvp_l1_migrated_sample_v1.md tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`
  - Result: no findings, exit 0.

Screenshots were not run because this wave has no UI or visual scope.

## 12. Active Repair Queue Update

Closed items:

- L1 migrated content validation is now proven for one W1 source slice.
- The validator can surface migration source metadata.
- L0 validation remains green.

Newly discovered blockers:

- None that block Wave 6.3 closure.

Still-open items:

- L2 world coverage report.
- Full route/title/owner alignment against active route maps.
- Tiny content factory import/export.
- W2-W6 route/content normalization after pilot.
- Human QA Protocol before external beta or claims.

Deferred items:

- New W1-W6 content authoring.
- W5-W12 expansion.
- W7-W12 opening.
- Monetization.
- Store/public beta.

Items that must block forward movement:

- Do not author new content before factory proof.
- Do not normalize W2-W6 before the migrated-sample path is accepted.
- Do not claim coverage-ready from a single L1 sample.
- Do not open W7-W12 from fixture or registry presence.

## 13. Score Delta Proposal

Default proposal:

- Architecture scalability: `+0.2`
- W1-W12 Premium Product Readiness: `+0.1`
- Full readiness: `+0.1` maximum
- Overall top-1 readiness: `+0.1` maximum
- Content depth: unchanged
- Learning effect: unchanged

Reason: Wave 6.3 proves a real source slice can be migrated into schema shape
and validated. It does not prove coverage, author new content, open routes, or
create learner-visible value.

## 14. Anti-Theater Check

What risk actually moved?

- The schema/validator path now handles one real W1 source slice as an L1
  migrated sample, not only a synthetic L0 fixture.

What did not move?

- Content depth, coverage readiness, route admission, learning effect, poker
  correctness, monetization, and public readiness did not move materially.

Is this docs-only, code-backed, test-backed, or learner-visible?

- Code-backed and test-backed. It is not learner-visible.

Does this enable next factory/normalization step, or is PR2 needed?

- It enables the next factory/normalization step. PR2 is not expected if final
  validation stays green.

## 15. Remaining Work

Wave 6.3 closes if final validation is green.

PR2 is not expected.

Recommended actual next step:

- Volume I Launch Scope Rebaseline, because the prompt notes strategic launch
  direction is shifting toward perfect W1-W12 Volume I with W13-W36 as
  post-launch/live expansion.

Other eligible follow-ups after rebaseline:

- L2 world coverage report.
- Tiny content factory import/export.
- W2-W6 route/content normalization.
- Human QA Protocol.

Must not be skipped before authoring:

- accepted L1 migrated-sample proof;
- factory proof or import/export contract;
- W2-W6 route/content normalization plan;
- no W7-W12 opening without route-admission evidence.
