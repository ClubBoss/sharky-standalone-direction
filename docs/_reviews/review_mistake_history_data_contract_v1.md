# Review Mistake-History Data Contract v1

## 1. Verdict

`review_history_contract_docs_only_ready`

The Review mistake-history owner and unresolved-record contract are selected.
No UI or product behavior is admitted in this wave. A data-only implementation
PR is still required because current durable evidence does not retain the
original repair source task on mapped repairs and does not persist an explicit
resolution event.

## 2. Claude Post-Wave-2 finding addressed

The accepted post-Wave-2 direction ranks Review mistake history / clearable
backlog as the first Wave 3 family, with data ownership required before UI.
This audit resolves the owner, source event, schema, retention, deduplication,
consumer order, and claim boundary.

The selected direction is a bounded Review-history projection over durable Act0
learning evidence, coordinated with the existing open repair-intent owner. It
is not a broad redesign and does not open a clearable backlog yet.

## 3. Existing evidence/source audit

### Completed-decision source

`Act0CompletedDecisionV1` is the normalized fact emitted by the runner after an
action-list, seat, or sizing decision. It already carries:

- stable `attemptKey`;
- world, lesson, task, and `sourceTaskId`;
- decision kind;
- selected and expected ids;
- correct / incorrect truth;
- deterministic decision-time bucket;
- result kind;
- optional error type, skill atom, repair focus, and missed signal.

This is the correct source event for a mistake observation.

### Durable learning evidence

`Act0LearningEvidenceHistoryV1` is persisted in the Act0 progress snapshot and
already owns:

- append-only completed-decision facts;
- idempotency by stable attempt key;
- deterministic `createdOrder`;
- lesson / practice / repair run grouping;
- malformed-record rejection;
- compatibility with old ungrouped records;
- a bounded latest-200-record retention policy.

It is the source ledger for Review history, but it is not itself the Review
backlog model. Its records are decision facts and intentionally have no
learner-facing interpretation or open/resolved state.

Current evidence records also omit two fields needed for safe Review history:

- the completed decision's `sourceTaskId`;
- the completed decision kind.

For mapped repair runs, persisted `taskId` can identify the repair target rather
than the original mistake source. A future implementation must not guess that
link from UI state.

### Repair-intent persistence

`Act0RepairIntentV1` owns current actionable repair truth:

- source task and source signal;
- selected choice and error type;
- skill atom;
- mapped or exact repair target;
- mapping and reason codes.

Open intents are persisted and deduplicated by `sourceTaskId`. A matched correct
exact or mapped repair removes the intent. That makes repair intent the correct
active-job owner, but the wrong history owner: resolved intents disappear and
there is no durable closure record.

### Current Review inputs

`Act0ReviewStateV1.mistakes` and `fixedMistakes` are presentation inputs.
Production cards are currently projected from private shell-local
`_mistakeRecords`, `_resolvedMistakeTaskIds`, retention memory, and open repair
intents. The shell reconstructs only open mistake records from persisted repair
intents after relaunch.

These private presentation projections must not become the durable
mistake-history store.

## 4. Proposed data owner

Add a new bounded data contract:

`Act0ReviewMistakeHistoryV1`

Ownership rules:

- It belongs beside `Act0LearningEvidenceHistoryV1` in the Act0 learning
  evidence/data layer.
- It consumes normalized completed-decision facts; it does not scrape Review
  widgets or `Act0MistakeCardV1`.
- It coordinates with `Act0RepairIntentV1` only for active-item suppression and
  future explicit resolution linkage.
- It is persisted as local product data in the Act0 progress snapshot.
- It is not telemetry, route state, progression state, Profile evidence, or
  Practice queue state.

Rejected alternatives:

1. **Use repair intents as history:** rejected because intents represent only
   open actionable work and are removed after successful repair.
2. **Render durable evidence directly:** rejected because evidence is a raw
   decision ledger without Review taxonomy, resolution, or active-job
   deduplication.
3. **Use current Review card state:** rejected because it is presentation-owned,
   partly shell-local, and not a durable fact contract.

## 5. Proposed mistake record schema

Proposed record:

`Act0ReviewMistakeRecordV1`

Required fields:

| Field | Rule |
| --- | --- |
| `schemaVersion` | `1` |
| `mistakeId` | Stable id created from the canonical mistake key and first source record id. |
| `canonicalMistakeKey` | `sourceTaskId + repairFocusId + skillAtomId + errorType`, with deterministic empty-field handling. |
| `firstDecisionRecordId` | First durable evidence `recordId` / completed-decision attempt key. |
| `latestDecisionRecordId` | Latest deduplicated non-correct attempt key. |
| `createdOrder` | First source evidence order. |
| `updatedOrder` | Latest source evidence order. |
| `worldId` | Original source world. |
| `lessonId` | Original source lesson. |
| `decisionTaskId` | Task on which the recorded decision occurred. |
| `sourceTaskId` | Original repair source task; must be persisted from `Act0CompletedDecisionV1`. |
| `decisionKind` | `actionList`, `seat`, or `sizing`. |
| `selectedId` | Latest selected answer id. |
| `expectedId` | Expected answer id. |
| `resultKind` | `incorrect` or `suboptimal`; correct decisions do not create mistake records. |
| `errorType` | Existing normalized error type. |
| `skillAtomId` | Existing stable skill/concept atom. |
| `repairFocusId` | Existing repair-focus/signal id when available. |
| `runId` | Source lesson/practice/repair run id when available. |
| `runKind` | Source run kind when available. |
| `runOrdinal` | Stable source run ordering when available. |
| `attemptRecordIds` | Stable, deduplicated source record ids for this mistake key. |
| `resolutionState` | `unresolved_only_v1` in the first implementation. |
| `resolvedByRecordId` | Must be null in `unresolved_only_v1`. |
| `resolvedOrder` | Must be null in `unresolved_only_v1`. |

The contract stores ids and facts, not learner-facing titles, labels, rankings,
or generated explanations.

Source event admission:

- create or update a mistake record only from a complete
  `Act0CompletedDecisionV1` / durable evidence record with
  `resultKind == incorrect || resultKind == suboptimal`;
- do not create a mistake record from placement-only diagnostics unless they
  are already admitted into the same durable completed-decision path;
- do not create records from telemetry, widget state, summary copy, or inferred
  Profile state.

## 6. Retention and migration rules

Retention:

- maximum `200` Review mistake records;
- align with the current durable learning-evidence maximum instead of inventing
  a second time-based window;
- sort for storage by `updatedOrder`, then `mistakeId`;
- retain the latest 200 after deduplication;
- no lifetime-history claim;
- no wall-clock expiry in v1 because the source ledger owns stable order, not a
  durable timestamp.

Duplicate handling:

- identical source attempt keys append once;
- repeated non-correct attempts with the same canonical mistake key update one
  record;
- `attemptRecordIds` remains unique and deterministically ordered;
- the latest attempt updates `latestDecisionRecordId`, selected id, result kind,
  run identity, and `updatedOrder`;
- repeated attempts do not create multiple learner jobs.

Migration/parsing:

- reject unknown schema versions and malformed required fields;
- skip malformed entries rather than filling them from UI state;
- old snapshots without `reviewMistakeHistory` parse as an empty history;
- existing learning-evidence records remain untouched;
- pre-contract evidence may be projected only as
  `unresolved_only_v1`;
- old records without an explicit `sourceTaskId` may use `taskId` only as a
  marked legacy fallback for non-repair identity; they cannot support a fixed
  claim or mapped-repair resolution;
- old repair-run records without source linkage must not be guessed into a
  resolved chain.

## 7. Resolution / fixed-state semantics

The first implementation is:

`unresolved_only_v1`

Current durable evidence cannot safely prove resolution because:

- evidence records do not retain the original `sourceTaskId`;
- a correct record on a mapped repair target does not durably identify which
  source mistake it resolved;
- clearing an open repair intent removes active state but does not append a
  durable resolution event;
- retention-memory statuses are private shell state and can also represent
  later recheck/prove cadence, not a standalone mistake-history closure event.

Therefore v1 rules are:

- every admitted record remains `unresolved_only_v1`;
- no `fixed`, `resolved`, `cleared`, or `mastered` learner claim;
- a correct answer on the same skill or repair focus alone is insufficient;
- session-summary outcome alone is insufficient;
- an explicit future dismiss/clear action would mean hidden/dismissed, not
  fixed.

Future resolution admission requires a separate data-only contract that emits a
durable resolution marker when all are true:

1. the shell has a persisted source mistake id / source task id;
2. the completed task matches the exact or mapped target owned by the open
   repair intent;
3. the repair decision is correct;
4. the resolution marker stores the matching correct decision record id and
   deterministic order.

Only after that proof may a future state such as
`resolved_by_repair_v1` be admitted.

## 8. Deduplication with active repair

Active repair remains authoritative over the same historical mistake.

Required projection rules:

- build the same canonical mistake key from the history record and open repair
  intent;
- if an open intent matches, suppress that history record from the read-only
  backlog projection;
- keep the existing active repair context as the single actionable item;
- do not create a second Review backlog row for the same source task/signal;
- repeated attempts coalesce into the same mistake-history record;
- Home, Practice, and Review must consume the same open repair intent identity,
  not create three separate jobs;
- Practice repair queue remains closed and cannot copy Review history entries;
- when source-task linkage is uncertain, prefer suppression or omission over a
  duplicate learner job.

Priority/ranking is not admitted. Ordering is recency by deterministic
`updatedOrder`, not “biggest,” “worst,” or “most important.”

## 9. Consumer admission rules

First eligible consumer after the data-only projection is implemented and
tested:

- Review read-only unresolved history.

That future UI must be separately admitted. This contract alone does not permit
rendering it.

Consumer order:

1. Review read-only unresolved history.
2. Resolution/fixed-state data contract.
3. Optional clear/dismiss policy after fixed-state semantics are proven.
4. Practice repair queue only after Review ownership and launch mapping are
   proven.

Explicit exclusions:

- Practice cannot consume this store as a queue yet.
- Profile cannot consume this store for capability, weakness, identity, trend,
  or mastery claims.
- Home cannot create a second history consumer; it continues to own current
  next action through existing state.
- Session Summary continues to consume latest grouped-run evidence, not Review
  history.

## 10. Forbidden UI/claim rules

Until a later implementation and UI-admission wave, forbid:

- any Review mistake-history list;
- any clearable backlog;
- any clear, dismiss, archive, or bulk action;
- grouped mistake patterns or ranking;
- Practice repair queue;
- Profile cited-capability copy;
- counts presented as lifetime or complete history;
- `based on your last N decisions` unless the exact owned N/window is shown;
- `biggest leak`, `weakest area`, or equivalent ranking;
- `fixed`, `resolved`, or `cleared` while state is
  `unresolved_only_v1`;
- `mastered`;
- `AI detected your leak`;
- AI, leak, GTO, solver, optimal-frequency, or personalized-analysis claims;
- premium, paywall, trial, or commerce framing.

Also forbid deriving labels, reasons, or claims from raw internal ids without a
separately admitted safe-copy mapping.

## 11. Implementation readiness

The contract is ready for a data-only implementation, but not for UI.

Required next implementation seam:

- add `sourceTaskId` and `decisionKind` to durable evidence records, preserving
  old-record parsing;
- add pure `Act0ReviewMistakeRecordV1` and
  `Act0ReviewMistakeHistoryV1` contracts;
- project only non-correct completed decisions;
- implement max-200 retention, parsing, ordering, repeated-attempt
  deduplication, and active-intent suppression;
- persist the new history beside learning evidence;
- keep every entry `unresolved_only_v1`;
- expose no widget, copy, route, telemetry, or Practice/Profile consumer.

No pure model code was added in this selection wave because the source-task and
resolution gaps require an explicit implementation PR with focused migration
and persistence tests.

## 12. Tests / validation

This selection wave is documentation-only.

Validation:

- existing completed-decision contract inspected;
- durable learning-evidence schema, grouping, persistence, retention, and
  migration tests inspected;
- repair-intent creation, persistence, matching, and clearing tests inspected;
- current Review state projection and restore behavior inspected;
- `graphify hook-check`;
- `flutter analyze`;
- `git diff --check`;
- `git status --short`.

No Dart/source file or test was changed. No formatter or generated capture
command is required.

## 13. Next recommended PR

`Review Mistake-History Unresolved Projection v1 — Data Only`

Implement only the durable schema/projection/persistence and focused pure
contract tests described above. Do not render Review history, add clear
actions, open Practice/Profile consumers, or claim that any mistake is fixed.
