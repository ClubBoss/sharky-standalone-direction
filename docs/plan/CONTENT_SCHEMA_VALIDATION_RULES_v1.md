# Content Schema Validation Rules v1

Status: ACTIVE validation rules for Content Schema Foundation v1.
Created: 2026-06-28.

## 1. Purpose And Authority

This document operationalizes
`docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md` into executable validation levels,
rules, and future gates for content migration, factory work, and route
admission.

Authority order:

1. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
2. `docs/plan/MASTER_PLAN_v3.0.md`
3. `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
4. `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
5. `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`
6. This validation rules document
7. Validator scripts, fixtures, tests, and migration reports

Wave 6.2 implements only an L0 fixture schema check. Later levels must use
these rules without treating this wave as content migration, coverage proof,
route admission, or poker-correctness approval.

## 2. Non-Goals

This validation layer does not:

- migrate W1-W6 content;
- validate all existing content as a blocking gate;
- author or rewrite lessons, tasks, drills, or poker advice;
- open W7-W12;
- make W7-W12 learner-playable;
- create W13-W36 content;
- change runtime routes, UI, Modern Table, telemetry, monetization, server
  analytics, dependencies, or generated output;
- infer coverage from filenames, folders, registry rows, or display copy;
- approve advanced W7+ poker advice for public claims.

## 3. Validation Levels

| Level | Name | Scope | Wave 6.2 status |
| --- | --- | --- | --- |
| L0 | Fixture schema check | Validate tiny schema-shaped fixtures against field, value, ID, preview, duplicate, and route-gate rules. | Implemented for one W1 fixture. |
| L1 | Migrated content file check | Validate one migrated content file or session against the same schema rules. | Deferred. |
| L2 | World coverage report | Produce report-only coverage counts by concept, repair focus, same-signal group, and transfer surface. | Deferred. |
| L3 | Route admission gate | Block route admission if content, route gate, preview, validation, or coverage evidence is missing. | Deferred. |
| L4 | Poker correctness gate | Require expert/solver/protocol review before advanced W7+ public correctness claims. | Deferred. |

Only L0 is executable in Wave 6.2. L1-L4 are documented so later migration and
factory work has a stable gate ladder.

## 4. Required Field Rules

Every L0 task object must include these fields:

- `schema_version`
- `world_id`
- `route_world_id`
- `display_world_title`
- `content_owner_world_id`
- `route_gate_status`
- `lesson_id`
- `task_id`
- `concept_family_id`
- `drill_kind`
- `feedback_reason`
- `validation_status`
- `preview_only`
- `source_truth_status`

Every decision task must also provide at least one of:

- non-empty `correct_action`
- non-empty `acceptable_actions`

Allowed `source_truth_status` values:

- `canonical`
- `bridge_or_legacy`
- `preview_only`
- `migrated`
- `blocked_conflict`

Allowed `route_gate_status` values:

- `learner_playable`
- `locked_preview`
- `internal_only`
- `authored_but_not_routed`
- `planned_only`
- `blocked`

Allowed `validation_status` values:

- `draft`
- `source_validated`
- `runtime_validated`
- `poker_review_needed`
- `poker_reviewed`
- `blocked`

## 5. Conditional Rules

Conditional L0 rules:

- If `repairable` is `true`, `repair_focus_id` must be present and non-empty.
- If `claims_same_signal` is `true`, `same_signal_group_id` must be present
  and non-empty.
- If `claims_transfer` is `true`, `transfer_surface_id` must be present and
  non-empty.
- `preview_only` must be a boolean.
- `preview_only: true` tasks must not count toward coverage-ready, mastery,
  same-signal, transfer, or repair-ready counts.
- W7-W12 tasks must not use `route_gate_status: learner_playable` unless a
  future route-admission artifact explicitly changes route truth.
- `task_id` must be unique within the validated fixture.

Format rules:

- Changed markdown, fixture, tool, and test files must be ASCII-only.
- Stable IDs use lowercase ASCII letters, digits, underscores, dots, or
  hyphens.
- Raw Unicode suits, arrows, emojis, and unsupported claim language are not
  allowed in validation examples.
- Display copy may be human-readable, but IDs must not depend on display copy.

## 6. Coverage Rules

Coverage-threshold rules are documented in Wave 6.2 but not fully implemented
because the L0 fixture is intentionally tiny.

Future L2/L3 rules:

- A same-signal group needs at least 5 non-preview reps before it can become a
  `coverage_ready` candidate.
- A transfer claim needs at least 2 distinct non-preview
  `transfer_surface_id` values for the same concept family.
- `preview_only: true` tasks are excluded from mastery and coverage counts.
- `coverage_ready` cannot be inferred from filenames, folder counts, registry
  rows, historical calibration, or display copy alone.
- Repair-ready claims require `repair_focus_id` and a misconception or
  correction path.
- Coverage outputs are validator/report results, not author-provided source
  claims.

## 7. Route/Content Alignment Rules

Route/content validation must check:

- `world_id` declares the content record's world.
- `route_world_id` declares the learner-route world.
- `content_owner_world_id` declares source ownership.
- `display_world_title` aligns with active route truth for the route world.
- `source_truth_status` states whether the record is canonical, bridge,
  preview, migrated, or blocked.
- `route_gate_status` states whether the record is playable, locked,
  internal, authored-but-not-routed, planned, or blocked.

L0 enforces route-gate value validity and blocks W7-W12
`learner_playable`. Later L1-L3 validators should add full title and owner
alignment checks against the active route map.

## 8. Claim-Safety And Validation-Status Rules

Validation status must be one of the allowed values in section 4.

Claim-safety rules:

- `draft` content is not claim-ready.
- `source_validated` means schema/source checks passed, not runtime proof.
- `runtime_validated` means the app or runner consumed the content as
  expected, not poker correctness approval.
- `poker_review_needed` must block public correctness claims until the
  accepted correctness protocol is complete.
- `poker_reviewed` requires the later accepted correctness protocol.
- `blocked` content must not be routed, counted, or claimed.
- W7+ advanced advice requires later correctness review before public claims,
  even if source and runtime validation pass.

## 9. Wave 6.3 Handoff

Wave 6.3 should consume this validation layer as the gate for a tiny Content
Factory MVP or one isolated migrated source sample.

Recommended Wave 6.3 inputs:

- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`
- this validation rules document
- `tools/content_schema_foundation_validator_v1.dart`
- `test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json`
- `test/tools/content_schema_foundation_validator_v1_test.dart`

Recommended Wave 6.3 work:

1. Keep L0 green.
2. Add one tiny L1 migrated-content fixture or source sample.
3. Keep any current-content scan report-only and non-blocking.
4. Do not open W7-W12.
5. Do not claim content depth or coverage-ready until L2 thresholds are
   implemented and met.

Route/content normalization should wait until after the validator can protect
one migrated file or factory output.
