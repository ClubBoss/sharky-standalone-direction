# Session Summary Evidence Grouping Contract v1

## 1. Verdict

`session_grouping_contract_only_ready`

The repository now has a stable contract shape for grouping learning-evidence
records by a session/run key and summarizing one grouped run. Production writes
do not attach run keys yet, so no visible Session Summary consumer is admitted
in this wave.

## 2. Session/run owner map

| Area | Current owner | Contract decision |
| --- | --- | --- |
| Lesson-run state | `Act0ShellPreviewScreenV1` lesson-run sets and counters | Owns current in-memory run boundaries today. |
| Completed decision facts | `Act0LessonRunnerShellV1` -> `Act0CompletedDecisionV1` | Remains the sole append input. |
| Durable evidence record | `Act0LearningEvidenceRecordV1` | Can now carry optional run identity fields. |
| Durable evidence history | `Act0LearningEvidenceHistoryV1` | Can query by run id and summarize latest grouped run. |
| Visible Session Summary | Not admitted | Needs production write-path grouping first. |

## 3. Grouping key decision

`Act0EvidenceRunKeyV1` defines the stable non-telemetry grouping shape:

- `runId`;
- `worldId`;
- `lessonId`;
- `runOrdinal`;
- `runKind`;
- `startedBy`;
- `schemaVersion`.

The key is local, deterministic, and independent of telemetry event ids or
user-facing copy.

## 4. Run start/end decision

Contract-only decision:

- A future Act0 evidence run should start when the shell starts a concrete
  lesson/practice/repair run.
- It should end when that run completes, exits, or is replaced by another run.
- The implementation should use a shell-owned deterministic ordinal, not wall
  clock time.

This wave does not wire that lifecycle into production writes because repair
and practice launches still need explicit owner confirmation.

## 5. Repair attempt grouping decision

Repair attempts can belong to the same run only when the shell explicitly keeps
them inside the same active lesson/practice/repair context. If a repair is
launched later from Home, Review, or Practice, it should receive its own run key
unless a future contract deliberately links it to the source run.

## 6. Snapshot compatibility

Existing evidence records without run fields remain parse-safe. Their
`runId`, `runKind`, `sourceWorldId`, and `sourceLessonId` default to empty and
`runOrdinal` defaults to null.

Old records are not retroactively grouped. They are excluded from run queries
and cannot support "this session" claims.

## 7. Query/summarization contract

`Act0LearningEvidenceHistoryV1` now supports:

- `byRunId(runId)`;
- `latestRunRecords()`;
- `latestRunSummary()`.

The summary includes:

- spots played;
- correct count;
- incorrect count;
- distinct error types;
- top repair focus id;
- `currentSessionOnly`.

The query returns a current-session-only summary only for records that already
carry a non-empty run id.

## 8. Implemented tiny slice, if any

Implemented contract-only:

- optional grouping fields on durable evidence records;
- stable run-key DTO;
- latest grouped-run query helpers;
- focused grouping/query tests.

Not implemented:

- production run-key assignment;
- visible Session Summary UI;
- Profile, Review, Practice, or Home consumers.

## 9. What Session Summary can now/cannot claim

Can claim in tests/contract proof:

- facts about one explicitly grouped run.

Cannot claim in product UI yet:

- "this session";
- "your last session";
- trend, mastery, leak, GTO, solver, AI, or long-term improvement;
- anything from ungrouped old records.

## 10. What Profile/Review/Practice still cannot claim

Profile still cannot claim strength ranking, mastery, long-term trend, or
identity-level personalization from durable evidence.

Review still cannot claim a complete durable mistake-history backlog without a
Review-history taxonomy and open/resolved ownership.

Practice still cannot recommend drills from durable evidence without a routing
contract that maps repair focus or skill atom to a launchable target.

## 11. Telemetry compatibility

No telemetry event, payload, schema, event id, or timing convention changed.
The run key is explicitly non-telemetry identity.

## 12. Route/progression boundary proof

No route, progression, W11/W12 activation, W13+ state, content, glossary,
Modern Table, premium, visible UI, or generated output changed.

## 13. Baseline residue, if observed

The known `act0_telemetry_sink_v1_test.dart:565` failure remains baseline
residue and was not touched by this contract.

## 14. Tests / validation

Validation covers:

- focused grouping/query tests;
- durable evidence write-path tests;
- completed-decision callback/evidence-facts tests;
- repair intent / rule-based decision / resolver tests;
- feedback rhythm tests;
- affected snapshot/progress tests;
- `graphify hook-check`;
- `flutter analyze`;
- `git diff --check`;
- `git status --short`.

## 15. Next recommended wave

`Session Summary Evidence Write Grouping v1`

Attach `Act0EvidenceRunKeyV1` to new evidence records at the shell-owned
lesson/practice/repair run boundary. Keep UI closed until grouped production
records are proven by snapshot and query tests.
