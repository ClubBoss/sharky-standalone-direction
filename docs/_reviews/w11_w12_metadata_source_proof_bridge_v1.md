---
status: "w11_w12_metadata_source_proof_bridge_complete"
status_source: "derived"
baseline: "fed0c4caf7d5"
generated_by: "docs_frontmatter_v1"
---

# W11-W12 Metadata Source-Proof Bridge v1

## Verdict

`w11_w12_metadata_source_proof_bridge_complete`

## Previous source-proof gap

W11 and W12 already had live Act0 owners, deterministic packet reps, campaign
fixtures, route-proof descriptors, and admitted campaign packs. The active
content roots did not expose one validator-readable inventory connecting those
stable-ID families. General drill-root validation therefore omitted W11/W12,
while copying the learner content into drill JSON would have created a second
source of truth.

## Chosen metadata surface and schema

Each active world root now owns one `source_proof_manifest_v1.json`. The
manifest follows the existing active-content manifest convention of explicit
IDs and paths, but is classified as `metadata_only_source_proof` rather than a
drill runtime source. Each world index links its manifest.

The schema records only:

- canonical and packet world IDs
- existing Act0 owner symbol and runtime source path
- existing lesson/task IDs grouped by lesson
- existing packet and campaign fixture paths
- existing packet rep IDs and campaign pack IDs
- existing route-proof ID and source path
- repair, transfer, and review coverage IDs
- explicit existing-owner and no-duplication flags

It contains no prompt, choice, answer, feedback, visible-state, board-context,
title, subtitle, or learning-purpose body.

## W11 mapping matrix

| Surface | Stable IDs / ownership |
| --- | --- |
| Live owner | `_realPlayTransferLessons` |
| Active source root | `content/worlds/world11/v1` |
| Lesson `session_plan_basics` | `w11_session_plan_intro`, `w11_plan_focus_choice`, `w11_plan_avoid_overload`, `w11_plan_table_focus_transfer`, `w11_session_plan_recap` |
| Lesson `table_trigger_reads` | `w11_trigger_intro`, `w11_trigger_overfold_blinds`, `w11_trigger_overcall_flop`, `w11_trigger_small_price_continue`, `w11_trigger_bad_price_fold`, `w11_trigger_recap` |
| Lesson `post_session_review_loop` | `w11_review_loop_intro`, `w11_review_pick_leak`, `w11_review_define_fix`, `w11_review_loop_recap` |
| Lesson `real_play_transfer_checkpoint` | `w11_checkpoint_intro`, `w11_checkpoint_plan_line`, `w11_checkpoint_trigger_line`, `w11_checkpoint_review_line`, `w11_checkpoint_mixed_table_line`, `w11_checkpoint_review` |
| Packet reps | `w11.s01.r01` through `w11.s01.r06` |
| Campaign packs | `world11_spine_campaign_v1`, `world11_spine_followup_v1_b0`, `world11_spine_followup_v1_b1`, `world11_spine_followup_v1_b2` |
| Repair proof | Six existing Act0 repair/review IDs plus all six packet reps with existing `repair_cue` fields |
| Transfer proof | Five existing Act0 `taskFamily: transfer` IDs plus the existing transfer packet reps |
| Review proof | Four existing Act0 review-phase IDs plus the existing packet reps |

## W12 mapping matrix

| Surface | Stable IDs / ownership |
| --- | --- |
| Live owner | `_mindsetBridgeLessons` |
| Active source root | `content/worlds/world12/v1` |
| Lesson `decision_over_outcome` | `w12_decision_quality_intro`, `w12_good_fold_bad_result`, `w12_bad_call_good_result`, `w12_decision_quality_recap` |
| Lesson `tilt_reset_protocol` | `w12_tilt_reset_intro`, `w12_after_bad_beat_reset`, `w12_after_mistake_reset`, `w12_tilt_reset_recap` |
| Lesson `confidence_and_discipline` | `w12_confidence_intro`, `w12_assertive_not_ego`, `w12_discipline_under_pressure`, `w12_pretty_hand_bad_price_fold`, `w12_revenge_raise_trap`, `w12_confidence_recap` |
| Lesson `mindset_bridge_checkpoint` | `w12_checkpoint_intro`, `w12_checkpoint_process_line`, `w12_checkpoint_reset_line`, `w12_checkpoint_discipline_line`, `w12_checkpoint_full_loop_line`, `w12_checkpoint_review` |
| Packet reps | `w12.s01.r01` through `w12.s01.r06` |
| Campaign packs | `world12_spine_campaign_v1`, `world12_spine_followup_v1_b0`, `world12_spine_followup_v1_b1`, `world12_spine_followup_v1_b2` |
| Repair proof | Six existing Act0 reset/review IDs plus all six packet reps with existing `repair_cue` fields |
| Transfer proof | Seven existing Act0 `taskFamily: transfer` IDs plus the existing packet reps |
| Review proof | Four existing Act0 review-phase IDs plus the existing packet reps |

## Validator change

Validator change required: yes.

`tools/validate_w11_w12_source_proof_v1.dart` is a narrow W11/W12 resolver. It
does not alter the W0-W10 drill validator. It checks:

- manifest classification and expected active-root ownership
- exact Act0 owner, lesson, and task IDs
- exact transfer/review task classifications in the existing Dart owner lists
- locked and non-selectable W11/W12 world-card state
- exact packet and fixture rep IDs
- non-empty existing packet repair cues
- exact campaign-pack registry membership
- route-proof ID reachability
- index reachability
- coverage references and stable-ID syntax
- absence of learner-copy fields and W13 campaign registration

## Runtime byte-identity and behavior preservation

`lib/ui_v2/act0_shell/act0_shell_state_v1.dart` was not edited. Its working
blob and branch-base blob both hash to
`fed0c4caf7d5e26b0d9f140aca6413dc228b9efd`.

No route, mapper, progress, telemetry, content prompt, answer, feedback,
fixture, campaign registry, or runtime owner file changed. W11 remains bound to
`_realPlayTransferLessons`; W12 remains bound to `_mindsetBridgeLessons`.

## Second-source-of-truth avoidance

The manifests reference existing sources and stable IDs only. They contain no
learner-facing content bodies and are explicitly classified as metadata-only.
The validator rejects learner-copy keys, and no `sessions/**/drills/*.json`
files were added.

## Negative-control behavior

The focused test mutates temporary manifest copies and proves deterministic
failure for:

- an unresolved Act0 task ID
- an unresolved packet rep ID
- an unresolved campaign pack ID
- a forbidden `learner_prompt` metadata key

The production manifests still resolve exactly 4 lessons / 21 tasks / 6 reps /
4 packs for W11 and 4 lessons / 20 tasks / 6 reps / 4 packs for W12.

## Files changed

Metadata and validator:

- `content/worlds/world11/v1/index.md`
- `content/worlds/world11/v1/source_proof_manifest_v1.json`
- `content/worlds/world12/v1/index.md`
- `content/worlds/world12/v1/source_proof_manifest_v1.json`
- `tools/validate_w11_w12_source_proof_v1.dart`

Test:

- `test/guards/w11_active_source_draft_contract_test.dart`
- `test/tools/w11_w12_source_proof_validator_v1_test.dart`

Documentation:

- `docs/_reviews/w11_w12_metadata_source_proof_bridge_v1.md`

## Tests and validation

- Focused W11/W12 metadata/source-proof validator test.
- Existing W11 source guard aligned to the already-admitted W12 registry set.
- Direct W11/W12 source-proof validator run.
- Existing focused W11/W12 route/source/proof guards.
- Representative W0-W10 world-content validator regression.
- Focused W7-W12 lock-state guards.
- W12/W13 closure guard.
- `flutter analyze` because a Dart validator was added.
- `git diff --check`.
- `graphify hook-check`.
- Changed-file and forbidden-scope inspection.

## Lock-state and W13+ closure proof

The validator resolves the unchanged W11/W12 world cards and requires
`Act0WorldStateV1.locked`, `isSelectable: false`, and `isLocked: true` for both.
Existing lock-state guards remain the route authority. The campaign registry
still has no `world13_` pack, and the existing W12 closure guard remains green.

## Explicit non-goals

- no learner content authoring or duplicated copy
- no runtime lesson-owner, task-order, stable-ID, or behavior change
- no route, mapper, progress, telemetry, or lock-state change
- no W0-W10 content or validator change
- no W4-W7 or W13+ change
- no visual, mascot, Modern Table, screenshot, monetization, or localization work
- no generated output or archive change
- no dependency change
- no push
