# F1M — existing measurement contract (B109)

F1M is elapsed wall time from a fresh app open to the first submitted real
Fold, Call or Raise answer, right or wrong. This is not F1 (startup/render
performance), the first read-the-table answer, or the time spent on a single
question. The threshold is inclusive: 180 seconds.

## Source inventory

| Milestone | Existing signal | Can the raw UI metrics file prove it? |
| --- | --- | --- |
| App open | No app-open event found in the requested sources or active Act0 sink. A raw frame sample has `t` (ISO timestamp) and `ms` (frame duration), not launch time. | No |
| Lesson start | Act0 emits `lesson_started` with `lessonId`, `taskId`; `session_start` denotes a learning session, not opening the app. Both are in the separate opt-in Act0 trace. | No |
| First real answer | Act0 emits `user_choice` and `decision_made` when an answer is committed. For W1's `first_table_guide_first_decision`, the authored `choiceId` / `chosen_action` values are exactly `fold`, `call`, `raise`. The two events describe the same attempt, not two answers. | No |
| Tasks done | Act0 `task_result` is an answer result, not proof that a task was cleared. `world_complete` with `worldId: world_1` and `completedClearCount` can corroborate a completed W1; there is no general per-task completion event in the UI metrics file. | No |
| Repairs taken | Act0 `repair_started`, `repair_entered`, and `repair_attempted` can describe the same repair entry; do not sum them. They do not establish an exhaustive count of all inline retries. | No |
| Drop-off | Act0 `task_shown` / `session_exited` can give context for the last observed activity, not prove why or when someone stopped. | No |

- [UI telemetry service](../../../lib/services/ui_telemetry_service.dart) writes
  best-effort `ui_metrics_events.jsonl` frame samples, `ui_anim` transition
  samples/aggregates and `ui_nav` durations. Its five-second `ui_metrics`
  screen/FPS summaries go through `UserActionLogger` (shared preferences
  `user_action_log`, with a `time` field), not necessarily to that raw file.
  No active Act0 call to `startFrameTracking` was found; the file may not exist
  on the test device.
- [Exporter](../../../tools/export_ui_metrics.dart) reads that JSONL and writes
  **aggregate JSON** `ui_metrics.json`; it cannot recover session milestones.
  Feed the raw JSONL, not the aggregate, to the F1M report.
- [Runner](../../../lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart):
  `_traceFirstDecisionV1` is enabled only outside release with
  `SHARKY_F1_STARTUP_TRACE=true`. Its one-time console marker
  `SHARKY_F1_FIRST_DECISION_US=<Timeline.now>` marks the post-frame
  ready/unanswered drill `what_poker_is_find_hero` (find your cards), not
  a Fold/Call/Raise submission. It is not a UTC timestamp or a JSONL event.
- [Act0 telemetry producer](../../../lib/ui_v2/act0_shell/act0_shell_preview_telemetry_v1.dart)
  and [sink](../../../lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart):
  the existing diagnostic flag `HNP_TELEMETRY=true` (non-release only) exports
  `act0_hnp_trace_v1.jsonl` to application support. Rows have `name`,
  `fields`, `sequence` and `capture`; exact timestamps are deliberately
  excluded, `decisionTimeBucket` is only a per-question duration bucket, and
  default retention is 256 rows. Sequence and incomplete/evicted traces cannot
  be used as elapsed time or complete journey evidence. This is a separate
  diagnostic stream, not input to the UI metrics report.

## Consequence

Raw UI metrics alone produce unknown values, not a fabricated start/answer or
zero tasks/repairs. Until the telemetry gap is resolved in a separately approved
scope, use the recording-based observation CSV in
[OWNER_RUN_v1.md](OWNER_RUN_v1.md) to fill the table from reproducible offsets
and observed progress. No event, privacy filter or product code is changed.
An unobserved answer or unavailable recording is not a timed pass.
