# Act0 Completed Decision Callback Contract v1

## 1. Verdict

`completed_decision_callback_ready`

## 2. Decision owner map

`Act0LessonRunnerShellV1` now normalizes action-list, seat, and sizing
completion before forwarding their existing parent callbacks. The preview shell
continues to own repair intent, answer recording, progression, and feedback.

## 3. Action-list support

`_handleChooseOptionTelemetry` emits an `Act0CompletedDecisionV1` before its
unchanged telemetry and `onChooseOption` behavior.

## 4. Seat-decision support

`_handleChooseSeat` resolves the selected seat id against the runner options,
emits the completed decision when it resolves, then forwards the unchanged
seat-id callback to the shell.

## 5. Sizing-decision support

`_handleConfirmSizingPreset` resolves the selected preset id against runner
options, emits the completed decision when it resolves, then forwards the
unchanged sizing-confirm callback.

## 6. Timing-bucket ownership

The runner retains timing ownership. The new callback uses the active task
interval directly: an immediate completion is `under_3s`; `unknown` is used
only when no active timing interval exists. Existing telemetry bucketing is
unchanged.

## 7. Attempt-key decision

The callback owns a per-task completion ordinal. Its attempt key is versioned
and contains world, lesson, task, decision kind, selected option, and ordinal.
It is independent of telemetry event keys.

## 8. Implemented tiny slice

Added the internal `Act0CompletedDecisionV1` DTO and optional runner callback.
It carries stable source, selection, expected-answer, outcome, family, timing,
and attempt identity. The DTO contains no learner-facing copy and no persistence
behavior.

## 9. Why evidence write path remains closed

No evidence history is written and no progress snapshot changes. A future
bounded write-path wave must explicitly select an idempotency and storage
policy using this normalized callback.

## 10. Telemetry compatibility

No telemetry event, field, or schema changed.

## 11. Boundary proof

No UI, route, progression, repair policy, persistence, Profile, Review,
Summary, Practice, content, Modern Table, W11/W12, or W13+ change.

## 12. Tests / validation

Focused callback tests cover action-list, seat, and sizing completion. Existing
evidence, repair, feedback, runner, and telemetry checks are run with this
wave.

## 13. Next recommended wave

`Act0 Learning Evidence Durable Write Path v1`, limited to consuming this
contract through a deliberately bounded, idempotent persistence seam.
