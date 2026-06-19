# First Return / Day 2 Persistence Contract Audit v1

Date: 2026-06-18
Mode: Audit-only
Scope: Act0 first-value, daily, repair, Review, and return-state persistence seams.

## 1. Wave Admission

Admitted as an audit-only persistence contract pass.

No app code, tests, routing, copy, telemetry, UI, screenshots, Playwright tooling, table geometry, dashboard, content, or monetization changes were made. The only intended artifact is this review note.

Primary question:

Can Sharky preserve the learner's first-session proof into a next-session or Day 2 return without depending on in-memory state?

Verdict:

Partially. The current Act0 shell has real local persistence for placement completion, route/progress state, same-day daily count, streak/day ledger, retention memory, open repair markers, and repaired proof. The weakest contract is the first-value receipt and same-signal Home carry: it is an in-memory object and is lost on relaunch before the learner consumes the next rep. Daily task identity is also partly session-only: the count persists, but same-day completed daily task ids do not.

## 2. PIEC Findings

### Placement / route persistence

- Owner: `Act0ShellPreviewScreenV1`.
- Durable stores:
  - `ProgressService.saveIntakeProfile(...)` writes `intake_profile_v1` and `intake_completed_v1`.
  - `ProgressService.setPlacementScoreV1(...)` writes `placement_score_v1`.
  - `_persistProgress()` writes `act0_shell_progress_v1`.
- Placement result is built when the diagnostic finishes, but placement completion is persisted when `_startPlacementRecommendation(...)` runs.
- Direct handoff persists selected world, lesson, task, skipped ids, and progress snapshot before calling placement completion persistence.

Interpretation:

If the learner finishes placement and taps the recommended start before exiting, the route and intake completion are durable. If the learner exits on the placement result before tapping start, the in-memory placement result is not itself a durable resume contract.

### First-value receipt / carry

- Owner: `_firstValueReceiptCarry`.
- Created by `_captureFirstValueReceiptCarryV1(...)` after first-value runner feedback when placement handoff is active.
- Consumed by `_startHomeNextAction(...)` and `_startFirstValueDailyRepLaunchV1(...)`.
- Cleared after same-signal launch.
- Not included in `_Act0PersistedProgressV1.toStorageString()`.
- Not restored by `_restorePersistedProgress()`.

Interpretation:

The first-value Home receipt is a strong in-session proof, but not yet a return-session contract. A learner who sees correct first feedback, exits, and relaunches will lose the exact "No bet yet -> one more action-read rep" carry.

### Same-signal next rep

- Owner: `_firstValueDailyRepTargetV1(...)`.
- Resolver derives target from `_firstValueReceiptCarry`.
- Mapping can produce a deterministic target, for example `actions_check_drill` for `repeat_action_read`.
- Target is not stored independently.

Interpretation:

The mapping itself is deterministic, but the input carry is session-only. Therefore same-signal next rep is deterministic in-session and not durable across relaunch until the learner actually launches/completes it.

### Daily progress / completion

- Owner fields:
  - `_dailyCompletedRepCount`
  - `_dailyCompletedTaskIds`
  - `_lastDailyDate`
  - `_persistedStreakDays`
- Durable fields in `act0_shell_progress_v1`:
  - `dailyCompletedRepCount`
  - `lastActiveDay`
  - `persistedStreakDays`
- Session-only field:
  - `_dailyCompletedTaskIds`
- Restore behavior:
  - Same day: count restored.
  - New day: daily count resets to 0 and daily task ids clear.
  - Consecutive-day streak is preserved; missed-day streak resets.

Interpretation:

The "Today complete" state is durable for the same day. On the next day, the product intentionally resets the daily goal. However, exact same-day no-repeat daily task identity is not durable; after relaunch, count can persist while task ids are empty.

### Repair state

- Owner fields:
  - `_mistakeRecords`
  - `_resolvedMistakeTaskIds`
  - `_retentionMemoryByTaskId`
- On wrong answer, `_recordAnswer(...)` writes:
  - an in-memory `_Act0MistakeRecordV1`
  - a persisted retention-memory entry with status `openRepair`
- Persisted field:
  - `retentionMemory`
- Not persisted:
  - full `_mistakeRecords` details such as selected label, better label, hardened reason, context labels, and repair action label.
- Review has tests proving persisted `openRepair` entries survive restore safely.

Interpretation:

Open repair is not entirely session-only. A durable queue marker exists through `retentionMemory.status == openRepair`. The exact rich mistake card details are partly reconstructed from content after relaunch rather than preserved as the original miss receipt.

### Repaired proof / Review

- Owner fields:
  - `_resolvedMistakeTaskIds`
  - `_retentionMemoryByTaskId`
  - `_cleanTaskIds`
- Correct repair changes retention memory from `openRepair` to `fixedRecent`.
- Retention memory is persisted and can age to `agedRecheck`, promote to `ownedCandidate`, and remain visible in Review.
- Existing focused tests cover:
  - retention-memory round trip
  - `fixedRecent` aging to `agedRecheck`
  - open repair safety on restore
  - recheck/prove-it state updates

Interpretation:

Repaired proof is the strongest durable part of the current loop. It is production-real local persistence, not only demo state.

### Profile / return value

- Owner: Profile/Home derived state in Act0 shell.
- Durable inputs:
  - completed task ids
  - clean task ids
  - resolved mistake task ids
  - earned XP
  - profile skill values
  - recent skill gains
  - streak/day ledger
  - retention memory
- Weakness:
  - Profile can show general progress and streak, but not the exact first-value receipt because that receipt is not persisted.

## 3. Persistence Artifact Created

Created:

- `docs/_reviews/first_return_day2_persistence_contract_audit_v1.md`

Purpose:

Document the active Act0 persistence contract before additional first-return or Day 2 product arcs, with explicit distinction between session-only proof, local persisted proof, and derived return-state proof.

## 4. Persistence Map Summary

| Surface / state | Owner | Store | Durable across relaunch? | New-day behavior | Contract verdict |
| --- | --- | --- | --- | --- | --- |
| Placement completion | `ProgressService.saveIntakeProfile`, `setPlacementScoreV1` | SharedPreferences | Yes after start recommendation is tapped | Persists | Mostly strong |
| Placement result screen itself | `_placementResult` | Memory | No | Lost | Gap if user exits before tapping start |
| Selected route/progress | `_Act0PersistedProgressV1` | `act0_shell_progress_v1` | Yes | Persists | Strong |
| Runner phase resume | persisted fields exist, restore intentionally ignores runner resume | `act0_shell_progress_v1` | No active runner resume | Home-first boot | Intentional |
| First-value receipt carry | `_firstValueReceiptCarry` | Memory | No | Lost | High gap |
| Same-signal next rep target | `_firstValueDailyRepTargetV1` derived from carry | Derived memory | No if carry lost | Lost | High gap |
| First-value telemetry | telemetry sink | Event stream only | Not user-state | N/A | Observability only |
| Daily completed count | `_dailyCompletedRepCount` | `act0_shell_progress_v1` | Yes same day | Resets to 0 next day | Strong enough |
| Daily completed task ids | `_dailyCompletedTaskIds` | Memory | No | Clears | Medium gap |
| Streak / day ledger | `_lastDailyDate`, `_persistedStreakDays` | `act0_shell_progress_v1` | Yes | Preserves consecutive streak; resets missed streak | Strong |
| Open repair marker | `retentionMemory.status == openRepair` | `act0_shell_progress_v1` | Yes | Persists | Good |
| Rich open mistake details | `_mistakeRecords` | Memory | No | Lost/reconstructed | Medium gap |
| Repaired proof | `fixedRecent`, `agedRecheck`, `ownedCandidate` | `retentionMemory` | Yes | Ages by sequence, not calendar | Strong |
| Home carried first-return reason | derived from first-value carry or persisted state | Mixed | Generic durable, exact first-value not durable | Generic next action | Medium-high gap |

## 5. Return Scenario Findings

| Scenario | Expected learner promise | Current return behavior | Verdict |
| --- | --- | --- | --- |
| 1. New learner finishes placement result but exits before first hand | App remembers placement and next recommended hand | If they tapped "Start first hand", route/progress and placement completion persist. If they exit on the result before start, `_placementResult` is not durable. | Partial |
| 2. Learner completes first correct feedback and exits | Home returns with exact "No bet yet" first-value receipt and same-signal rep | First-value carry is lost. Persisted task/progress may remain, but exact receipt and deterministic Home reason do not survive. | Gap |
| 3. Learner completes one same-signal rep and exits | Daily/progress reflects the rep and next action remains coherent | Completed progress and daily count persist. Exact daily task id exclusion does not persist. | Mostly ok, one medium gap |
| 4. Learner completes daily 3/3 and exits | Same-day return says today is complete | `_dailyCompletedRepCount` persists and same-day Home can stay done. | Ok |
| 5. Learner repairs a mistake and exits | Review shows repaired proof | `fixedRecent` retention memory persists; repaired proof is durable. | Strong |
| 6. Learner returns next day after daily completion | Daily resets and offers next useful hand | Count resets by date. Streak can remain. Specific next-day "why this hand" is derived/generic, not a persisted continuation receipt. | Mostly ok, product copy should stay honest |
| 7. Learner returns with no open mistakes | Home/Review should not invent repair pressure | Persisted retention memory can show rechecks/prove-it only when statuses exist; no open marker means no open repair queue. | Ok |
| 8. Learner returns with one open repair | Review/Home should offer repair | `openRepair` retention entry persists. Rich original wrong-answer details may be reconstructed rather than preserved. | Good, with detail gap |

## 6. Biggest Persistence Gaps

1. First-value receipt carry is session-only.

This is the biggest product gap because the first-session proof spine has become one of Sharky's primary competitive advantages. Losing the exact "you noticed No bet yet -> practice same table clue" state on relaunch weakens Day 2 trust.

2. Same-signal next rep target is not stored.

The resolver is deterministic, but it depends on the session-only carry. Persisting either the carry or a compact resolved target would make the return contract real.

3. Placement result is not itself a durable screen-state contract.

Placement completion persists after starting the recommendation. Exiting on the result screen before tapping start can lose the result proof and recommended handoff state.

4. Daily completed task identity is session-only.

The count persists, which protects the visible 3/3 promise, but the exact completed daily tasks do not. This can allow task repetition after same-day relaunch if the learner continues before the daily reset.

5. Open repair detail is partly durable, not fully durable.

The repair marker survives through `retentionMemory.openRepair`, but the original miss card details in `_mistakeRecords` do not. This is acceptable for MVP queue durability but weaker than a full "you missed this exact thing" return receipt.

## 7. Product Interpretation

Current Sharky is not just fixture/demo state. The active Act0 shell uses SharedPreferences-backed progress with schema version 8, and several first-return surfaces are production-real within the current standalone Act0 runtime.

The product should not claim a fully durable first-value return loop yet. The in-session loop is strong: first-value feedback, signal proof, Home carry, same-signal launch, daily completion, and repair proof all work as a coherent path. The Day 2 contract is more uneven:

- durable: route progress, daily done count same-day, streak, retention memory, repaired proof
- partly durable: open repair queue
- not durable: exact first-value receipt/carry and same-signal launch reason

This means the next product arc should not be broad premium polish. It should close the smallest persistence hole that protects the app's core learning proof.

## 8. Recommended Next 1-3 Arcs

1. First-Value Return Carry Persistence MVP v1

Persist a compact first-value carry contract in `act0_shell_progress_v1`:

- `skillReceiptId`
- `skillAtomId`
- `sourceSignalId`
- `sourceSignalLabel`
- `outcomeId`
- `nextRepId`
- `nextRepLabel`
- `sourceWorldId`
- `sourceLessonId`
- `sourceTaskId`
- optional `createdDay`
- optional `consumed` or expiry rule

Acceptance:

- Correct first feedback survives relaunch and Home still shows the exact same-signal reason.
- Wrong first feedback survives relaunch and Home still offers repair-oriented same-signal next action.
- Tapping the CTA after relaunch launches the same deterministic target.
- Consuming the CTA clears the persisted carry.
- No route-order, UI redesign, or copy rewrite.

2. Daily Same-Day Task Identity Persistence v1

Persist `_dailyCompletedTaskIds` for same-day no-repeat protection. Reset it with the existing new-day daily reset.

Acceptance:

- Same-day relaunch after 1/3 or 2/3 keeps count and avoids repeating completed daily tasks.
- Next-day relaunch clears daily task ids.
- Existing 3/3 done state remains unchanged.

3. Placement Result Resume Contract Audit/Corrective v1

Decide whether exiting on the placement result before tapping start must restore the exact result screen. If yes, persist a compact placement-result handoff record. If no, keep current behavior and ensure copy does not imply the result is saved before start.

Acceptance:

- Product truth is explicit: either result-screen return is supported, or only post-start route persistence is supported.

## 9. Files Changed

Changed in this wave:

- `docs/_reviews/first_return_day2_persistence_contract_audit_v1.md`

Pre-existing unrelated dirty/untracked files were observed and not modified by this audit.

## 10. Verification

Commands run or inspected:

- `sed`/`rg` reads over Act0 shell, progress service, and focused Act0 tests
- `git status --short`
- `git diff --check` after artifact creation

No tests were run because this was an audit-only documentation wave and the prompt did not request test execution.

No screenshots or Playwright tooling were run.

## 11. Remaining Risks

- This is a static audit, not a device persistence run. SharedPreferences behavior was inferred from code and existing tests.
- Exact Home rendering after relaunch for each scenario was not screenshot-verified.
- The repair queue can survive as a persisted marker, but rich original miss details are not guaranteed to survive byte-for-byte.
- Date-boundary behavior depends on local `DateTime.now()` and existing test fakes; no time-travel integration run was performed in this wave.
- Existing broad dirty worktree state was not normalized, by instruction.

## 12. Direction Score

Current first-session plus first-return direction: 7.7 / 10.

Why not higher:

- Sharky's in-session proof loop is strong and differentiated.
- Daily/repaired proof persistence is real.
- The exact first-value receipt, which is the most important new trust moment, is not durable across relaunch.

Compared with Runout and benchmark stack from proven current results only:

- Sharky is stronger on deterministic table-signal proof and repair-loop specificity.
- Runout remains stronger on polished packaging and perceived app maturity.
- Sharky's clearest route to market-leading learning value is not more packaging first; it is making the proof spine survive return sessions.

## 13. Recommended Next Arc

Run `First-Value Return Carry Persistence MVP v1`.

This is the smallest high-EV corrective because it preserves the exact learning proof the user just earned:

user choice -> visible table clue -> why -> same-signal next rep -> return-session Home reason.

Do this before broader premium polish, Profile expansion, dashboard work, or new content volume.
