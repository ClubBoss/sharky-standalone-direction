# Deterministic Session Identity v1

## 1. Verdict

`deterministic_session_identity_landed_with_bounded_events`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`.
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`.
- Starting HEAD: `d374c87516231a98cd74e5a5ba6fcc3578c3703b`.
- Tracked and staged changes at preflight: none.
- Untracked at preflight: `output/**` only.
- `graphify hook-check`: exit 0.

## 3. Capsule/authority check

The active capsules were fresh to `f9a1909f`, while the task worktree HEAD was
`d374c875`. The prompt explicitly set `Phase 2 - Learning Truth Foundation`,
closed Concept Family State Foundation, and opened Deterministic Session
Identity. That route fact is higher authority than capsule next-task text and
is consistent with the phase map, so this was treated as a non-blocking
freshness note, not `stale_capsule_scope`.

## 4. Current lifecycle audit

- Learner session start is currently expressed by Act0 shell task launch:
  `_startTaskByIds`, `_emitLessonStartedTelemetryV1`,
  `_emitPracticeStartedTelemetryV1`, and `_startLearningEvidenceRunV1`.
- "Session" already existed under narrower names: learning evidence `runId`,
  `runKind`, and `runOrdinal`. Those identify lesson/practice/repair runs, not
  one local learner session across miss, repair, and completion.
- Session completion is owned by `_emitPracticeCompletedTelemetryV1` and
  `_maybeShowBlockCompletionSummary`, both flowing through
  `_emitSessionCompleteTelemetryV1`.
- Session summary state is assembled from `Act0LearningEvidenceHistoryV1` and
  current-run summaries.
- Repair attempts and outcomes are written through `_recordAnswer`,
  `_appendPracticeQueueRepairOutcomeV1`, and `Act0RepairOutcomeProjectionV1`.
- Canonical local telemetry is emitted by Act0 shell helpers for
  `session_start`, `repair_attempted`, `fix_landed`, `session_complete`,
  `day2_return`, and `world_complete`; runner-owned `decision_made` is emitted
  inside `Act0LessonRunnerShellV1`.
- Persisted progress is loaded/saved through `_Act0PersistedProgressV1` under
  `act0_shell_progress_v1` in `SharedPreferences`.
- Existing counters: learning evidence `runOrdinal`, repair outcome sequence,
  retention sequence, daily rep count.
- Hot restart restores durable progress but intentionally lands Home-first
  instead of reopening the runner. Active session identity therefore resumes as
  state, not as an automatic UI route.

## 5. Session owner

The authoritative owner is the existing Act0 persisted progress snapshot. No
parallel store and no telemetry-owned state were introduced.

## 6. Session contract

Added `Act0SessionIdentityStateV1` and `Act0SessionIdentityRecordV1` with:

- `schemaVersion`
- `sessionId`
- `startedAtOrder`
- `startedWorldId`
- optional `startedLessonId`
- `status`
- optional `completedAtOrder`
- optional `completionReason`

Statuses are only `active` and `completed`. No `abandoned` state was added
because the current lifecycle has no authoritative abandon event.

## 7. ID generation strategy

IDs are locally generated from an owned monotonic ordinal:

`session_v1|<ordinal>`

The next ordinal is persisted and normalized against the highest seen persisted
session ID to avoid collisions after reload. No wall-clock-only ID, random UUID,
device fingerprint, account ID, or PII is used.

## 8. Start/resume/complete rules

- First session creation: task/practice start creates `session_v1|1`.
- Repeated reads during the same session: `startOrResume` returns the active
  session without incrementing.
- App rebuild/re-render: no session is created by rendering alone.
- Route transitions inside the same session: reuse the active session.
- Practice repair: reuses the active session; a restored valid repair write can
  defensively resume/create state if it has no active session.
- Session completion: closes the active session and emits one
  `session_complete`.
- Starting after completion: increments to the next local ordinal.
- Interrupted app restart: active session identity is restored as persisted
  state; runner UI still follows the existing Home-first boot policy.
- Old or malformed state: defaults to empty session identity state.

## 9. Persistence/migration

`_Act0PersistedProgressV1` moved from schema `13` to `14` and now writes
`sessionIdentityState`. v1-v14 snapshots are accepted. Missing or malformed
optional session state defaults safely. Existing learning evidence, review
history, concept-family state, retention, and selected route fields are
preserved.

## 10. Concept-family integration

`Act0LearningEvidenceRecordV1`, `Act0RepairOutcomeV1`, and
`Act0ConceptFamilyStateV1` now support optional session linkage:

- evidence records may carry `sessionId`;
- repair outcomes may carry `sessionId`;
- concept-family state records expose `lastSessionId`.

Historical records are not rewritten. Missing `sessionId` parses as empty.

## 11. Telemetry integration

Bounded session linkage was added to current local canonical learning events:

- `session_start`
- `decision_made`
- `repair_attempted`
- `fix_landed`
- `session_complete`
- `day2_return` when a latest session exists
- `world_complete` when a latest session exists

Runner `decision_made` receives the shell-owned active session ID through a
small sink wrapper. Telemetry remains non-authoritative.

## 12. Backward compatibility

Old learning evidence without `sessionId`, old concept-family state without
`lastSessionId`, old repair outcomes without `sessionId`, and v1-v13 persisted
progress snapshots continue to load safely.

## 13. Tests

Focused passing validation:

- `flutter test test/ui_v2/act0_session_identity_v1_test.dart test/ui_v2/act0_learning_evidence_contract_v1_test.dart test/ui_v2/act0_concept_family_state_foundation_v1_test.dart test/ui_v2/act0_repair_outcome_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Old persisted progress without retention fields restores safely|Persisted session identity state round-trips|Malformed persisted session identity defaults safely|Incorrect completed decisions persist unresolved mistake history|New lesson-run evidence records carry one shared run key"`
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`

Full `act0_shell_preview_screen_v1_test.dart` still exits 1 with existing broad
UI/localization expectation failures unrelated to this state seam; the focused
session/persistence tests above pass.

## 14. Scope safety

No UI changes, copy changes, route changes, transfer scoring, personalized
return reason, spaced repetition, server analytics, vendor SDK, account/device
fingerprint, dependency, W13+ work, or broad refactor was introduced.

## 15. Known limitations

Session identity is a local join key only. It does not compute transfer
measurement, return reasons, spaced repetition intervals, retention cohorts,
analytics funnels, or public learning-effect claims.

## 16. Next recommendation

`Learning Transfer Measurement v1`
