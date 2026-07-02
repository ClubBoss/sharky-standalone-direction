# Concept Family State Foundation v1

## 1. Verdict

`concept_family_state_foundation_landed_with_bounded_coverage`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`.
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`.
- Starting HEAD: `f3ccddb24d9f653ec9028bed97bedba56e78b372`.
- Tracked and staged changes at preflight: none.
- Untracked at preflight: `output/**` only.
- `graphify hook-check`: exit 0.

## 3. Capsule/authority check

The active capsules were fresh to `f9a1909f`, while the task worktree HEAD was
`f3ccddb2`. The prompt explicitly moved the current phase to
`Phase 2 - Learning Truth Foundation` and named Concept Family State Foundation
as step 1. That route fact is higher authority than the capsule next-task text
and is consistent with the capsule phase map, so this was treated as a
non-blocking freshness note, not `stale_capsule_scope`.

## 4. Current state ownership audit

- Active repair state owner: `Act0RepairIntentV1` plus the Act0 shell's
  `_openRepairIntentBySourceTaskId`.
- Repair intent contract: `act0_repair_intent_contract_v1.dart`.
- Repair outcome contract: `Act0RepairOutcomeProjectionV1`.
- Review unresolved-history state: `Act0ReviewMistakeHistoryV1`.
- Practice repair queue state: `Act0PracticeRepairQueueProjectionV1`.
- Session Summary proof receipt source: `Act0LearningEvidenceHistoryV1` and
  `Act0RepairOutcomeConsumerV1`.
- Profile proof projection source: `Act0ProfileEvidenceProjectionV1` from
  `Act0LearningEvidenceHistoryV1`.
- Local persistence mechanism: `_Act0PersistedProgressV1` under
  `act0_shell_progress_v1` in `SharedPreferences`.
- Current identifiers: `worldId`, `lessonId`, `taskId`, `sourceTaskId`,
  `attemptKey`, `conceptFamilyId`, `repairFocusId`, `skillAtomId`, `errorType`.
- Current telemetry seams: local `task_result`, `repair_attempted`,
  `fix_landed`; telemetry remains non-authoritative for product state.

## 5. Existing identifier/taxonomy findings

`conceptFamilyId` already exists on `Act0CompletedDecisionV1` and
`Act0LearningEvidenceRecordV1`. Existing projections fall back to
`repairFocusId`, then `skillAtomId`, then `errorType` when explicit
`conceptFamilyId` is absent. This PR reuses that accepted identifier order and
does not introduce a new taxonomy.

## 6. Concept-family contract

The new source-owned contract is `Act0ConceptFamilyStateHistoryV1` with
per-family `Act0ConceptFamilyStateV1` records:

- `schemaVersion`
- `conceptFamilyId`
- `worldId`
- `lastSeenAt`
- `lastAttemptAt`
- `lastProofAt`
- `missCount`
- `repairAttemptCount`
- `successfulRepairCount`
- `lastOutcome`
- `lastTaskId`

Outcome values are:

- `missed`
- `repair_attempted`
- `repair_succeeded`
- `repair_not_yet_succeeded`

No mastery label, mutable score, queue resolution, fixed-forever state, or
cross-session improvement claim was added.

## 7. Persistence owner

The persistence owner is the existing `_Act0PersistedProgressV1` shell snapshot.
The snapshot schema moved from v12 to v13 and now writes
`conceptFamilyStateHistory`. Older v1-v12 snapshots remain accepted; absent or
malformed optional concept-family state defaults to an empty history.

## 8. Mapping seam

The deterministic mapping is:

1. explicit `conceptFamilyId`;
2. `repairFocusId`;
3. `skillAtomId`;
4. `errorType`.

Repair outcomes map by `repairFocusKey`, with `repairTaskId` as a last safe
fallback. No UI string, localized copy, or display label parsing is used.

## 9. Write rules

- Normal miss: append from completed decision evidence; increment `missCount`;
  update `lastSeenAt`, `lastTaskId`, and `lastOutcome = missed`.
- Repair attempt: append from repair-run evidence or repair outcome seam;
  increment `repairAttemptCount`; update `lastAttemptAt`.
- Successful repair: increment `successfulRepairCount`; update `lastProofAt`;
  set `lastOutcome = repair_succeeded`.
- Unsuccessful repair: do not increment success; set
  `lastOutcome = repair_not_yet_succeeded`.
- Repeated miss in same family: aggregate into the same family record.
- First encounter: create the family record with schema version 1.
- Duplicate source: ignored by stable source ids, preventing repeated-render
  writes.

## 10. Read API

The read model exposes only raw state:

- `familyById`
- `knownFamilyIds`
- `mostRecentActiveFamily`
- `toPayload`

No ranking, scheduling, recommendation, streak, weakest-skill wording, or
improvement score was added.

## 11. Backward compatibility

Existing users with no `conceptFamilyStateHistory` load safely into an empty
state. Malformed family records are ignored. Existing `learningEvidenceHistory`
and `reviewMistakeHistory` behavior remains unchanged and continues to
round-trip.

## 12. Tests

Added focused contract tests for:

- first family creation;
- repeated miss aggregation;
- repair attempt and repair success counts;
- unsuccessful repair handling;
- timestamp/order updates;
- serialization round-trip;
- missing and malformed optional state;
- stable id mapping;
- same-family and different-family aggregation;
- duplicate-source protection;
- raw read APIs;
- source dependency guard.

Updated shell persistence tests for:

- v13 defaulting;
- concept-family state round-trip;
- source-backed miss persistence.

## 13. Scope safety

No new UI, copy, route, Review redesign, Practice redesign, Session Summary
redesign, Profile redesign, telemetry owner, dependency, server analytics,
vendor SDK, AI/adaptive claim, XP/rating/radar/level/mastery score, W13+ work,
or broad refactor was introduced.

## 14. Unsupported/deferred families

Coverage is bounded to currently evidenced Act0 family ids available through
completed decision evidence and Practice repair outcome requests. There is no
universal W1-W12 taxonomy expansion, no spaced repetition scheduling, no
personalized return reason, no transfer score, and no multi-repair queue.

## 15. Next recommendation

`Deterministic Session Identity v1`

Validation note: the new focused state suite and focused owner tests pass, and
the newly added shell persistence tests pass when the full shell file reaches
them. The full `act0_shell_preview_screen_v1_test.dart` file still exits 1 due
to unrelated pre-existing broad UI/localization expectations outside this
state-foundation path.
