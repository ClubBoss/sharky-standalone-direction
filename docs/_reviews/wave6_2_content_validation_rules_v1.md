# Wave 6.2 - Content Validation Rules v1

## 1. Verdict

`wave6_2_content_validation_rules_ready`

Wave 6.2 converts the Wave 6.1 docs-only schema foundation into an executable
L0 validator/checker for a tiny non-runtime W1 schema fixture.

The wave does not migrate runtime content, author lessons, open W7-W12, or
claim coverage readiness.

## 2. Source Truth

Files inspected and why:

- `AGENTS.md`: active repo boundary, Act0 route truth, graphify validation,
  testing policy, and forbidden archive/donor routing.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  validator/tooling orientation.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Full Top-1 route,
  quick-beta pause, and anti-theater requirements.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: Stage B content
  factory ordering and architecture-scalability score context.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  accepted reason schema-first validation is required before content-depth
  claims.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: canonical Wave 6.1 schema
  authority and Wave 6.2 validator handoff.
- `docs/_reviews/wave6_1_content_schema_foundation_v1.md`: accepted prior
  wave verdict, route/content truth handling, and validator list.
- `tools/content_schema_validator.dart`: existing broad schema validator;
  not reused because it scans module schemas and writes release reports, while
  Wave 6.2 needs an isolated non-runtime L0 fixture gate.
- `test/tools/content_quality_validator_v1_test.dart` and
  `test/tools/content_integrity_validator_v1_test.dart`: local pattern for
  deterministic validator tests with synthetic or focused fixtures.

## 3. Problem Statement

Wave 6.1 defined the schema vocabulary but left it docs-only. Without an
executable checker, future factory or migration work could still omit required
fields, infer coverage from filenames, or accidentally weaken the W7-W12 route
gate.

Wave 6.2 needs the first small proof that the schema can be enforced without
bulk-validating or migrating existing content.

## 4. Validation Decision

Implemented validation level: L0 fixture only.

Created:

- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
- `test/tools/content_schema_foundation_validator_v1_test.dart`

The checker validates one schema-shaped fixture by default and can validate
explicit fixture paths from the command line. It is isolated from runtime
content and does not write reports or generated output.

## 5. Rules Implemented

Implemented L0 rules:

- required field presence for the Wave 6.2 required field list;
- at least one of `correct_action` or non-empty `acceptable_actions`;
- allowed `source_truth_status` values;
- allowed `route_gate_status` values;
- allowed `validation_status` values;
- `repairable: true` requires `repair_focus_id`;
- `claims_same_signal: true` requires `same_signal_group_id`;
- `claims_transfer: true` requires `transfer_surface_id`;
- `preview_only` must be boolean;
- `preview_only: false` counts toward the validator's coverage-countable
  total, while preview-only tasks do not;
- W7-W12 cannot use `route_gate_status: learner_playable`;
- stable ID format for ID-like fields;
- ASCII-only fixture/task text;
- duplicate `task_id` detection within the fixture;
- CLI returns exit 2 for invalid fixtures.

## 6. Rules Documented But Deferred

Documented but deferred to L2/L3:

- same-signal group threshold of at least 5 non-preview reps before
  `coverage_ready` candidate;
- transfer threshold of at least 2 distinct non-preview
  `transfer_surface_id` values for the same concept family;
- world-level concept-family coverage reporting;
- full route/title/owner alignment against active route maps;
- L3 route admission gate;
- L4 poker correctness gate for W7+ advanced advice.

## 7. Fixture/Pilot Status

Pilot fixture:

- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`

Scope:

- one W1 task-shaped object;
- non-runtime;
- not imported by product code;
- not a replacement for current W1 content;
- not a content migration.

The fixture exists only to prove the schema rules are executable.

## 8. Files Changed

- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`
- `docs/_reviews/wave6_2_content_validation_rules_v1.md`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/tools/content_schema_foundation_validator_v1_test.dart`
- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`

No product runtime file, active content source, UI, telemetry, monetization,
server, screenshot, or generated-output file was changed.

## 9. Wave DoD Status

- [x] Validation rules doc created.
- [x] L0 fixture/check implemented.
- [x] Required fields enforced.
- [x] Allowed values enforced.
- [x] Conditional rules defined and enforced for L0 fixture fields.
- [x] Coverage thresholds defined.
- [x] Route/content alignment rules defined.
- [x] W7-W12 learner-playable route gate blocked.
- [x] No content migration.
- [x] No route opening.
- [x] No authoring.

## 10. Evidence DoD Status

Commands and results:

- `flutter test test/tools/content_schema_foundation_validator_v1_test.dart`
  - Red before implementation: failed to load because
    `tools/content_schema_foundation_validator_v1.dart` did not exist.
  - Green after implementation: 6 tests passed, exit 0.
- `dart run tools/content_schema_foundation_validator_v1.dart`
  - Result: validated
    `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
    with `tasks=1 coverage_countable=1`, OK, exit 0.
- `dart format --set-exit-if-changed tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart`
  - First run formatted both files, exit 1.
  - Final run: 2 files checked, 0 changed, exit 0.
- `flutter analyze`
  - Result: no issues found, exit 0.
- `graphify hook-check`
  - Result: passed, exit 0.
- `git diff --check`
  - Result: passed, exit 0.
- Direct ASCII check on changed markdown/fixture/code files.
  - Command:
    `LC_ALL=C grep -n '[^ -~]' docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md docs/_reviews/wave6_2_content_validation_rules_v1.md tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
  - Result: no findings, exit 1 from grep.
- Direct trailing-whitespace and CRLF check on changed files.
  - Command:
    `perl -ne 'print "$ARGV:$.:CRLF\n" if /\r/; print "$ARGV:$.:TRAILING\n" if /[ \t]$/; close ARGV if eof' docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md docs/_reviews/wave6_2_content_validation_rules_v1.md tools/content_schema_foundation_validator_v1.dart test/tools/content_schema_foundation_validator_v1_test.dart test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
  - Result: no findings, exit 0.

Screenshots were not run because this wave has no UI or visual scope.

## 11. Score Delta Proposal

Default proposal:

- Architecture scalability: `+0.3`
- Content depth: unchanged
- Learning effect: unchanged
- Full readiness: `+0.1` maximum
- Overall top-1 readiness: `+0.1` maximum

Reason: Wave 6.2 adds executable schema enforcement for a tiny fixture, which
moves content-factory architecture risk. It does not migrate content, prove
coverage, open routes, or validate learning transfer.

## 12. Active Repair Queue Update

Closed items:

- Wave 6.1 schema was docs-only; Wave 6.2 now has an executable L0 fixture
  checker.
- Required field, allowed-value, conditional, duplicate-ID, ASCII, preview,
  and W7-W12 route-gate rules are enforceable on schema-shaped fixtures.

Newly discovered blockers:

- None that block Wave 6.2 closure.

Still-open items:

- L1 migrated content validation.
- L2 world coverage reporting.
- L3 route admission gate.
- L4 W7+ poker correctness gate.
- Full route/title/owner alignment against active route maps.

What must not be skipped:

- Do not migrate W1-W6 or author W5-W12 before the validator protects at least
  one migrated source sample or factory output.
- Do not infer `coverage_ready` from filenames.
- Do not route W7-W12 from fixture or registry presence.

Whether Wave 6.3 remains the right next step:

- Yes, if Wave 6.3 is a Content Factory MVP or one tiny L1 migrated sample that
  consumes the L0 validator.

## 13. Anti-Theater Check

What risk actually moved?

- The schema is now executable at L0, so future fixture/factory work can be
  checked for required fields, allowed values, duplicate IDs, preview handling,
  and W7-W12 route-gate violations.

What did not move?

- No content depth, world coverage, learner-visible route, poker correctness,
  monetization, telemetry, or learning-effect proof moved.

Is this docs-only, code-backed, test-backed, or learner-visible?

- Code-backed and test-backed. It is not learner-visible.

Does this PR enable Wave 6.3, or is PR2 needed first?

- It enables Wave 6.3. No PR2 is needed if final validation stays green.

## 14. Remaining Work

Wave 6.2 closes if final validation is green.

PR2 is not expected.

Wave 6.3 Content Factory MVP can proceed only as a tiny factory or L1 migrated
sample that consumes this validator and does not open routes.

Route/content normalization should wait until after Wave 6.3 proves one
factory output or migrated source sample can stay schema-valid.
