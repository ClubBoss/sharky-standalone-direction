# Action sequence convergence v1

## Terminal verdict

The source contract and focused canonical runner/telemetry regressions pass.
Production admission is withheld because the required full live-route visual
capture/contact-sheet packet is not yet available; no synthetic images were
substituted.

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

## Residual risk and rollback

The remaining gate is visual evidence only: a real learner-route capture lane
must rasterize sequence entry through next progression and measure visible
feedback occupancy. Rollback is removal of the bounded sequence contract and
runner-control bridge commits. Human QA and public learning-effect claims are
not made.
