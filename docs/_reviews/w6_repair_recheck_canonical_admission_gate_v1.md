# W6 Repair-Recheck Canonical Admission Gate v1

Status: docs-only canonical route admission review.

Verdict: `w6_repair_recheck_finding_misscoped`.

Branch: `codex/w6-repair-recheck-canonical-admission-gate-v1`.

Base: `20dda460ce909542553843e0342a93e315a3fb05`.

## Scope Guard

This review determines whether `W1W6-DLR-002` exists on the canonical Act0
Home/Learn learner route. It does not implement a repair, edit product code,
edit content, edit tests, touch tooling, touch Modern Table, or integrate any
session-drill content branch.

## Source Documents And Files Inspected

- `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`
- `docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md`
- `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
- `lib/ui_v2/runner/canonical_launcher_api_v1.dart`
- `lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart`
- `lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart`
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- focused tests for Act0 telemetry, Review recheck queue, session-drill target
  launch, and W6 mapped repair behavior.

## Canonical W6 Route

Canonical W6 route:

`AppRoot -> Act0ShellPreviewScreenV1 -> Home/Learn -> world_6 Range Thinking -> Act0 lesson task -> Act0LessonRunnerShellV1 -> Act0 answer/repair/recheck/progress state`

The canonical W6 content is not `content/worlds/world6/v1/sessions/w6.s01`.
The normal learner reaches W6 through the Act0 world card `world_6`, titled
`Range Thinking`, whose active lessons are `_rangeThinkingFoundationLessons`
from `act0_shell_state_v1.dart`.

Canonical W6 lessons/tasks inspected:

- `range_bucket_basics`
  - `w6_range_intro`
  - `w6_value_dry_board`
  - `w6_missed_dry_board`
  - `w6_table_bucket_notice`
  - `w6_buckets_recap`
- `range_board_fit`
  - `w6_board_fit_intro`
  - `w6_wrong_board`
  - `w6_value_wet_board`
  - `w6_turn_shift_bucket`
  - `w6_board_fit_recap`
- `range_pressure_lines`
  - `w6_pressure_lines_intro`
  - `w6_value_range_action`
  - `w6_bluff_candidate`
  - `w6_missed_hand_action`
  - `w6_table_value_line_transfer`
  - `w6_turn_pressure_shift_transfer`
  - `w6_wet_board_repair`
  - `w6_pressure_lines_recap`

Additional W6 lessons exist in source, but the canonical `world_6` card uses
the three foundation lessons above.

## Required Owner Map

| Owner | Classification | Evidence / responsibility |
| --- | --- | --- |
| W6 route owner | `CANONICAL_REQUIRED` | Act0 shell route selects `world_6` and gates it through Home/Learn world and lesson progression. |
| W6 content owner | `CANONICAL_REQUIRED` | `act0_shell_state_v1.dart` owns the route-visible `world_6` Range Thinking lessons and tasks. |
| Progression owner | `CANONICAL_REQUIRED` | `_progressWorld`, `_progressLesson`, `_taskAvailable`, `_completeCurrentTask`, and `_advanceAfterTask` own world/lesson/task progression. |
| Completion owner | `CANONICAL_REQUIRED` | Act0 `completedTaskIds`, `completedLessonIds`, and `_Act0PersistedProgressV1` own canonical W6 completion. |
| Telemetry owner | `CANONICAL_REQUIRED` | Act0 answer/repair/recheck/world-completion telemetry is emitted from `act0_shell_preview_screen_v1.dart`; `ACT0_TELEMETRY_TRUTH_MAP_v1.md` classifies `lib/ui_v2/act0_shell/*` as active route owner. |
| Repair owner | `CANONICAL_REQUIRED` | `_recordAnswer`, `buildAct0RepairIntentV1`, `_storeOpenRepairIntentForMissV1`, `_startMistakeRepair`, and Review/Home repair CTAs own canonical task-centric repair. |
| Targeted-recheck owner | `CANONICAL_REQUIRED` for Act0 task rechecks; `ACTIVE_OPTIONAL` for session-drill recheck queue | Act0 retention memory (`openRepair -> fixedRecent -> agedRecheck -> ownedCandidate`) owns canonical task rechecks. `SessionDrillRecheckLaunchQueueItemV1` is consumed by Act0 Review only when a separate session-drill receipt exists. |
| Payoff / next-step owner | `CANONICAL_REQUIRED` | `_maybeShowBlockCompletionSummary`, `_seedWorldCompletionRetentionTargetsV1`, `_advanceAfterTask`, Home daily jobs, and Review own payoff, future recheck counts, and next task/world routing. |

## Canonical Error-To-Recheck Chain

Representative canonical W6 error:

`Home/Learn -> world_6 -> range_pressure_lines -> w6_bluff_candidate -> wrong answer ("Bet for value")`

Trace:

1. Home/Learn opens canonical Act0 `world_6` / `range_pressure_lines`.
2. `_startTaskByIds` launches the Act0 task and records lesson-start/session
   evidence.
3. The learner chooses a wrong or suboptimal option in `w6_bluff_candidate`.
4. `_recordAnswer` records the mistake under the Act0 source task id.
5. `buildAct0RepairIntentV1` creates an `Act0RepairIntentV1` from the Act0
   runner receipt; this is task-centric, not session/drill-centric.
6. `_storeOpenRepairIntentForMissV1` stores the open repair intent in the
   Act0 multi-repair queue and open-repair index.
7. `_recordAnswer` stores `_Act0RetentionMemoryEntryV1` with status
   `openRepair` and persists progress.
8. Home or Review starts the repair through `_startMistakeRepair`.
9. For `w6_bluff_candidate`, `_repairVariantTargetForSourceV1` maps the repair
   to `w6_turn_pressure_shift_transfer`; unmapped W6 task mistakes fall back to
   exact Act0 task replay.
10. Repair launch emits `repair_started` / `repair_attempted` and starts an
    Act0 task, not a JSON session drill.
11. Correct repair emits `repair_completed`, `fix_landed`, and
    `repair_item_completed`, closes the matching repair intent, marks the
    repaired target complete, and stores retention status `fixedRecent`.
12. After enough route progression, `_refreshRetentionMemoryStatusesV1`
    promotes `fixedRecent` to `agedRecheck`.
13. Home daily plan or Review surfaces the aged recheck with job id
    `recheck:<taskId>` / a recovered replay card.
14. The learner launches the recheck through `_startMistakeRepair` in retention
    replay mode.
15. A correct recheck emits `recheck_completed` and promotes retention memory to
    `ownedCandidate`.
16. `_Act0PersistedProgressV1` persists completed task ids, retention memory,
    open repair intents, and queue state.
17. Canonical progress/payoff continues through Act0 completion summary and
    `_advanceAfterTask` to the next task, lesson, or world.

First broken link on canonical Act0 route: **none found for the task-centric
repair/recheck chain.**

The broken link claimed by the old audit belongs to the session-drill receipt
path, not to canonical Act0 W6 task repair.

## Key Questions

1. **Does canonical Act0 W6 emit the receipt or queue item cited by the old
   audit?**
   No. A canonical Act0 W6 answer creates an `Act0RepairIntentV1` and retention
   memory. `SessionDrillRecheckLaunchQueueItemV1` is built from persisted
   session-drill repair receipts.

2. **Is `SessionDrillRecheckLaunchQueueItemV1` used by canonical Act0?**
   Yes, but only as an optional Review queue card loaded from the session-drill
   receipt consumer. It is not emitted by the canonical Act0 W6 Home/Learn
   route.

3. **Does Act0 use a separate task-centric repair mechanism?**
   Yes. Act0 uses `Act0RepairIntentV1`, mistake records, retention memory,
   Home/Review repair CTAs, and Act0 task replay.

4. **Can the learner reach a canonical recheck after a W6 error?**
   Yes. After a task-centric W6 repair is fixed and enough progression passes,
   retention memory promotes to `agedRecheck`, then Home/Review can launch a
   task replay recheck.

5. **Does recheck completion update canonical Act0 progress correctly?**
   Yes for canonical retention state: `recheck_completed` is emitted and
   retention memory becomes `ownedCandidate`. It does not need to create a new
   route task because it replays an already-owned Act0 task.

6. **Is the alleged dead end learner-visible?**
   Not for a canonical Act0 W6 Home/Learn error. The session-drill queue card
   can be learner-visible in Review only if a separate persisted session-drill
   receipt exists, but that is not the canonical W6 task path.

7. **Did the old finding rely on legacy/session-drill infrastructure?**
   Yes. The old audit's chain is
   `SessionDrillRepairReceiptCandidateV1 -> SessionDrillRepairReceiptPersistenceV1 -> SessionDrillRepairRecheckCandidateV1 -> SessionDrillRecheckLaunchQueueItemV1`.
   That is session-drill infrastructure, not canonical Act0 W6 answer handling.

8. **Does the finding legitimately cap W6's score?**
   No. This finding does not cap W6's canonical Act0 score because its premise
   does not describe the canonical W6 repair owner.

9. **Is there a different canonical repair gap hiding behind the misscoped
   finding?**
   No P1-equivalent canonical gap was found in this review. A lower-severity
   future audit may still evaluate whether every W6 family has the ideal
   same-signal transfer target, but the canonical route has exact replay,
   mapped transfer for key pressure-line tasks, persistence, telemetry, and
   aged recheck.

## Old Audit Owner Classification

`docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md` is
valid for the session-drill receipt/queue family it inspected, but it is
noncanonical for the Act0 W6 Home/Learn learner route.

Classification:

- Old session-drill repair receipt / queue owner:
  `ACTIVE_OPTIONAL` support surface when a session-drill receipt exists.
- Old finding as a canonical W6 score blocker:
  `LEGACY_BLOCKED` / noncanonical evidence for the normal Act0 W6 route.

Important history update: the old audit reported `STOP` because target-drill
launch and recheck completion policy did not exist at that time. Current source
now includes `initialDrillId`, `isRecheckLaunchV1`, Review queue-card launch,
and suppression of normal session completion for recheck launches. That later
session-drill improvement still does not make session-drill receipts canonical
W6 score evidence.

## Finding Validity

Decision: `NONCANONICAL_FINDING_MISSCOPED`.

Reason: `W1W6-DLR-002` describes a session-drill receipt/queue dead end. The
canonical Act0 W6 route does not emit that receipt or depend on that queue for
normal W6 repair. Canonical Act0 W6 uses task-centric repair intents, persisted
retention memory, Home/Review replay, and `recheck_completed` telemetry.

## Score Impact

Decision: `NO_CANONICAL_SCORE_IMPACT`.

Do not use `W1W6-DLR-002` as a W6 score cap. It may remain as optional
session-drill route-history context, but it is not a canonical Act0 W6 learning
defect.

## Implementation Disposition

Decision: `CORRECT_LEDGER_NO_REPAIR`.

No product repair is admitted by this review. The minimum next step is a
separate docs-only ledger correction that withdraws `W1W6-DLR-002` as a
canonical P1 and preserves the session-drill note as noncanonical history.

## No-Scope-Expansion Confirmation

No product, content, test, tooling, route, Modern Table, or session-drill
source changes were made. This artifact is review-only.
