# Review Mistake-History Unresolved Projection v1

## 1. Verdict

`review_history_projection_data_only_ready`

The bounded unresolved mistake-history projection exists as a pure data
contract. It is not wired into Review, the Act0 shell, or persisted progress in
this wave.

## 2. Contract implemented

Implemented:

- `Act0ReviewMistakeRecordV1`;
- `Act0ReviewMistakeHistoryV1`;
- projection from `Act0CompletedDecisionV1`;
- strict unresolved-only state;
- deterministic repeated-attempt deduplication;
- newest-first max-200 retention;
- serializer/parser round-trip;
- malformed and non-v1 state rejection.

Not implemented:

- Review backlog UI;
- snapshot/write-path integration;
- active-repair UI deduplication;
- fixed, cleared, resolved, hidden, or dismissed state;
- Practice, Profile, or Home consumption.

## 3. Owner and source map

| Concern | Owner |
| --- | --- |
| Normalized source decision | `Act0CompletedDecisionV1` |
| Current actionable repair | `Act0RepairIntentV1` |
| Unresolved history projection | `Act0ReviewMistakeHistoryV1` |
| Individual unresolved record | `Act0ReviewMistakeRecordV1` |
| Review UI | Not admitted |
| Persistence/write integration | Not admitted in this wave |

The projection imports only the completed-decision contract and `dart:convert`.
It does not import Flutter, Review widgets, `Act0ReviewStateV1`, or
`Act0MistakeCardV1`.

## 4. Data model/schema

Each record stores:

- schema version;
- deterministic record id;
- latest source decision / attempt key;
- first and latest stable sequence;
- world and lesson;
- decision task and original source task;
- decision kind;
- selected and expected answer ids;
- incorrect or suboptimal result kind;
- optional error type, skill atom, and repair focus;
- optional run id, run kind, and run ordinal;
- all deduplicated source attempt ids;
- fallback-key marker;
- state fixed to `unresolved_only_v1`.

Correct decisions and incomplete decision payloads are excluded.

The projection stores identifiers and facts only. It adds no learner-facing
labels, explanations, ranking, or capability claims.

## 5. Retention behavior

- `Act0ReviewMistakeHistoryV1.maxRecords == 200`.
- Records are stored newest first.
- Primary ordering is descending `updatedOrder`.
- Stable tie-break is `recordId`.
- Retention runs after repeated attempts have been coalesced.
- The oldest distinct records are removed when the collection exceeds 200.
- No wall-clock or lifetime-history claim is introduced.

## 6. Deduplication behavior

The deterministic mistake identity uses:

- source task id, falling back to decision task id;
- repair focus id, falling back to missed signal id;
- skill atom id;
- error type.

Each component is length-prefixed in the record id to avoid separator
ambiguity.

Repeated non-correct attempts with the same identity:

- update one record;
- preserve the first `createdOrder`;
- advance `updatedOrder`;
- replace latest selected/result/run facts;
- append the new attempt key once.

An identical attempt key is idempotent and returns the same history instance.

If repair-focus, skill, or error identity is missing, the source-task fallback
still provides deterministic behavior and the record marks
`dedupUsesFallback == true`. Collision risk remains: multiple conceptually
different mistakes on one source task can coalesce when all distinguishing
fields are absent. Future consumers must treat that record as a bounded source
mistake, not a proven error taxonomy.

## 7. Active repair boundary

`Act0RepairIntentV1` remains the sole owner of current actionable repair.

The new history:

- does not import or mutate repair intents;
- does not create repair targets;
- does not replace open repair persistence;
- does not route Home, Practice, or Review;
- does not suppress records for UI.

A focused test proves projection append leaves an existing repair-intent
payload unchanged.

Future Review UI must compare the historical source identity with the active
repair intent and present the active item only once. That UI deduplication is
not implemented here.

## 8. Resolution-state boundary

The only admitted state is:

`unresolved_only_v1`

The parser rejects any other state. The serializer has no fixed/cleared
resolution fields, and correct decisions do not mutate or remove historical
records.

Therefore this projection cannot support:

- fixed;
- resolved;
- cleared;
- mastered;
- clear/dismiss actions;
- clearable backlog UI.

## 9. Consumer admission status

No consumer is admitted in this PR.

The first possible consumer remains Review read-only unresolved history, but it
must wait for:

1. shell-owned write/persistence integration;
2. restore and migration proof;
3. active repair overlap projection;
4. a separate Review UI admission.

Practice repair queue, Profile capability evidence, and Home history
consumption remain forbidden.

## 10. Tests / validation

Focused tests cover:

- non-correct completed decisions included;
- correct decisions excluded;
- incomplete/non-mistake decisions rejected by the projection;
- deterministic repeated-attempt coalescing;
- stable fallback key behavior;
- newest-first max-200 retention;
- every state remains `unresolved_only_v1`;
- serializer/parser round-trip;
- malformed and resolved-state parsing rejection;
- active repair intent remains unchanged;
- no direct Flutter or Review UI dependency.

Validation:

- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart`;
- `graphify hook-check`;
- `flutter analyze`;
- touched-file `dart format --set-exit-if-changed`;
- `git diff --check`;
- `git status --short`.

## 11. Next recommended PR

`Review Mistake-History Persistence/Write Integration v1 — Data Only`

Attach the projection to the existing completed-decision append and Act0
snapshot lifecycle. Add migration/restore tests and a read-only active-intent
overlap projection. Do not render Review history or add any clear/fixed state.
