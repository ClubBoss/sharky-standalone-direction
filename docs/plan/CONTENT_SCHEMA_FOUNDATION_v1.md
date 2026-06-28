# Content Schema Foundation v1

Status: ACTIVE content schema foundation.
Created: 2026-06-28.

## 1. Purpose And Authority

This document defines the canonical authorable content schema foundation for
Sharky world, lesson, session, pack, task, chain, feedback, repair, coverage,
and route-truth metadata.

It is the schema authority for content production after Wave 6.1. It is
intended to sit below the active product SSOT chain and above individual
content files, fixtures, packs, and future validators.

Authority order:

1. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` defines the active SSOT
   hierarchy and active app boundary.
2. `docs/plan/MASTER_PLAN_v3.0.md` remains the day-to-day product execution
   authority.
3. `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` and
   `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` define the top-1
   route and content-factory ordering.
4. This document defines the canonical content schema vocabulary and minimum
   field contract for authorable content.
5. Individual world/session/task files must conform to this document before
   they can be counted as schema-normalized content.

Wave 6.1 does not migrate W1-W6 or author W5-W12. It locks the vocabulary and
minimum field contract required before scalable content production.

## 2. Non-Goals

This foundation does not:

- open W7-W12 for learner play;
- author or rewrite W5-W12 content;
- migrate W1-W6 content in bulk;
- define W13-W36 content;
- change runtime routing, Act0 shell behavior, UI, telemetry, monetization,
  paywalls, analytics, server behavior, dependencies, or Modern Table work;
- make poker-correctness claims for advanced W7+ advice;
- replace the active route truth, monetization SSOT, or Master Plan;
- count preview-only or filename-only content as coverage-ready;
- reorder or rename runtime enums.

## 3. Core Entity Model

| Entity | Definition | Schema responsibility |
| --- | --- | --- |
| World | A route-visible or planned curriculum world such as W1 or W7. | Owns `world_id`, `route_world_id`, `display_world_title`, `content_owner_world_id`, and route/content status. |
| Lesson | A learner-sized teaching unit within a world. | Owns `lesson_id` and groups sessions or packs under one learning promise. |
| Session / Pack | A runnable or authorable sequence of tasks. | Owns `session_id` and/or `pack_id`, route gate, preview status, and validation state. |
| Task / Drill | One decision rep, explanation rep, quiz, table action, or other content atom. | Owns `task_id`, action fields, feedback, concept fields, and source state. |
| Chain / Multi-step spot | A linked set of task steps that represent one multi-step poker situation. | Owns `chain_id` and `chain_step_id`; each step still carries task-level concept and validation fields. |
| Feedback | The reason, correction, reinforcement, or recap shown for a task or step. | Owns `feedback_reason` and may be keyed by `locale_key` or `copy_key`. |
| Concept family | The durable poker idea being trained, such as position, hand selection, or board texture. | Owns `concept_family_id`; required on every decision rep. |
| Repair focus | The specific misconception or behavior being fixed inside a concept family. | Owns `repair_focus_id`; required when a concept is repairable. |
| Same-signal group | A cluster of reps that train the same table signal with varied surface forms. | Owns `same_signal_group_id`; required when a same-signal coverage claim is made. |
| Transfer surface | The external or adjacent situation where the concept must transfer. | Owns `transfer_surface_id`; required when transfer is claimed. |
| Misconception | The named novice error that the task or feedback addresses. | Owns `misconception_id`; required when a task repairs or diagnoses an error. |
| Route gate | The product route state for a world, pack, session, or task. | Owns `route_gate_status` and blocks false playable claims. |
| Validation status | The evidence state for source quality, runtime behavior, and poker correctness. | Owns `validation_status` and blocks unsupported public claims. |

## 4. Required IDs And Fields

All schema-normalized task-like records must carry the following fields unless
the field is explicitly marked nullable for the record kind. A nullable field
must still appear with `null` when absent so validators can distinguish absent
data from intentionally not-applicable data.

| Field | Required for | Format / values | Purpose |
| --- | --- | --- | --- |
| `schema_version` | All records | Stable string, starting with `content_schema_foundation_v1` | Identifies the schema contract. |
| `world_id` | All records | `world_N` | Content file's declared world. |
| `route_world_id` | All routed or route-preview records | `world_N` | World shown in the learner route. |
| `display_world_title` | All world/session/task records | Human title from active route truth | Prevents title drift between content and route. |
| `content_owner_world_id` | All records | `world_N` | World that owns the source truth when route and content differ. |
| `route_gate_status` | All world/session/pack/task records | See section 5 | Blocks false learner-playable claims. |
| `lesson_id` | Lesson/session/task records | Stable dotted ID, for example `w1.l01` | Groups content under a learner lesson. |
| `session_id` | Session/task records | Stable dotted ID, for example `w1.s01` | Groups tasks into an authorable session. |
| `pack_id` | Pack/session/task records | Stable snake/digit ID | Connects content to packs without relying on filenames. |
| `task_id` | Task records | Stable dotted or snake/digit ID | Identifies one task or drill atom. |
| `chain_id` | Chain steps, nullable otherwise | Stable dotted or snake/digit ID, or `null` | Links multi-step spots. |
| `chain_step_id` | Chain steps, nullable otherwise | Stable step ID, or `null` | Orders a chain step. |
| `concept_family_id` | Every decision rep | Stable snake/digit ID | Enables coverage, repair, telemetry joins, and progression. |
| `repair_focus_id` | Repairable decision reps | Stable snake/digit ID, or `null` for non-repair reps | Names the exact fix target. |
| `same_signal_group_id` | Same-signal reps | Stable snake/digit ID, or `null` | Enables same-signal coverage threshold checks. |
| `transfer_surface_id` | Transfer reps | Stable snake/digit ID, or `null` | Enables transfer breadth checks. |
| `misconception_id` | Diagnostic or repair reps | Stable snake/digit ID, or `null` | Names the novice error being addressed. |
| `drill_kind` | Task records | Stable string, for example `action_choice`, `quiz`, `review`, `multi_step` | Identifies the task shape. |
| `correct_action` | Decision reps | Stable action string, object, or `null` for non-action reps | Defines the canonical correct response. |
| `acceptable_actions` | Decision reps | Array, possibly empty | Allows alternate accepted answers without weakening the canonical answer. |
| `feedback_reason` | Task records | String or copy reference | States the short why behind the answer. |
| `table_state` | Table decision reps | Object or `null` | Captures poker table facts. |
| `scenario_state` | Non-table or richer scenario reps | Object or `null` | Captures non-table or supplemental state. |
| `validation_status` | All records | See section 7 | Defines evidence and correctness posture. |
| `preview_only` | All records | Boolean | Excludes non-production reps from mastery and coverage. |
| `source_truth_status` | All records | See section 5 | Classifies canonical, bridge, preview, migrated, or blocked source truth. |
| `locale_key` | Localized copy records, nullable otherwise | Stable key or `null` | Joins localized copy without embedding it. |
| `copy_key` | Shared copy records, nullable otherwise | Stable key or `null` | Joins shared copy without duplicating it. |

ID format rule: new schema IDs should use lowercase ASCII letters, digits,
underscores, dots, and hyphens only. Spaces, slashes, Unicode punctuation, and
display titles are not valid IDs.

## 5. Route And Content Truth Fields

Route and content truth must be represented directly in schema fields rather
than inferred from paths, filenames, registry presence, or copy.

### Source truth status

`source_truth_status` values:

| Value | Meaning |
| --- | --- |
| `canonical` | This record is the active source truth for the declared owner and route state. |
| `bridge_or_legacy` | This record supports compatibility or migration but is not the final source shape. |
| `preview_only` | This record exists for preview, planning, or internal inspection only. |
| `migrated` | This record has been converted into the canonical schema and linked to prior source. |
| `blocked_conflict` | This record has unresolved conflict between route, content, ownership, or correctness claims. |

### Route gate status

`route_gate_status` values:

| Value | Meaning |
| --- | --- |
| `learner_playable` | The active route can serve this content to learners. |
| `locked_preview` | The content may be visible as locked preview but is not playable. |
| `internal_only` | The content may exist for authoring, tests, fixtures, or internal review only. |
| `authored_but_not_routed` | Source content exists but has no active learner route. |
| `planned_only` | The item is planned in the curriculum but not authored as playable content. |
| `blocked` | The item cannot be used until a conflict or validation blocker is resolved. |

Route and ownership fields:

- `world_id` is the world declared by the content record.
- `route_world_id` is the world shown by the active learner route.
- `content_owner_world_id` is the world that owns the source contract when
  content is shared, bridged, or carried for compatibility.
- `display_world_title` must match active route truth for the route world, not
  stale filenames or legacy titles.
- W7-W10 currently remain `locked_preview` or `internal_only` in learner-facing
  status, not `learner_playable`.
- W11-W12 currently remain `authored_but_not_routed` where source exists and
  `planned_only` where no source exists.

## 6. Coverage Rules

Coverage claims must come from schema fields and validator evidence, not from
filenames, folder counts, registry rows, or historical calibration language.

Rules:

- Every decision rep must carry `concept_family_id`.
- Repairable concepts must carry `repair_focus_id`.
- Same-signal coverage requires `same_signal_group_id`.
- Transfer coverage requires `transfer_surface_id`.
- `preview_only: true` reps do not count toward mastery, completion,
  coverage-ready, repair-ready, same-signal-ready, or transfer-ready claims.
- `coverage_ready` cannot be claimed only from filenames, pack IDs, or folder
  presence.
- A same-signal group needs at least 5 non-preview reps before it can become a
  `coverage_ready` candidate.
- A transfer claim requires at least 2 distinct non-preview
  `transfer_surface_id` values for the same concept family before it can become
  a transfer-ready candidate.
- A repair-ready claim for a concept family requires at least one
  non-preview rep with `repair_focus_id` and an explicit misconception or
  correction path.
- W7-W12 remain locked or non-routed unless a later route-admission artifact
  changes their route gate status.

Claim names such as `coverage_ready`, `same_signal_ready`, and
`transfer_ready` are validator outputs, not author-provided source fields.

## 7. Claim Safety And Poker Correctness

`validation_status` values:

| Value | Meaning |
| --- | --- |
| `draft` | Authored but not source-reviewed or runtime-reviewed. |
| `source_validated` | Required schema fields and source consistency have been validated. |
| `runtime_validated` | The app or runner has consumed the content as expected. |
| `poker_review_needed` | Poker correctness or advice quality needs expert/solver/protocol review. |
| `poker_reviewed` | Poker correctness review has been completed under the accepted protocol. |
| `blocked` | The record must not be claimed, routed, or counted until fixed. |

Advanced W7+ advice requires a later correctness protocol before public claims.
For W7+ content, `source_validated` and `runtime_validated` are not enough to
make public strategic correctness claims when the spot contains advanced poker
advice, tournament pressure, solver-sensitive concepts, or ambiguous EV lines.

Validation status is not linear. A record may be runtime-valid but still need
poker review before public use. Validators should report the strongest true
state and preserve blockers.

## 8. JSON Example

This example is docs-only. It is a minimal W1 task-shaped record showing the
required fields and the route/content truth posture. It does not migrate the
existing W1 source files.

```json
{
  "schema_version": "content_schema_foundation_v1",
  "world_id": "world_1",
  "route_world_id": "world_1",
  "display_world_title": "Poker from Zero",
  "content_owner_world_id": "world_1",
  "route_gate_status": "learner_playable",
  "lesson_id": "w1.l01",
  "session_id": "w1.s01",
  "pack_id": "world1_spine_campaign_v1",
  "task_id": "w1.s01.position_action_order.r01",
  "chain_id": null,
  "chain_step_id": null,
  "concept_family_id": "position_action_order",
  "repair_focus_id": "position_before_action",
  "same_signal_group_id": "w1.position_action_order.first_in_or_facing_pressure",
  "transfer_surface_id": "table_seat_action_order_v1",
  "misconception_id": "acts_without_reading_position",
  "drill_kind": "action_choice",
  "correct_action": "raise",
  "acceptable_actions": [],
  "feedback_reason": "Hero is on the button after folds, so position and first-in action support a simple raise.",
  "table_state": {
    "street": "preflop",
    "hero_position": "button",
    "players_remaining": 6,
    "action_before_hero": "folded_to_hero",
    "stack_depth_bb": 100
  },
  "scenario_state": null,
  "validation_status": "draft",
  "preview_only": false,
  "source_truth_status": "canonical",
  "locale_key": "w1_s01_position_action_order_r01",
  "copy_key": null
}
```

## 9. Tiny Pilot Decision

Wave 6.1 uses a docs-only pilot: the JSON example above is the pilot artifact.

Reason:

- Wave 5.3 found W1-W6 source/title/coverage drift and missing concept-family,
  repair, same-signal, and transfer fields.
- Creating runtime fixtures before the schema is accepted would risk another
  bridge format.
- The prompt permits a docs-only schema plus example JSON snippet when runtime
  or file churn is too large.
- No runtime consumer is needed to prove the schema vocabulary.

Future pilot work should be a separate Wave 6.2 or later validator/checker
wave. It should use one tiny non-runtime fixture only after the validator rules
below are accepted.

## 10. Wave 6.2 Handoff

Recommended Wave 6.2 validator list:

- Required field presence for all schema-normalized records.
- ASCII-only IDs and stable ID format.
- `world_id`, `route_world_id`, `content_owner_world_id`, and
  `display_world_title` route/content alignment.
- `source_truth_status` value enforcement.
- `route_gate_status` value enforcement.
- `preview_only: true` exclusion from mastery and coverage counts.
- Every decision rep has `concept_family_id`.
- Every repairable decision rep has `repair_focus_id`.
- Same-signal candidate threshold: at least 5 non-preview reps per
  `same_signal_group_id`.
- Transfer candidate threshold: at least 2 distinct non-preview
  `transfer_surface_id` values per concept family.
- `misconception_id` presence for diagnostic or repair reps.
- `validation_status` value enforcement and W7+ correctness warning.
- W7-W10 cannot validate as `learner_playable` under the current route truth.
- W11-W12 cannot validate as `learner_playable` under the current route truth.
- `coverage_ready` cannot be produced from filenames, folder counts, registry
  rows, or display copy alone.

## 11. Adoption Order

Recommended adoption order:

1. Keep this document as the accepted schema authority.
2. Build a docs/source validator against a tiny fixture or one isolated W1
   source sample.
3. Run the validator as advisory first.
4. Migrate one W1 session only after the validator proves field, ID, route,
   preview, same-signal, transfer, and repair checks.
5. Use the accepted validator before any W5-W12 authoring or W7-W12 route
   admission.
