# Telemetry Mapping

Use the existing local Act0 telemetry sink; after each session, export the in-memory event list from the session diagnostic capture (or record its structured event rows immediately with the observer scorecard). No external analytics export is required for this small cohort.

| Observer checkpoint | Expected event | Required identity / result fields | Collection |
| --- | --- | --- | --- |
| Choice and decision time | `user_choice`, `decision_made` | `worldId`, `lessonId`, `taskId`, `choiceId`, `correct`, `error_type`, `time_to_decision_ms`, `attempt_id` | session capture rows |
| Feedback read | `feedback_viewed` | `worldId`, `lessonId`, `taskId`, `result`, `feedbackSignal` | session capture rows |
| Review item/action | `repair_item_shown`, `repair_item_started` | `repairItemId`, `sourceTaskId`, `targetTaskId`, `missedSignal`, `status` | session capture rows |
| Repair completed | `repair_item_completed`, `repair_completed`, `fix_landed` | source/target task IDs, `repairItemId`, `correct`, `outcome`, `repairStatus` | session capture rows |
| Completion/exit | `session_start`, `session_end`, `world_complete` where applicable | `session_id`, stable world/lesson/task identity and completion result | session capture rows |

The preferred retention recheck is stable as `world_1` / `what_poker_is_table_read_transfer` / target `what_poker_is_table_read_recheck`; the deterministic telemetry test asserts `recheck_completed` with the transfer task identity. Keep raw event rows local and use a pseudonymous participant/session ID only.
