# Act0 Learning Evidence Write-Path Proof v1

## 1. Verdict

`documentation_only_write_path_blocked`

No single active Act0 callback currently has all required facts for every
completed decision. Persisting only action-list decisions would create a
partial history; unifying action-list and seat-choice flows is broader than
this write-path proof.

## 2. Write owner map

| Decision path | Current owner | Available at shell write point | Gap |
| --- | --- | --- | --- |
| Action-list choice | Runner option telemetry then `onChooseOption` | Option, correctness, feedback signal, and repair-capable state. | Decision-time bucket remains local to the runner. |
| Seat choice | Seat prompt calls `onChooseSeat` with a seat id | Shell can resolve an option and record repair state. | It bypasses runner option telemetry and has no decision-time bucket. |
| Sizing confirmation | Existing shell confirmation path | Shell owns selected preset/result flow. | Not normalized to the same completed-decision evidence callback. |
| Persistence | `_Act0PersistedProgressV1` | Safe local snapshot serializer and migration owner. | No evidence-list field or write integration yet. |

## 3. Evidence fields proven available

For action-list decisions, the runner knows selected option, correctness,
feedback signal, and its `decisionTimeBucket`. The shell can derive source
world/lesson/task, expected choice, repair intent, missed signal, skill atom,
and result state. For seat choices, all but the runner-owned time bucket can be
derived at the shell.

## 4. Snapshot / storage compatibility

`_Act0PersistedProgressV1` is suitable for a future bounded evidence field:
it already has schema-versioned JSON parsing, defensive defaults, and a single
`SharedPreferences` write path. Old snapshots can safely default an absent
evidence list to empty. This wave intentionally does not change its schema.

## 5. Duplicate / idempotency decision

A safe record requires a stable completion-event key, not just task and choice
identity: legitimate retries can select the same choice again, while duplicate
callbacks must not append twice. The current split callbacks do not expose one
shared attempt ordinal or completion key. Generating a sequence only in the
shell would not solve callback duplication before the two paths are unified.

## 6. Implemented tiny slice

No production write. The existing durable contract remains unchanged.

## 7. What Profile can now / cannot claim

No new Profile claim is allowed. It still cannot state accuracy trends,
strength rankings, historical mistake counts, or last-N evidence.

## 8. What Review can now / cannot claim

Review continues to own current open-repair context only. It cannot claim a
durable complete mistake backlog.

## 9. What Session Summary can now / cannot claim

Current lesson-run summary data remains valid. It cannot become a durable
cross-session decision-history summary.

## 10. Telemetry compatibility

No telemetry schema changes are needed or made. The blocker is internal data
handoff: the active decision-time bucket is calculated in the runner but not
carried through the full set of completed-decision callbacks.

## 11. Boundary proof

- No evidence write, snapshot-schema change, UI, route, progression, content,
  Modern Table, W11/W12, W13+, premium, ML, or AI change.
- No partial history is persisted.

## 12. Tests / validation

- Existing durable evidence contract tests.
- Existing repair intent, rule-based decision, resolver, and feedback-rhythm
  tests.
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review.

## 13. Next recommended wave

`Act0 Completed Decision Callback Contract v1`.

First define one internal, non-telemetry callback payload for action-list,
seat, and sizing decisions. It must carry completed option identity and the
existing decision-time bucket or an explicit unavailable value, plus a stable
attempt key. Only after that contract is proven should the durable evidence
write path be reopened.
