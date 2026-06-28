# Tiny Content Factory Import/Export MVP v1

## 1. Verdict

`factory_import_export_mvp_ready`

The tiny Content Factory Import/Export MVP is ready for its bounded purpose:
one W1 migrated source task and one safe W2 bridge_or_legacy source task can
be imported from existing source JSON and exported into deterministic
Content Schema Foundation shaped fixtures.

This is not a runtime migration, broad migration, authoring pass, UI change,
telemetry change, monetization change, Modern Table change, W7-W12 opening, or
external beta claim.

## 2. Source truth

Files inspected and used:

- `tools/content_schema_foundation_validator_v1.dart`: validator API and
  required schema fields.
- `test/tools/content_schema_foundation_validator_v1_test.dart`: existing
  validation-test style.
- `test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json`:
  accepted L1 migrated sample pattern.
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json`:
  selected W1 source task.
- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_fold_early.json`:
  selected W2 bridge_or_legacy source task.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md`: accepted W2-W6
  route/content normalization posture.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: world score movement and
  next-action ledger.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon
  queue and anti-drift rules.

## 3. Problem statement

Wave 6.3 proved one validator-backed L1 migrated sample, but the project still
lacked a tiny import/export proof. Without that proof, future authoring could
skip schema fields, lose migration-source metadata, or collapse route title
and content-owner truth for W2-W6 bridge content.

## 4. Factory MVP decision

The MVP is intentionally small:

- W1 sample: `choose_fold`, a safe migrated baseline.
- W2 sample: `choose_fold_early`, a bridge_or_legacy action-choice task with
  the same simple expected-action shape.

W2 was safe to include because it has a clear `expected.actionId`, clear
`why_v1`, and can carry the accepted W2 route/content normalization fields
without rewriting source content or learner-facing route titles.

## 5. Import/export contract

The factory exports:

- `schema_version`
- `world_id`
- `route_world_id`
- `display_world_title`
- `content_owner_world_id`
- `route_gate_status`
- `lesson_id`
- `session_id`
- `pack_id`
- `task_id`
- `concept_family_id`
- `repair_focus_id`
- `same_signal_group_id`
- `misconception_id`
- `drill_kind`
- `correct_action`
- `acceptable_actions`
- `feedback_reason`
- `validation_status`
- `preview_only`
- `source_truth_status`
- `locale_key`
- `migration_source`

For W2 bridge content, the exported task preserves:

- `route_world_id: world_2`
- `display_world_title: Hand Discipline`
- `content_owner_world_id: world_2`
- `source_truth_status: bridge_or_legacy`
- source job metadata under `migration_source.source_job`

## 6. Fixture/output summary

Generated fixtures:

- `test/fixtures/content_factory_mvp/w1_import_export_sample_v1.json`
  - one W1 migrated task;
  - `task_id: w1.s01.choose_fold.import_export_sample_v1`;
  - `source_truth_status: migrated`;
  - `correct_action: fold`.
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_import_export_sample_v1.json`
  - one W2 bridge_or_legacy task;
  - `task_id: w2.s01.choose_fold_early.import_export_sample_v1`;
  - `display_world_title: Hand Discipline`;
  - `source_truth_status: bridge_or_legacy`;
  - `correct_action: fold`.

Both fixtures are non-runtime test fixtures.

## 7. Tooling changes

Added:

- `tools/content_factory_import_export_mvp_v1.dart`

The tool:

- imports the selected source JSON tasks;
- maps the safe source fields into schema-shaped task records;
- writes deterministic JSON with stable field order;
- validates generated fixtures through
  `validateContentSchemaFoundationMapV1`;
- exits non-zero if validation errors are found.

No runtime loader consumes the generated fixtures.

## 8. Test coverage

Added:

- `test/tools/content_factory_import_export_mvp_v1_test.dart`

Covered behavior:

- imports the selected W1 source task;
- exports deterministic schema-shaped JSON;
- validates the W1 sample with the schema validator;
- exports the W2 bridge sample with normalized route/content fields;
- rejects duplicate task IDs through the schema validator;
- rejects missing required fields through the schema validator;
- rejects non-ASCII text through the schema validator;
- confirms `preview_only: true` is excluded from coverage count;
- preserves migration-source metadata in exported JSON;
- confirms source content files are not modified by fixture writing.

## 9. Volume I ledger impact

Updated:

- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

Score movement:

- W1: `6.5 -> 6.6`
- W2: `4.4 -> 4.5`
- W1-W12 Volume I Premium Product Readiness: `5.4 -> 5.5`
- Overall Top-1 Readiness: `5.2 -> 5.3`
- Architecture scalability: `7.4 -> 7.6`

No content-depth, learning-effect, monetization, route-admission, or human-QA
score moves were claimed.

## 10. Route impact

No runtime route changed.

No learner-facing title changed.

W2 bridge export keeps the active route title separate from source job
metadata. W7-W10 remain locked, and W11-W12 remain authored but not routed.

## 11. Active repair queue update

Closed:

- Tiny Content Factory Import/Export MVP.
- One W1 source task exported into schema-shaped fixture output.
- One W2 bridge_or_legacy source task exported with normalized route/content
  fields.

Still open:

- L2/L3 Content Validator Expansion.
- Validator-led factory expansion across W2-W6.
- W7-W12 Admission/Content Lock.
- Human QA Protocol before external beta or claims.

Deferred:

- New W1-W6 content authoring.
- W5-W12 expansion.
- W7-W12 opening.
- Monetization.
- Store/public beta.

## 12. Score delta proposal

Accepted conservative proposal:

- Architecture scalability: `+0.2`
- W1-W12 Volume I Premium Product Readiness: `+0.1`
- Overall Top-1 Readiness: `+0.1`
- W1: `+0.1`
- W2: `+0.1`

Reason: the wave proves import/export mechanics and route/content metadata
preservation for tiny samples. It does not prove broad coverage, poker
correctness, human QA, route admission, or learner-visible value.

## 13. Next-step recommendation

Recommended next wave:

`L2/L3 Content Validator Expansion`

Why:

- The factory can now emit tiny schema-shaped samples.
- The next blocking risk is validation breadth across migrated/bridge samples,
  not new authoring.
- W2-W6 bridge samples must continue preserving route title, content owner,
  source truth, and source job separately.

## 14. Wave DoD status

- [x] One validator-backed migrated W1 sample imported/exported.
- [x] One W2 bridge_or_legacy sample imported/exported.
- [x] Factory output includes Content Schema Foundation fields.
- [x] W2 output preserves route/content normalization fields.
- [x] Deterministic fixture JSON generated.
- [x] Focused tests added.
- [x] Runtime content files were not modified.
- [x] No broad migration or authoring.
- [x] No W7-W12 opening.

## 15. Evidence DoD status

Commands and results:

- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart`
  - Red before implementation: failed because
    `tools/content_factory_import_export_mvp_v1.dart` did not exist.
  - Green after implementation: 6 tests passed, exit 0.
- `dart run tools/content_factory_import_export_mvp_v1.dart`
  - Result: wrote two fixtures, both with `tasks=1 coverage_countable=1`,
    exit 0.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_import_export_sample_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_import_export_sample_v1.json`
  - Result: both fixtures OK, exit 0.
- `dart format --set-exit-if-changed tools/content_factory_import_export_mvp_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart`
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

- The project now has a deterministic tiny source-to-schema import/export
  path.
- One W2 bridge sample proves route title and source job can stay separate.
- Generated fixtures are validator-backed and preserve source metadata.

What did not move:

- No active content was migrated.
- No broad W1-W6 coverage was proven.
- No W5-W12 expansion was started.
- No W7-W12 route opened.
- No public launch, monetization, store, external beta, or learning-effect
  claim is safer from this wave alone.
