# Wave 6.1 - Content Schema Foundation v1

## 1. Verdict

`wave6_1_schema_foundation_docs_only_ready`

Wave 6.1 defines the canonical content schema foundation needed before
scalable W5-W12 content work, W7-W12 route admission, or coverage-ready claims.

The wave is docs-only. It adds the schema SSOT and this review artifact. It
does not migrate content, open routes, change runtime behavior, or add
validators.

## 2. Source Truth

Files inspected and why:

- `AGENTS.md`: active root, Act0 boundary, graphify policy, route authority,
  and no-archive default.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/MASTER_PLAN_v3.0.md`: day-to-day product priority, active route
  truth, and content-quality bar.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Full Top-1 route and
  quick public/store beta pause.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: Stage B content
  factory ordering and Wave 6.1 architecture-scalability role.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  accepted finding that W1-W6 content depth needs schema-first normalization.
- `docs/_reviews/wave5_2_w7_w12_route_truth_reconciliation_v1.md`: W7-W12
  route-truth conflict classification.
- `docs/_reviews/wave5_2_w7_w10_current_campaign_status_alignment_v1.md`:
  accepted follow-up making W7-W10 `locked_not_learner_playable` and keeping
  W11-W12 `authored_but_not_routed`.
- `docs/content/CONTENT_SYSTEM_v2.1.md`: existing content-system hierarchy,
  micro-session shape, transfer requirement, and QA stage precedent.
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`: active content roots and
  source-stack ownership.
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`: one-skill, one-situation,
  repair, feedback, variation, and mastery-signal bar.
- `docs/plan/CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md`: existing
  authoring grammar for setup, concept framing, expected answer, acceptable
  answers, mismatch, correction, and recap.
- `docs/plan/CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`: density and
  meaningful-world requirements.
- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`: W1-W6 concept-family
  and world-title authority for coverage mapping.
- `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md`: equal felt
  completeness and scoring-axis precedent.
- `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`: historical
  calibration context that must not override current route/schema findings.

Referenced but not found:

- `docs/plan/SEAM_TRANSITION_AUDIT_TEMPLATE_v1.md`: the path named in the
  prompt does not exist in the active repo. This is not a blocker for Wave 6.1
  because the wave defines schema foundation, not a seam-transition audit.

## 3. Problem Statement

Wave 5.3 found that W1-W6 content is not safely claimable as
coverage-normalized content because current source files do not consistently
carry explicit `concept_family_id`, `repair_focus_id`,
`same_signal_group_id`, or `transfer_surface_id`.

It also found route/content title drift between practical route titles and
some content-root naming. Folder presence, filenames, historical calibration,
and registry rows are not enough to prove content depth or same-signal
coverage.

Wave 5.2 and its follow-up also require schema-level route truth: W7-W10 are
locked in the active learner route, and W11-W12 are authored but not routed.
Schema work must preserve that boundary rather than accidentally promoting
content to playable status.

## 4. Schema Decision

Created:

- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`

The schema foundation defines:

- authority and non-goals;
- core entity model for World, Lesson, Session/Pack, Task/Drill, Chain,
  Feedback, Concept family, Repair focus, Same-signal group, Transfer surface,
  Misconception, Route gate, and Validation status;
- required IDs and fields;
- `source_truth_status` values;
- `route_gate_status` values;
- coverage, same-signal, transfer, repair, preview, and claim-safety rules;
- validation status values;
- a docs-only W1 JSON example;
- Wave 6.2 validator handoff list.

The schema keeps nullable fields present as `null` when not applicable so
validators can distinguish intentional absence from missing data.

## 5. Route/Content Truth Handling

The schema explicitly separates:

- `world_id`: the world declared by the content record.
- `route_world_id`: the world shown by the active learner route.
- `display_world_title`: the route-facing world title that must align with
  active route truth.
- `content_owner_world_id`: the owner of source truth when route and content
  differ.
- `source_truth_status`: source posture such as `canonical`,
  `bridge_or_legacy`, `preview_only`, `migrated`, or `blocked_conflict`.
- `route_gate_status`: route posture such as `learner_playable`,
  `locked_preview`, `internal_only`, `authored_but_not_routed`,
  `planned_only`, or `blocked`.

Current route implications encoded in the schema:

- W1-W6 may contain learner-playable content only where active route truth and
  validation support it.
- W7-W10 cannot be schema-validated as `learner_playable` under the current
  route truth; they remain locked preview or internal-only until a later route
  admission artifact changes that.
- W11-W12 source records, where present, must remain
  `authored_but_not_routed` unless a later route admission artifact changes
  that.
- Registry presence, folder presence, filenames, or display copy cannot
  override `route_gate_status`.

## 6. Coverage And Same-Signal Rules

Wave 6.1 locks these coverage rules:

- every decision rep must carry `concept_family_id`;
- every repairable concept must carry `repair_focus_id`;
- every same-signal claim requires `same_signal_group_id`;
- every transfer claim requires `transfer_surface_id`;
- `preview_only: true` reps do not count toward mastery, coverage, repair,
  same-signal, or transfer claims;
- `coverage_ready` cannot be claimed from filenames, pack IDs, folder counts,
  registry rows, or historical calibration alone;
- a same-signal group needs at least 5 non-preview reps before it can become a
  coverage-ready candidate;
- transfer requires at least 2 distinct non-preview `transfer_surface_id`
  values for the same concept family;
- repair-ready concepts require a repair focus and misconception or correction
  path;
- W7-W12 remain locked or non-routed unless a later route-admission artifact
  changes route truth.

## 7. Pilot Status

Pilot type: docs-only schema plus example JSON snippet.

No runtime file, fixture, validator, migration, or content record was added.

Reason:

- Wave 5.3 found source/title/coverage drift that should be normalized through
  schema before file churn.
- The prompt explicitly permits docs-only schema plus a JSON example when a
  tiny runtime pilot is not the safest first move.
- A real validator is the proper Wave 6.2 follow-up because it needs the
  accepted schema contract first.

## 8. Files Changed

- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`
- `docs/_reviews/wave6_1_content_schema_foundation_v1.md`

No product code, runtime route, content source, telemetry, monetization, UI,
or generated-output file was changed.

## 9. Wave DoD Status Checklist

- [x] Create canonical content schema foundation document.
- [x] Create Wave 6.1 review artifact.
- [x] Define purpose, authority, and non-goals.
- [x] Define core entity model.
- [x] Define required IDs and fields.
- [x] Define `source_truth_status` values.
- [x] Define `route_gate_status` values.
- [x] Define coverage, same-signal, transfer, repair, and preview rules.
- [x] Define claim-safety and poker-correctness validation statuses.
- [x] Include ASCII-only W1 JSON example.
- [x] Decide tiny pilot status.
- [x] Provide Wave 6.2 validator handoff list.
- [x] Preserve W7-W10 locked and W11-W12 authored-but-not-routed boundary.
- [x] Avoid forbidden scope.

## 10. Evidence DoD Status

Commands and results:

- `graphify hook-check`
  - Result: passed, exit 0.
- `git diff --check`
  - Result: passed, exit 0.
- Direct ASCII check on changed markdown files.
  - Command:
    `LC_ALL=C grep -n '[^ -~]' docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md docs/_reviews/wave6_1_content_schema_foundation_v1.md`
  - Result: no findings, exit 1 from grep.
- Direct trailing-whitespace and CRLF check on changed markdown files.
  - Command:
    `perl -ne 'print "$ARGV:$.:CRLF\n" if /\r/; print "$ARGV:$.:TRAILING\n" if /[ \t]$/; close ARGV if eof' docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md docs/_reviews/wave6_1_content_schema_foundation_v1.md`
  - Result: no findings, exit 0.

Dart, Flutter, screenshot, and runtime validation were intentionally not run
because Wave 6.1 changed only markdown docs.

## 11. Score Delta Proposal

Default proposal:

- Architecture scalability: `+0.3`
- Full 36-world readiness: `+0.1` maximum
- Overall top-1 readiness: `+0.1` maximum

Rationale: Wave 6.1 improves the content factory foundation and reduces future
schema rework risk. It does not migrate content, add validators, prove
coverage, open W7-W12, improve poker correctness, or prove learning transfer,
so content depth and learning-effect scores should not move materially yet.

## 12. Remaining Work

Recommended next step: Wave 6.2 validator/checker foundation.

Wave 6.2 should implement the validator list from
`docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`:

- required field presence;
- ASCII and ID-format checks;
- route/content title and owner alignment;
- `source_truth_status` and `route_gate_status` enum checks;
- preview-only exclusion;
- decision-rep `concept_family_id` requirement;
- repairable-rep `repair_focus_id` requirement;
- same-signal threshold;
- transfer threshold;
- misconception/correction path requirement;
- validation-status checks;
- W7-W12 locked/non-routed route-gate enforcement.

Only after that validator exists should a tiny non-runtime fixture or one W1
session migration be considered.
