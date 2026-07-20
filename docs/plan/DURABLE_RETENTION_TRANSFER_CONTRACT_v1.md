# Durable Retention & Transfer Contract v1

Status: ACTIVE CANONICAL ACT0 LEARNING CONTRACT

Implementation baseline: `fa74f50fe6e857b0191462acf97e74d3c6de4936` on
`main`. This contract closes the source-reproducible learning debt grouped as
`DG-RETENTION`: CL-LRN-F01, CL-LRN-F08, and CL-LRN-F11. It does not close or
expand W7 lesson depth (CL-LRN-F02), Human Novice Proof, Final Deep Independent
Audit, or AI Personalization.

## Purpose and human-learning claim boundary

Act0 now distinguishes an immediate repair from evidence that a read held after
time passed. A same-session correct answer may close the immediate repair route,
but it never proves durable retention or transfer. Durable language requires
two eligible successful spaced reviews. Transfer language requires recent,
timestamped, session-diverse, task-diverse evidence separated by at least 24
hours. Legacy untimestamped evidence remains readable but cannot acquire an
invented date or prove spacing.

This is a deterministic product-state contract, not proof that a human learned,
retained, or transferred poker skill in the scientific sense. It supports
claim-safe learner copy and future Human QA; it does not replace Human evidence.

## Canonical owner map

| Responsibility | Canonical owner |
| --- | --- |
| UTC clock and duration constants | `act0_durable_learning_time_contract_v1.dart` |
| Evidence timestamp and review-kind persistence | `act0_learning_evidence_contract_v1.dart` |
| Family retention state, due projection, ordering, and payload | `act0_durable_retention_contract_v1.dart` |
| Recent-evidence transfer verdict | `act0_learning_transfer_measurement_v1.dart` |
| Compatibility schedule projection | `act0_spaced_repetition_engine_v1.dart` |
| Schema migration, restore/write, evidence application, and route launch | `act0_shell_preview_screen_v1.dart` |
| Minimal due affordance on the existing Review route | `act0_review_shell_v1.dart` |
| Existing decision-event payload extension | `act0_lesson_runner_shell_v1.dart` |
| Selected deterministic authority | `tools/_world1_selected_tests_v1.sh` |

No owner creates a background timer, network scheduler, external analytics
dependency, new top-level route, or second persistence system. Retention logic
receives UTC time through `Act0UtcClockV1`; the system-clock adapter is the only
retention owner allowed to call `DateTime.now()`.

## Timing policy

All times are UTC and all boundary comparisons are inclusive at the due instant.

| Transition | Duration |
| --- | ---: |
| recovered -> first spaced review due | 24 hours |
| first due success -> second spaced review due | 72 hours |
| second due success -> maintenance due | 7 days |
| due miss/lapse -> next repair review due | 24 hours |
| minimum transfer separation | 24 hours |
| recent transfer window | latest 4 eligible records |

The constants live in one source owner, not in route widgets or tests.

## Retention state machine

The append-only states are `unseen`, `needsRepair`,
`recoveredPendingSpacedReview`, `due`, `durable`, and `lapsed`.

1. A miss creates or preserves `needsRepair` and preserves the entire repeated-
   miss history.
2. A correct recovery creates `recoveredPendingSpacedReview` due in 24 hours.
   Early correct attempts do not fabricate a due success.
3. At the due instant the refreshed projection is `due`.
4. The first eligible due success remains non-durable and schedules the second
   check 72 hours later.
5. The second eligible due success enters `durable` and schedules maintenance
   seven days later.
6. A miss while due or durable enters `lapsed`, preserves prior successes and
   misses, and schedules the next repair review in 24 hours.
7. A later correct recovery never erases prior repeated misses or fabricates
   durability; it starts the spaced path again.

Immediate repair, exact replay, and legacy-unspaced evidence can contribute to
history and repair state but cannot count as a spaced success. Re-applying the
same evidence record is idempotent by record identity.

## Due selection and routing

Only `due` and `lapsed` families are eligible for the Review due list. Ordering
is deterministic:

1. earliest `dueAtUtc`;
2. lapsed before ordinary due at the same instant;
3. concept-family id;
4. source-task id.

The Review tab shows one minimal `Ready to recheck` card and `Review now` CTA.
It launches the existing authoritative task through
`Act0LessonRunnerShellV1`; it does not clone lesson, repair, recheck, or payoff
UI. Unknown or non-launchable source identities fail closed.

## Review-kind and eligibility policy

Evidence persists one of these append-only kinds: `legacyUnspaced`,
`initialAssessment`, `immediateRepair`, `exactReplay`, `alternateSameSignal`,
`originalSourceRecheck`, `spacedReview`, or `unseenTransfer`.

- Transfer eligibility requires a timestamp and excludes legacy-unspaced,
  immediate-repair, and exact-replay evidence.
- Same-task repeat and same-session repeat do not prove transfer.
- A valid transfer comparison requires at least two task ids, two session ids,
  and at least 24 hours between the earliest and latest eligible records.
- Recent evidence, not immutable first-versus-latest history, decides the trend.
- Equal timestamps use `createdOrder` and then `recordId` for a stable tie-break.

## Transfer verdict table

| Verdict | Deterministic meaning | Claim boundary |
| --- | --- | --- |
| `insufficient_evidence_v1` | timing or diversity gate is not met | no transfer claim |
| `recovered_not_durable_v1` | recovery exists but spaced durability does not | repair only |
| `improving_v1` | recent eligible evidence moves from miss to two correct reads without a later lapse | conservative improvement |
| `stable_v1` | durable recent correct evidence remains correct | supporting stability, not mastery |
| `regressing_v1` | latest eligible record is a miss after prior success | regression/lapse signal |
| `mixed_v1` | recent eligible evidence contains unresolved mixed outcomes | no stable direction claim |

Unseen-transfer classification is retained as evidence metadata for a new task
surface; it does not bypass the timing and diversity gates.

## Persistence and migration

The canonical progress payload advances additively from schema 16 to schema 17.
Schema 17 adds `recordedAtUtc`, `reviewKind`, optional `sourceTaskId`, and
`durableRetentionHistory`. Schemas 1-16 remain readable. A schema-16 or older
payload derives a conservative legacy history from existing records: counts and
identities are preserved, timestamps remain null, and no due date, spaced
success, durability, or transfer claim is fabricated. The next normal write
emits schema 17. Clean install defaults and restore/write round trips are
deterministically guarded. Generic legacy and concept-specific error ids remain
readable through the unchanged compatibility parser.

Rollback is non-destructive but not forward-readable: an older schema-16 binary
will reject a schema-17 snapshot rather than reinterpret its new fields. A
rollback therefore requires restoring the pre-upgrade preference backup or
returning to the upgraded binary; migration never rewrites local `output/`
evidence or destructively transforms the prior payload in place.

## Telemetry contract

No event name or event count changes. Existing `user_choice` and
`decision_made` events add the bounded `review_kind` field so retention,
spaced-review, and transfer attempts are distinguishable without a duplicate
event. Existing base fields, decision identity, and cardinality remain intact.
There is no new sink, network path, background emission, or learner PII.

## Before/after deterministic proof

The pre-implementation red test demonstrated the three source failures:

- evidence payloads had no UTC event time;
- recent transfer could still report improvement after repeated misses or a
  later regression because it used immutable first-versus-latest order;
- one correct answer removed the family from future repair selection.

The focused matrix now covers recovery, before/at-due boundaries, both spaced
successes, seven-day maintenance, lapse and repeated lapse, unrelated concepts,
legacy migration, restart/round-trip, due ordering, duplicate reads, clock
determinism, exact versus alternate repair, unseen transfer, all six verdicts,
and equal-time tie-breaking. Route, Review, telemetry, payoff, and migration
tests prove the integration seams.

## Finding dispositions and next work

- CL-LRN-F01 — `CLOSED_FIXED`: UTC timestamps, due projection, and time-based
  spaced stages are canonical and persisted.
- CL-LRN-F08 — `CLOSED_FIXED`: recent eligible evidence with timing/diversity
  gates replaces immutable first-versus-latest transfer.
- CL-LRN-F11 — `CLOSED_FIXED`: a single recovery remains scheduled for a due
  recheck and repeated misses survive recovery and lapse.
- CL-LRN-F02 — historically `PRODUCT_DEBT_CONFIRMED`; W7 Depth Authority later
  closed the mandatory outcome gap without inferring a lesson-count rule.

At this contract's point in the sequence, the next Top-1 was **W7 Depth
Authority (CL-LRN-F02)**. It subsequently closed, followed by deterministic
convergence and the local Final Deep Independent Audit. This historical
contract does not select the current wave.
