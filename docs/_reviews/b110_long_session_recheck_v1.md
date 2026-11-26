# B110 · T4 · Long-session hang re-check

**Verdict: gone (old harness hang mechanism, source review); runtime/CI unverified.**

Baseline: `codex/b110-long-session-recheck` = local `origin/main` = `a85177b9c2e79ede5d879e74f6db17e4c449c0a7`. Read-only `git -C /Users/elmarsalimzade/sharky-wt/lead-hotfix diff` at `9cdade7464441f9e342b17ae4fb8e50ec52f2868` (165 commits behind) changes only the long-session harness. It neither demonstrates a production hang nor fixes production code.

## What happened to the old hotfix

| Old diff | Current main |
|---|---|
| `_settle` with 5-second timeout and tap history | Already present; also checks Flutter exceptions and includes task, phase, teaching step, visible text. Both imported choreography/practice helpers also have explicit 5-second settle timeouts. |
| Replace open-ended teaching `while` with capped helper | Already present: `_finishTeaching` has 40 attempts, and `_tapTeachingContinue` checks enabled buttons and pumps 1 second for the dwell timer before retrying. |
| Clear `_tapLog` and exit Result via actionable close | Already present or superseded: the current driver takes the Result primary CTA first, uses the specific home/map button keys as fallback and checks that Result disappears. It can also return to Learn or repair checkpoint weak spots through Review. |
| Additional current harness limits (beyond old diff) | Current `registerLongSessionRoutes` caps each task and consecutive navigation at 40 attempts, totals at 3600/5200 steps, and has explicit 5/6/8-minute test timeouts; focused number-entry/bet-size cases are capped too. Existing all-task, XP, practice, missed-answer, restart and no-skip assertions are retained. |

## Runtime paths reviewed

Paths below are relative to `lib/ui_v2/act0_shell/`. **Guarded** means finite progress or lifecycle cancellation in source, not a measured device latency guarantee. **Unguarded** means a specific wait has no product-side deadline.

| Path exercised or reachable during the traversal | Verdict | Termination / risk |
|---|---|---|
| `act0_shell_preview_w1_rules_v1.dart` — W1 entry/rules check | guarded | Finite questions, explicit result and lesson entry, no automatic polling. |
| `act0_lesson_runner_shell_v1.dart` — `_syncTheoryAdvanceLock`, `_syncRapidReviewAdvance` | guarded | One-shot dwell/650 ms timers, unchanged interaction key does not rearm, mounted checks and disposal cancellation. A previously disabled CTA is now handled by the driver's fixed pump. |
| Same file — `_syncTableChoreographyV1`, `_advanceTableChoreographyV1` | guarded | One-shot 160 ms start then at most one timer per finite beat; monotonic beat index, ends at decision ready or plan length, generation/task identity fences and cancellation. Test helper pumps 500 ms per beat plus initial pump, then bounded settle. |
| `act0_lesson_runner_seats_v1.dart` — `_scheduleRevealUntil`, `_emitFocusedIndex` | guarded | Reveal count increases to target at 130 ms; timer disposed. Parent ignores identical focus index, so the post-frame notification does not endlessly rebuild it. |
| `act0_lesson_runner_seats_v1.dart` — `_toggleAutoPlay` | guarded for this route | A deliberately repeating 900 ms manual playback path, cancelled on toggle, widget update or disposal; no caller of `_toggleAutoPlay` in the current source and no driver activation. Not a route hang. |
| `act0_lesson_runner_shell_v1.dart`, `act0_sharky_presence_v1.dart`, `act0_learn_path_world_menu_v1.dart`, `act0_lesson_runner_completion_v1.dart` — attention, mascot, world-node and milestone reveals | guarded | Finite `forward` controllers (no `repeat`); milestone reveal has one post-frame callback and one finite timer. All controllers/timers have disposal cleanup. |
| `act0_shell_preview_answer_v1.dart` — `_shouldRetryInsideLesson`, `_startInsideLessonRetry`, `_maybeStartLessonWrapUpRetry`, `_continueAfterRepeatedLessonMissV1`; `act0_shell_preview_flow_v1.dart` — `_advanceAfterTask`, `_nextTask`; Result handlers in `act0_shell_preview_screen_v1.dart` | guarded | Per-run pending/retried sets consume the in-lesson retry; wrap-up skips already processed mistakes, repeated miss can leave a repair owed instead of forcing endless retries; successor selection is over finite task/lesson lists. Navigation is learner-driven, with test attempt limits catching a repeated selection. |
| `act0_shell_preview_route_practice_v1.dart` — `onContinueReview` | guarded | Rejects stale run/epoch and missing choice; advances through finite task IDs or finishes/re-enters Learn. Practice helper has bounded settle and the route shares the per-task/step cap. |
| `act0_shell_preview_home_v1.dart` — `_launchNextWarmupV1`, daily deck interleave; `act0_daily_practice_queue_v1.dart` — deck selection | guarded | Queue/deck loops remove entries or increase the selected count toward a finite cap. |
| `act0_lesson_runner_scene_v1.dart` — clause split; `act0_street_replay_contract_v1.dart` — deduced exits; `act0_shell_state_v1.dart` — XP progress | guarded | String search advances offset or breaks, deduced folds remove pending seats, capped XP decreases by positive level thresholds. No unbounded synchronous loop found in these helpers. |
| `act0_progress_store_v1.dart` — `_write`, `_removeVerified`, `_resolve`, `_commit`; `act0_shell_preview_persistence_v1.dart` — `_persistProgress`, `_writePersistedProgress`, save notice | guarded (retry/control flow) | Two attempts per verified write/remove; fixed checkpoint keys; serialized queue failure tail releases on success/error; stale generation/epoch requests coalesce. Save notice is a single 2-second timer cancelled on completion; Retry save is manual. |
| `act0_progress_store_v1.dart` — `_serial`, `loadState`, `save`, `flush`; `_bootstrapFirstStartRouteV1` in `act0_shell_preview_screen_v1.dart` / `_restorePersistedProgress` in persistence part | **unguarded (I/O wait)** | A never-resolving platform preference Future would block the per-key queue, save acknowledgement or boot; exception handlers handle thrown failures, not a Future that never completes. Boot's indeterminate spinner schedules frames until readiness/error, now caught by the harness's 5-second settle. This is a contingent external-I/O stall, not evidence of an actual loop in the mocked route. |
| `act0_shell_preview_answer_v1.dart` — `_openUnseenReviewTaskV1` acknowledgement; runner `_exposeDecisionAssistanceV1` | **unguarded (I/O wait)** | Awaited save/assistance acknowledgement can remain pending if the storage operation itself never completes; current epoch/interaction guards handle late returns, not a permanently pending Future. Optional branches, not the ordinary one-miss-per-world route; follow-up with injected never-completing storage if owner opens it. |
| `act0_attempt_replay_screen_v1.dart`, `act0_replay_playback_v1.dart` — focused archive replay | guarded | Playback timer only when playing, pauses at last finite step or lifecycle pause, disposed on exit. Imported timeline loop increments `revealed` on every iteration. |

No proven unguarded product loop on this route: no `skip:` added, no existing assertion disabled. Follow-up candidate is a **storage liveness** fault-injection package (boot, queued save and acknowledgement), not an excuse to skip the normal long-session test. A real device or injected hung platform call is necessary to establish that separate failure mode. B100 owns device traversal.

## Residual harness change and validation

Main already had bounded settle and route iteration; B110 closes the last direct unbounded storage awaits in `_saved` (preferences open/reload) and `_openSavedCourseTask` (persisted seed), using the existing 3-second flush budget per operation. `_waitForStorage` runs inside `runAsync` (real clock) and names the failed operation; test exceptions are checked before interpreting the returned snapshot/seed. No production timeout, routing change, skip, or test-budget increase. This cannot interrupt a synchronous isolate freeze; the outer CI watchdog remains necessary.

- `dart format` and focused `dart analyze test/ui_v2/act0_w1_long_session_v1_test.dart`: pass. Offline package configuration sourced read-only from the old worktree (identical `pubspec.lock`, relative roots resolve here).
- Flutter execution unavailable per `_rules_tech.md` (blocked localhost); no retry or simulator. CI must run the focused cases (`ACT0_LONG_SESSION_FOCUSED_ONLY=true`) and both Tier A W1–W3/W4–W7 route wrappers before the merge credit. Runtime verdict is not asserted from static analysis.
- No product code, route, telemetry, Modern Table, monetization or `docs/PLAN.md` change. No commits, pushes or PR by this package.
