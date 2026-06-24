# Durable Act0 Learning Evidence Persistence Contract v1

## 1. Verdict

`durable_evidence_contract_only_ready`

The active Act0 progress snapshot is the eventual local persistence owner, but
this wave adds only the evidence contract and deterministic query boundary. It
does not write history from the runner yet.

## 2. Persistence owner map

| Concern | Existing owner | Decision |
| --- | --- | --- |
| Progress snapshot | `_Act0PersistedProgressV1` in the active preview shell | Future storage integration owner. |
| Local storage | `SharedPreferences` through the existing progress snapshot | Reuse later; no new store now. |
| Current decision | `Act0LessonRunnerShellV1` / selected option | Write seam is not complete because its decision-time bucket is not passed to the parent outcome callback. |
| Repair identity | `Act0RepairIntentV1` | Existing source of missed signal, skill atom, error type, and target identity. |
| Current lesson outcome | `Act0BlockCompletionSummaryV1` and lesson-run collections | Current-run summary only; not durable decision history. |

## 3. Minimal durable evidence contract

`Act0LearningEvidenceRecordV1` stores evidence only:

- deterministic `recordId` and `createdOrder`;
- world, lesson, task, selected choice, and expected choice;
- correctness, result kind, and error type;
- optional repair-focus id and required skill atom;
- active Act0 decision-time bucket;
- schema version.

It contains no learner-facing interpretation, ranking, leak, mastery, AI, or
commerce field.

`Act0LearningEvidenceHistoryV1` provides bounded ordered retention and small
read helpers: `lastN`, `bySkillAtom`, `byRepairFocus`, and `mistakes`.

## 4. Serialization / storage decision

Records serialize to safe maps. The history supports storage-string encoding
and defensive parsing, dropping malformed records and retaining at most 200
ordered records. No production persistence key or `_Act0PersistedProgressV1`
schema change was made.

## 5. Query contract decision

The contract supports future read-path proof without authorizing UI:

- latest N records in chronological order;
- records for one skill atom;
- records for one repair focus;
- incorrect/suboptimal records.

Interpretation such as accuracy, ranking, trend, or strength remains a later
consumer decision with its own evidence rules.

## 6. Implemented tiny slice

Contract-only:

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- focused serialization, malformed-input, ordering, query, and retention tests.

No Act0 runner writes, progress-snapshot writes, or UI reads are added.

## 7. What Profile can now / cannot claim

Nothing new is rendered. A future Profile can use this contract only after a
separate write-path proof persists active decisions. It still cannot claim
strengths, accuracy trends, or last-N evidence today.

## 8. What Review can now / cannot claim

Nothing new is rendered. Review continues to own current open-repair context,
not a durable mistake-history backlog.

## 9. What Session Summary can now / cannot claim

Current lesson-run summaries remain valid. The new contract does not create a
durable session-history claim or change any visible summary.

## 10. Telemetry compatibility

The model mirrors existing safe Act0 evidence fields without changing telemetry
schema. It stores a decision-time bucket only; it does not invent raw timing.

## 11. Determinism / migration notes

- `createdOrder` is explicit; no wall-clock timestamp is required.
- No prior history is interpreted as empty history.
- Parsing rejects malformed records and ignores unknown/malformed entries.
- Future snapshot integration must version its own storage payload and preserve
  current progress migration behavior.

## 12. Boundary proof

- No persistence write path, Profile/Review/Summary UI, route, progression,
  telemetry schema, W11/W12, W13+, content, Modern Table, premium, ML, or AI
  change.
- No user-facing claim is introduced.

## 13. Tests / validation

- Focused durable evidence contract tests.
- Existing repair intent, rule-based repair decision, resolver, and feedback
  rhythm tests.
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review.

## 14. Next recommended wave

`Act0 Learning Evidence Write-Path Proof v1` only if the runner-to-shell
callback can carry the existing decision-time bucket without a telemetry or
route rewrite. That wave should append one evidence record per completed Act0
decision to the existing progress snapshot, with no visible UI.
