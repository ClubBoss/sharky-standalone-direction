# Act0 screen logic inventory · V6 / B23

Source baseline `bb8af520`, with the B23 extractions below. Scope follows `lib/main.dart` → `lib/ui_v2/app_root.dart` → `Act0ShellPreviewScreenV1`. Paths below are relative to `lib/ui_v2/act0_shell/` unless stated. Tables describe states and data available to the current UI. A shared boot state or “no separate state” has no screen-specific data to draw.

Copy entries identify the current English state and action strings and the source for variable and localized copy. Standard buttons, links, switches and form fields expose their visible text or Flutter control semantics. Accessibility entries call out extra labels, hints and state announcements. The shell navigation exposes the Home, Learn, Practice, Review and You tab names and selection. Telemetry below belongs to shell action/exposure hooks and the existing sink in `act0_shell_preview_telemetry_v1.dart`. It is conditional on the run and route.

## Shell startup and recovery

| State | Data to draw and actions |
| --- | --- |
| Loading | Boot readiness, local preferences and progress hydration. Progress indicator before learner routes are available. |
| Error / recovering | Startup vs progress-read failure, optional recovery message and busy flag. “Sharky could not finish starting.” / “Your saved progress could not be read.”, “Try again”, and, for progress, “Recovery options” / “Delete local data”. Save failures after startup use a shell notice. |
| Deleting / delete error | Deletion in progress or durable retry. “Deleting local data…”, “Data deletion unfinished”, “Retry deletion”. |
| First run / empty / done | Successfully loaded local snapshot routes to first start or the appropriate returning learner surface. |
| Offline | Same local reads, recovery and deletion. |

**Owner and outputs.** `act0_shell_preview_screen_v1.dart`, `act0_shell_preview_persistence_v1.dart`, `act0_progress_store_v1.dart`, `act0_first_start_preferences_v1.dart`, `act0_local_data_deletion_v1.dart`. Shell owns async orchestration. Stores own read/write outcomes and deletion. **Accessibility.** Progress indicators, text and existing retry controls. **Telemetry.** `progress_persist_result` on persistence.

## Welcome

| State | Data to draw and actions |
| --- | --- |
| First run | Intro beat, mode flag, authored demo metadata. “Try one table read”, “This preview is ungraded. Your first lesson comes next.” Start demo. |
| In progress | Demo beat and authored question, options and table facts. Compact accessibility step where active. Pick an option or go back/close. |
| Done | Handoff beat, optional selected label, replay and recommended-launch flags. “Your path is ready.” / “You can reopen this anytime.”, optional “You tried … This preview was ungraded.”, “Start recommended lesson” / “Open my path” / “Back to profile”. |
| Empty / loading / error | No separate Welcome states. Entry and durable preferences use shell startup/recovery. |
| Offline | All beats use the bundled demo and local first-start flags. |

**Owner and outputs.** `act0_welcome_shell_v1.dart` owns localized copy, demo runner projection, accessibility flow and callbacks. B23 `Act0WelcomeStateV1` owns beat and orientation choice label. Shell persists completion or returns from replay without updating progress. **Accessibility.** Button text, step copy and bundled demo runner semantics, including the compact evidence/decision alternative. **Telemetry.** No Welcome-specific emission in the widget. Subsequent real lesson launches use the standard run/start hooks.

## Placement and W1 rules check

| State | Data to draw and actions |
| --- | --- |
| First run | Placement intro and optional skip, or current W1 start chooser. “Find my start”, “Start with the basics” and optional rules check. |
| In progress | Question ID/index, selected option IDs, option labels, single/multi-select bounds, check index and authored choices. “Where are you starting from?”, “How should Sharky start?”, “Continue”, “Start from zero”, “Start quick check”. Back, change selection or start the check. |
| Done | Placement recommendation and lesson/world target, or W1 score, pass/fail and topic reasons. “Your start”, “Start World 1” / “Start World 2”, or start recommended/from zero. |
| Empty | Exhausted placement questions lead to the diagnostic action. There is no distinct empty screen. |
| Loading / error | Shell startup/recovery owns persistence errors. No Placement spinner or diagnostic data fetch. |
| Offline | Bundled questions and local answers/onboarding disposition. |

**Owner and outputs.** `act0_placement_shell_v1.dart` uses B23 `Act0PlacementViewModelV1` for the primary-action rule. The question/result widgets own copy and controls. `act0_shell_preview_placement_v1.dart` owns routing, answers, diagnostic and persistence. `act0_shell_preview_w1_rules_v1.dart` owns W1 start/check/result and can bypass the legacy questionnaire. **Accessibility.** “Back” tooltip in the English flow, question and option text and CTA labels. **Telemetry.** Placement shell logic can emit `session_start` on learning entry. The questionnaire/widget itself emits no separate event.

## Home

| State | Data to draw and actions |
| --- | --- |
| First run | Catalog and placement target. First useful hand/recommended lesson when available. |
| Empty | No current mission or no personal reason. Render the current fallback action or completion, depending on route progress. |
| In progress | Selected world/lesson, resume position, due review or route practice, daily goal count, recommendation reason, phase/streak and proof where sourced. Open the exact action supplied by the shell. |
| Done | Daily goal reached or current route completed. Daily count and next available world/action where present. |
| Loading / error | Shared boot/progress states. No Home-specific fetch. |
| Offline | Same source-owned mission from local progress and bundled lessons. |

**Owner and outputs.** Shell and `act0_shell_preview_home_v1.dart` choose the action and launch it. `act0_academy_runtime_adapter_v1.dart`, `academy_leaves/act0_academy_home_leaf_v1.dart` and `act0_home_shell_v1.dart` compose it. Existing copy includes “YOUR NEXT STEP”, “Start practice”, “Open Learn” and the dynamic lesson/resume/review CTA. **Accessibility.** Streak label “$streakDays day streak”, “Learning guide, in order: Recall, Learn, Apply. No step is marked complete.”, “Current training phase: $label” or “Step $number, $label” on the Academy leaf. **Telemetry.** Recommendation and action-payoff generated/shown, recommendation accepted, `first_value_today_shown` and repair-item exposure where eligible. **Next seam.** Extract the assembled mission/daily status where still resolved inside shell/widget build. Keep the recommendation and callback on the same source IDs.

## Map / Learn

| State | Data to draw and actions |
| --- | --- |
| First run | Catalog volumes, first available world and requested placement focus. Open a world/lesson. |
| Empty | Content comes from the bundled catalog. Closed worlds have prerequisite data. No separate empty Map. |
| In progress | Current world/volume/lesson, route progress, unlocked/locked availability, required practice and lesson selection. Navigate, resume, start lesson or required practice. |
| Done | Cleared world/volume, lesson completion and next selectable node, if any. |
| Loading / error | Shared startup/recovery; no separate map fetch. |
| Offline | Catalog, progress and unlocks are local. |

**Owner and outputs.** Shell owns selection, progression truth and launch. `act0_path_progress_v1.dart` and `act0_learn_path_journey_v1.dart` hold route models. `act0_learn_path_shell_v1.dart`, `act0_learn_path_cards_v1.dart`, `act0_learn_path_world_menu_v1.dart` and `act0_learn_path_mission_v1.dart` build cards, volume/world selection and mission. Strings include “Cleared”, “Active”, “Next”, “Locked”, “Finish … to open.” and catalog titles. **Accessibility.** Merged button semantics for Learn targets and Material dialog semantics for the world picker barrier. **Telemetry.** Launch can start the lesson/run events. `world_complete` belongs to the completion transition. **Next seam.** Move remaining volume/focus/mission selection from Learn widget state while preserving callbacks.

## Lesson intro / teaching entry

| State | Data to draw and actions |
| --- | --- |
| First run | Selected world, lesson, task and first authored teaching step where the runner opens in theory. |
| Empty | A drill may open directly when no intro/teaching step is needed. No empty intro view. |
| In progress | Authored headline, step/body/clue, rail index and count, available disclosure actions; resume location comes from the shell. Back or advance through teaching. |
| Done | Teaching advances into the corresponding drill. |
| Loading / error | Shared shell states. No per-intro network load. |
| Offline | Bundled teaching copy and locally saved position. |

**Owner and outputs.** There is no dedicated stand-alone lesson intro route. Map mission and runner theory cover entry. `act0_shell_preview_launch_v1.dart` chooses phase. `act0_lesson_runner_shell_v1.dart` and `act0_lesson_runner_surfaces_v1.dart` project the authored copy and rail into the existing runner. Copy source is task/teaching content plus the Academy instruction and CTA copy in `act0_runtime_surface_copy_v1.dart`. **Accessibility.** Rail step and content semantics, text/CTA labels and existing adaptive reading surface. **Telemetry.** `lesson_started`, `learning_run_started` and `theory_completed` where applicable. **Next seam.** Isolate the intro copy/rail projection from runner build before changing its layout. Table-geometry work belongs to its own stage.

## Result / Session summary

| State | Data to draw and actions |
| --- | --- |
| First run | First completion may offer a reminder when eligible. “Want one reminder at 6 pm when practice is ready?”, “Yes”, “No thanks”. |
| Empty | The summary requires a completed slice. Optional evidence/payoff cards can be absent. |
| In progress | An active lesson stays in the runner. No summary while the slice is open. |
| Done | Completed block, lesson or world details, score/outcomes, practice or repair proof and source-owned next action when available. Continue, review, replay, return to Map, or “Back to Home” based on the summary contract. |
| Loading / error | No summary fetch; durable-save failure belongs to the shell. |
| Offline | Same locally computed summary. Reminder support is platform dependent. |

**Owner and outputs.** `act0_shell_preview_flow_v1.dart` and `act0_shell_preview_learning_run_v1.dart` assemble and close the run. `Act0RunnerCompletionSummaryV1`, `Act0SessionSummaryEvidenceViewModelV1` and payoff projections hold source data. `Act0BlockCompletionShellV1` in `act0_lesson_runner_completion_v1.dart` selects/layouts optional sections and shows localized summary labels. **Accessibility.** Visible heading, outcome and action text; reminder actions retain visible labels. **Telemetry.** Session/run completion and applicable `session_payoff_generated`, `session_payoff_viewed`, `session_focus_selected`, `next_practice_recommended`, `session_payoff_completed`, `world_complete`. **Next seam.** Move section eligibility and CTA pairing still assembled in the shell or completion widget.

## Review

| State | Data to draw and actions |
| --- | --- |
| First run / empty | No mistakes or due checks. “No saved mistakes yet”, “Continue learning”. |
| In progress | Open repair debt, featured mistake/pattern, due independent checks or saved check. “Start review”, “Continue saved check”, “Review this mistake”. Launch the exact repair/check, open archive or return to Learn. |
| Done | No open repairs or past repairs available for historical replay. “No open repairs” and history-backed rows. |
| Loading / error | Shared persistence states; no Review-specific loading or network error. |
| Offline | Same review queues, due dates and evidence from local storage. |

**Owner and outputs.** Shell, review history/repair/retention projections and `act0_academy_runtime_adapter_v1.dart` supply independent sources to `academy_leaves/act0_academy_review_leaf_v1.dart` and `act0_review_shell_v1.dart`. Leaf still picks featured/empty/due sections. Existing row copy uses authored or projected mistake/action labels. **Accessibility.** Due counts and repair/history CTA text, with inherited button semantics. **Telemetry.** Recommendation and repair-item shown/start/completion, repair/recheck events on actual actions. **Next seam.** Extract review presentation selection while keeping due, repair, history and saved-check input contracts distinct.

## Archive / Own hands / Replay

| State | Data to draw and actions |
| --- | --- |
| First run / empty | “Attempt archive”, “No saved attempts yet.”, “No saved own hands.” and archive/own-hand navigation. |
| In progress | “Search saved attempts”; visible rows match task/choice label or IDs, with “No matching attempts.” for no hits. Expand an attempt, inspect choice/help/legacy reflection and confirm removal, or open replay. Own hands can be imported, entered, edited or removed. |
| Done | Replay reaches the last saved event. “Step … of …”, “Earlier steps”, “Previous”, “Next”, “Play” / “Pause”, “Reset”. Legacy attempts without events show “No event history was saved for this attempt.” |
| Loading | Snapshot arrived during shell boot. No archive loading state. |
| Error | Import/entry shows invalid, duplicate, unsupported or full-archive messages. Shell handles persistence errors. |
| Offline | Local attempts, journals, manual hands and pasted PokerStars history. No remote hand lookup. |

**Owner and outputs.** `act0_attempt_archive_v1.dart` owns content, selection and storage. B23 `Act0AttemptArchiveViewModelV1` owns query, visible attempts, own-hands subview and replay return. `act0_attempt_archive_screen_v1.dart` still owns confirmation, dialogs, dates/local formatting and callback wiring. `act0_attempt_replay_screen_v1.dart` owns playback timer and reads `Act0AttemptReplayV1`. **Accessibility.** “Search saved attempts” and “PokerStars hand history” field labels, expanded state on attempt rows and live replay step announcements. **Telemetry.** No archive/replay-specific event. Own-hand practice follows standard practice hooks. **Next seam.** Dialog/validation presentation and own-hand event projection where needed. The new LRN input is absent from current archive and replay copy.

## Profile / You

| State | Data to draw and actions |
| --- | --- |
| First run / empty | Zero or absent proof, current course context, and available Learn/Practice/Settings actions. No fabricated session or backfilled skill proof. |
| In progress | Local tasks, worlds, streaks, skills, practice/repair evidence and expandable details when eligible. Open Learn, Practice, Review or Settings. |
| Done | Recorded milestones/skills and completion-backed progress where present. |
| Loading / error | Shell boot/save/recovery. No separate profile fetch. Recovery is available when exposed by the shell. |
| Offline | Local evidence and catalog descriptors. |

**Owner and outputs.** `act0_shell_preview_profile_v1.dart`, `act0_profile_evidence_projection_v1.dart` and the runtime adapter supply `academy_leaves/act0_academy_you_leaf_v1.dart` / `act0_profile_shell_v1.dart`. Widgets own disclosure and some row visibility. Copy includes “Skills · W1–W…”, “Tasks”, “Route”, “Accuracy”, and source-provided achievement/evidence labels. **Accessibility.** “Settings” tooltip on You, native expansion semantics on skills/details and control text. **Telemetry.** No leaf-specific You event. Outbound routes own their events. **Next seam.** Extract remaining section visibility and detail-row derivation where still in widgets.

## Settings

| State | Data to draw and actions |
| --- | --- |
| First run / empty | Default preferences and supported routes. Platform or callback availability can suppress individual rows. |
| Loading | Local preference load in progress; spinner. |
| Error | “Could not load preferences. Retry”, or “Preference was not saved. Try again.” for a failed write. |
| In progress | Haptics, supported practice reminder value and save busy state. “Replay Welcome”, “Take the W1 rules check”, “Recovery options”, “Delete local data”, “Beta activity” / “Support”, “Privacy Policy”, “Terms of Use” where available. |
| Done | Persisted preference values continue on the ready screen. Deletion completion goes through shell restart. |
| Offline | Local preferences, replay, checks and recovery work locally. Legal/external destinations have platform/browser availability. |

**Owner and outputs.** Settings route state in `act0_academy_runtime_adapter_v1.dart`; `academy_leaves/act0_academy_settings_leaf_v1.dart` reads `Act0AcademySettingsLeafInputV1`. Stores are `lib/services/app_settings_service.dart`, `act0_practice_reminder_v1.dart` and the shell's recovery/deletion owners. **Accessibility.** “Back” tooltip and merged row semantics, switch state and retry text. **Telemetry.** No Settings leaf emission; optional beta diagnostics use the existing local data surface. **Next seam.** Move route preference loading/saving state only if needed for a replacement Settings widget.

## Practice hub

| State | Data to draw and actions |
| --- | --- |
| First run / empty | Practice availability and Learn fallback. Locked items carry an explanation or no launch callback. |
| In progress | Daily groups/deck state, available topics and recommendation title/subtitle/target. Start a voluntary rep, open Review or go to Learn. |
| Done | Daily progress and available follow-up groups from the same local queues. |
| Loading / error | Shared shell states. |
| Offline | Bundled groups/deals and local practice state. |

**Owner and outputs.** `act0_shell_preview_route_practice_v1.dart`, shell recommendation/launch logic and `act0_daily_practice_queue_v1.dart` feed the runtime adapter, `academy_leaves/act0_academy_practice_leaf_v1.dart` and `act0_play_shell_v1.dart`. “Practice” and group/CTA copy come from the leaf/runtime copy and input. **Accessibility.** “locked” semantics on unavailable rows and visible button labels. **Telemetry.** `practice_started`, `practice_completed`, `first_value_daily_rep_launched` where applicable. **Next seam.** Lift remaining presentation-only hub choices once the recommendation and launch IDs can be preserved together.

## Manual own-hand entry

| State | Data to draw and actions |
| --- | --- |
| First run / empty | New local hand draft, or seed values from the selected existing manual hand. |
| In progress | Table setup, seat/stacks, cards and per-street actions. Add/remove actions, move between steps, cancel or save. |
| Error | Validation for missing or invalid hand data. Error and draft are both available. |
| Done | Returns a validated own hand to Archive, which persists it and opens replay. |
| Loading | No separate fetch or loading view. |
| Offline | All input and validation are local. |

**Owner and outputs.** `act0_manual_hand_screen_v1.dart` owns edit state and returns `Act0ImportedHandV1`; imported-hand model/parser enforce source constraints. Copy includes “Add … action”, “Save action”, “Previous” and field-specific validation. **Accessibility.** “Remove action” tooltips and live validation error text. **Telemetry.** No manual-entry-specific event. **Next seam.** Extract draft validation/navigation when this auxiliary screen is redesigned.

## LRN-01.a storage boundary

`Act0LearnerReflectionInputV1` stores optional confidence and learner-authored mistake-reason text. `Act0AttemptArchiveV1.withLearnerInput` replaces or clears the input for an existing attempt. Confidence is independent of grade and help. A mistake reason attaches only to an incorrect attempt. The input round-trips in the existing local progress snapshot and disappears when the archive entry or all local data is deleted. Archive rows still display their existing historical reflection fields. The visual wave owns capture timing and the widget/callback binding to the existing archive snapshot writer.
