# Durable Act0 Learning Evidence Write Path v1

## 1. Verdict

`durable_evidence_write_path_ready`

## 2. Write owner map

`Act0LessonRunnerShellV1` emits a complete `Act0CompletedDecisionV1`.
`Act0ShellPreviewScreenV1` is the only active consumer and appends it to the
existing `_Act0PersistedProgressV1` snapshot.

## 3. Idempotency policy

`attemptKey` is the durable record ID. If the same completion is delivered
again, `Act0LearningEvidenceHistoryV1.appendCompletedDecision` returns the
existing history unchanged. A new runner-owned ordinal represents a distinct
attempt.

## 4. Snapshot compatibility

Snapshot schema 11 adds `learningEvidenceHistory`. Versions 1 through 10
remain accepted and parse the absent field as an empty history. Existing
progress, skills, retention memory, and repair intents retain their current
serializer ownership.

## 5. Evidence serialization

History serializes through the existing record payload format. The converter
accepts only fact-complete callback payloads; missing immutable fields skip the
append rather than re-derive data from shell or UI state. `unknown` timing is
valid only when the runner reports no active timing interval.

## 6. Implemented write path

The callback handler appends the normalized decision to in-memory history and
persists the unchanged progress snapshot shape plus evidence history. Retention
is bounded by the existing `maxRecords = 200` rule.

## 7. What Profile can now / cannot claim

No Profile consumer exists. Profile cannot claim trends, rankings, history, or
mastery from this storage.

## 8. What Review can now / cannot claim

No Review consumer exists. Review remains limited to its active repair context.

## 9. What Session Summary can now / cannot claim

No session-summary consumer exists. Existing session feedback is unchanged.

## 10. Telemetry compatibility

No telemetry event, field, schema, or timing convention changed.

## 11. Boundary proof

No visible UI, route, progression, repair policy, content, Modern Table,
W11/W12/W13, premium, or generated output changed.

## 12. Baseline residue

The known repair-flow telemetry test remains baseline residue when reproduced
on clean `0f62fd2b`; this write path does not change its telemetry seam.

## 13. Tests / validation

Focused conversion, idempotency, bound, callback, old-snapshot, and
evidence-round-trip tests cover the new persistence boundary alongside existing
repair and feedback contracts.

## 14. Next recommended wave

`Act0 Learning Evidence Consumer Admission Audit v1`: decide whether a
bounded, truthful consumer is justified before exposing any learner-facing
evidence claim.
