# Action sequence convergence v1

## Terminal verdict

Sequence Convergence is **CLOSED**. The source contract, canonical runner and
telemetry regressions, and real live-route raster packet pass without a
synthetic learner state.

## Contract

Baseline: `c3dc4056` sequence ownership and `d9c5ddcd` runner-control repair.
`Act0ShellPreviewScreenV1` remains the sole orchestration, completion, and
progression owner. `Act0ActionLearningSequenceV1` explicitly maps
`actions_theory` to `actions_check_drill`, with `missed_action_read` mapping
to same-task repair, successful repair to same-task recheck, and correct
initial/recheck results back to the existing shell completion path.

Table context is `related_read` under
`w1_action_words_no_bet_read_v1`; it makes no same-hand claim. Theory retains
its admitted `321.408 x 558` geometry and 12px gap; practice retains
`264.960 x 460` with zero decision/correct/wrong movement. Cross-task geometry
is intentionally different.

## Runner and telemetry

Each rendered surface has one real `act0_shell_runner_screen` root. Theory
uses its real Continue button. Practice preserves real option keys, and its
one real feedback Continue button retains both the continuation role and the
existing feedback-control identity. No hidden control or duplicate action was
introduced. Runner telemetry carries `sequenceId` and existing decision fields
(`correct`, `error_type`, `time_to_decision_ms`); preview-shell events record
repair entry, recheck entry, and one sequence completion.

## Validation and evidence

`act0_telemetry_sink_v1_test.dart`, task-presentation tests, and focused
analysis pass after `d9c5ddcd`. Source-derived traces are local-only under
`output/evidence/action_sequence_convergence_v1/`.

## Raster harness result

`test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart` mounts the
real `Act0ShellPreviewScreenV1` at 375x812 and writes local-only rasters plus
contact sheets. It proves theory at `321.408 x 558`, and Action decision,
correct feedback, and wrong feedback at `264.960 x 460` with stablePractice
selected and no overflow. From a real Action wrong-feedback state it drives
the actual feedback and option controls through same-task repair, repair
success, same-task recheck, recheck success, shell completion, and next
rendered state. `actions_legal_context` repair captures are excluded from this
sequence proof.

## Residual risk and rollback

Residual debt is limited to visible-content occupancy measurement for the
compact repair/recheck panels; the raster shows no clipping and reachable
controls, so it is non-blocking. Rollback is removal of the bounded sequence
contract and runner-control bridge commits. Human QA and public learning-effect
claims are not made. Next active layer: **Rule-based AI Personalization v1**.
