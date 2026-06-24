# Session Summary Evidence Write Grouping v1

## 1. Verdict

`session_grouping_write_path_ready`

New durable Act0 learning-evidence records now receive a shell-owned
`Act0EvidenceRunKeyV1` when the active shell has a clear lesson, practice, or
repair run boundary. No visible Session Summary UI or learner-facing evidence
claim was added.

## 2. Run boundary owner map

| Boundary | Owner | Decision |
| --- | --- | --- |
| Lesson route launch | `Act0ShellPreviewScreenV1._startTaskByIds` | Starts a `lesson` evidence run by default. |
| Practice launch | `Act0ShellPreviewScreenV1._startPracticeGroup` | Starts a `practice` evidence run. |
| Repair launch | `Act0ShellPreviewScreenV1._startMistakeRepair` | Starts a `repair` evidence run. |
| Completed decision | `Act0LessonRunnerShellV1` callback | Still emits fact-only decision data; it does not own run identity. |
| Durable append | `Act0ShellPreviewScreenV1._appendLearningEvidenceV1` | Attaches the active shell-owned run key. |

The shell is the correct run owner because it owns launch source, selected
world/lesson/task, practice group, repair source, and persistence.

## 3. Run key creation policy

Run keys are local, deterministic, and non-telemetry:

- `runId = run_v1|worldId|lessonId|runKind|runOrdinal`;
- `runOrdinal` is shell-owned and monotonic within the local evidence history;
- `runKind` is `lesson`, `practice`, or `repair`;
- `startedBy` records the internal launch source.

The runner DTO remains unchanged. Telemetry event keys are not reused.

## 4. Lesson/practice/repair grouping decision

Decisions inside one launched lesson run share the same run key.

Practice launches receive a distinct `practice` run key so they do not mix with
the parent lesson route.

Repair launches receive a distinct `repair` run key. Repair attempts do not
silently share the parent run because they can be entered from Home, Practice,
or Review and have separate ownership.

## 5. Evidence write attachment

`Act0LearningEvidenceHistoryV1.appendCompletedDecision` accepts an optional
`Act0EvidenceRunKeyV1`. The shell passes the active run key when appending the
completed decision.

Old or ungrouped append calls remain supported and produce parse-safe records
with empty run fields.

## 6. Query proof

The existing query helpers now work on production-written grouped records:

- `byRunId`;
- `latestRunRecords`;
- `latestRunSummary`.

Focused shell tests prove:

- two decisions in one lesson run share the same run id;
- a later practice launch creates a different run id;
- unit history append with a run key supports latest-run summary.

## 7. Snapshot compatibility

No snapshot schema bump was required. The persisted progress snapshot already
stores `learningEvidenceHistory` in schema 11. Record-level run fields are
optional, so old records without run identity remain parse-safe and excluded
from run queries.

## 8. What Session Summary can now/cannot claim

Can now claim in a future internal/visible consumer after scoped admission:

- facts from the latest grouped run;
- spots played in that run;
- correct and incorrect counts in that run;
- distinct error types in that run;
- top repair focus id in that run.

Still cannot claim:

- mastery;
- leak detection;
- long-term trend;
- strength ranking;
- solver/GTO comparison;
- AI personalization;
- anything from ungrouped old records.

## 9. What Profile/Review/Practice still cannot claim

Profile still cannot claim long-term identity, strength, weakness, trend, or
mastery from durable evidence.

Review still cannot claim a full durable mistake-history backlog without a
separate Review-history taxonomy and open/resolved policy.

Practice still cannot recommend drills from durable evidence without a routing
contract from repair focus / skill atom to a launchable target.

## 10. Telemetry compatibility

No telemetry event, payload, schema, event key, or timing convention changed.
Run keys are local evidence identity only.

## 11. Route/progression boundary proof

No visible UI, route, progression, W11/W12 activation, W13+ state, content,
glossary, Modern Table, premium, or generated output changed.

## 12. Baseline residue, if observed

The known `act0_telemetry_sink_v1_test.dart:565` failure remains baseline
residue and was not touched.

## 13. Tests / validation

Validation covers:

- focused evidence grouping/write tests;
- durable evidence write-path tests;
- completed-decision callback/evidence-facts tests;
- repair intent / rule-based decision / resolver tests;
- feedback rhythm tests;
- affected snapshot/progress tests;
- `graphify hook-check`;
- `flutter analyze`;
- `dart format --set-exit-if-changed`;
- `git diff --check`;
- `git status --short`.

## 14. Next recommended wave

`Session Summary Evidence Consumer Proof v1`

Add a non-visible or test-only Session Summary consumer proof that reads
`latestRunSummary` from grouped production evidence. Keep learner-facing UI
closed until the exact summary copy and placement are separately admitted.
