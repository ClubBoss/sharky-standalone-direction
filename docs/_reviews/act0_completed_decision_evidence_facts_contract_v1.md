# Act0 Completed Decision Evidence Facts Contract v1

## 1. Verdict

`completed_decision_evidence_facts_ready`

## 2. Previous write-path blocker

The completed-decision callback had identity, outcome, and timing, but not the
stable repair facts required by the durable evidence record.

## 3. Evidence facts added to completed-decision DTO

`resultKind`, `errorType`, `skillAtomId`, `repairFocusId`, and
`missedSignalId` are now internal fact-only fields.

## 4. Field ownership map

The runner derives result facts from the selected option quality and derives
skill/signal facts through `act0FirstValueSkillReceiptForRunnerV1`. No UI copy
or mutable shell state is used.

## 5-7. Decision support

Action-list, seat, and sizing completions use the same runner emission helper
after their option identity has resolved.

## 8. Why durable write path remains closed

This wave changes no snapshot field or persistence call. A later write-path
wave must explicitly adopt this DTO as its sole append input.

## 9-10. Compatibility and boundary proof

Telemetry payloads are unchanged. No UI, route, progression, repair policy,
persistence, content, Modern Table, or learner-facing claim changed.

## 11. Tests / validation

Focused callback evidence-fact tests cover action-list, seat, and sizing.

## 12. Next recommended wave

`Durable Act0 Learning Evidence Write Path v1`.
