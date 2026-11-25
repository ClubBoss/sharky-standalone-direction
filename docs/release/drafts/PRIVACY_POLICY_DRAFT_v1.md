# Sharky Poker privacy policy — draft

Effective date: [[OWNER: effective date]]

Operator: [[OWNER: legal operator name, country and postal contact address]]

Privacy contact: [[OWNER: working privacy/support email]]

## Your data on this device

Sharky Poker works without an account. We save your lesson and practice
progress on your device: your answers, use of help, mistakes and repeat
attempts, skill estimates, XP, study dates, place in the course, introduction
choices and settings. We use these records to support your learning, suggest
practice and restore your place in the course. They are not a certification
of poker skill. Local recovery copies help protect progress when saving is
interrupted.

If you import or manually enter a previous poker hand in Review, the app
stores a structured hand record for replay and study: cards, numbered seats,
stacks, actions, amounts and results, and the imported hand time. It does not
store the original pasted text or player names in the saved hand record.
These records stay on your device, including in local recovery copies.

The public learning route does not upload these records to us or to
analytics, advertising or AI services. It does not use cross-app tracking or
app-managed cloud sync.

If you enable the practice reminder and allow notifications, iOS schedules a
local reminder. You can change its time or turn it off in Sharky, or disable
notifications in iOS Settings.

## Optional sharing, beta testing and support

You can choose to share a lesson completion message and link through the
system share sheet. The message does not include your answers or private
history. The recipient and service you choose may keep the message.

Beta builds with local activity recording enabled can keep your first visit,
return days, lesson and practice counts, rules-check activity and optional
fixed-choice survey answers on your device. They are not automatically
uploaded. You can choose to copy a summary of activity and learning results
(including progress, answer counts, retries and optional survey responses)
and send feedback yourself.

Support can also provide a copyable diagnostic summary with app version,
platform and counts of errors in the current session. It does not include
your answer history or error stack traces. If you email us, we use the
address, message and attachments you choose to provide to respond, investigate
and follow up. Please avoid sending personal information in screenshots.
[[OWNER: support mailbox provider, storage location, access and sharing
arrangements, retention/deletion period and any legal basis required in the
countries served]].

Apple handles downloads, updates, optional review submissions and diagnostics
under its own [privacy policy](https://www.apple.com/legal/privacy/). Apple
may make crash reports, beta feedback and aggregate store statistics available
to the developer. [[OWNER: confirm which Apple reports are received, how they
are used and retained]]. You can manage diagnostics sharing in iOS Settings.

## Retention and deletion

Progress and preferences are kept between launches. Recent answer histories
are bounded, so newer attempts can replace older ones. To remove progress,
settings and local recovery copies, open **You → Settings → Delete local
data** and confirm. This also cancels the practice reminder. If deletion
cannot finish, retry when asked before continuing. Local deletion cannot be
undone.

Device or iCloud backups may contain app data under your Apple backup
settings. Sharky does not provide its own cloud restore. Deleting local data
does not erase earlier Apple backups, messages you sent, or copies you saved
outside the app. [[OWNER: confirm O4 reinstall decision; see support draft]].

To ask about access, correction or deletion of information you sent to
support, contact the privacy email above. [[OWNER: applicable rights,
complaint contact, response process and any required regional information]].

## Policy changes

We will post changes with an effective date at [[OWNER: public HTTPS privacy
policy URL]]. [[OWNER: confirm hosting provider, access logs/cookies,
retention and disclosures for the policy and support pages; amend this notice
if necessary]].

---

## Internal source inventory (not part of the published policy)

Inspected `origin/main` a85177b9c2e79ede5d879e74f6db17e4c449c0a7.
Persistence search: `git grep -nE 'SharedPreferences|FlutterSecureStorage|Hive\.|sqflite|File\(|UserDefaults' origin/main -- lib ios/Runner`.
Sink search: `git grep -nEi 'telemetry|analytics|http\.|Dio\(|launchUrl|Share\.|Clipboard\.|RemoteConfig' origin/main -- lib/main.dart lib/ui_v2/app_root.dart lib/ui_v2/act0_shell ios/Runner pubspec.yaml`.
Scope is the reachable iPhone Act0 route, not dormant legacy services merely
present in the repository. All Act0 source names below are relative to
`lib/ui_v2/act0_shell/` unless a different path is stated.

| Item stored or processed | File / field and destination |
|---|---|
| Completed/skipped tasks, completed lessons, selected world/lesson/task, deferred XP, earned XP, opened spaced review IDs | `act0_shell_preview_screen_v1.dart`, `_Act0PersistedProgressV1.toStorageString`; local `act0_shell_progress_v1` via `act0_progress_store_v1.dart`. |
| W1 start, best rules score and rules focus tasks, learner goal, profile skill values, recent gains | Same serializer and local key. |
| Lesson phase, teaching step, selected answer, multi-street runs, resume in runner and next-route state | Same serializer: `lessonResume`, `resume*`, `multiStreetRuns`. |
| Study/activity dates, daily rep count and task/lesson IDs, streak, practice days, daily practice/route queues, reminder response, home handoff dismissal and return-refresh offer | Same serializer: `lastActiveDay`, `lastShortSessionDay`, `lastEarnedDailyDay`, `daily*`, `persistedStreakDays`, `practiceDayKeys`, `firstLessonReminderAnswered`, `dismissedHomeHandoff*`, `returnRefreshOfferDay`. |
| Retention sequence/memory, repair intents and multi-repair queue/order, durable retention, review mistakes and resolution receipts, concept-family state, repair outcomes | Same serializer; local learning history, not exported. |
| Learning evidence and lineage (task/lesson/world and attempt IDs, answers, grade, assistance and timing), attempt archive, study observations, evidence boundaries, pending assistance, session identity, last session learner state and first-value receipt | Same serializer; nested records in `act0_learning_evidence_contract_v1.dart`, `act0_attempt_archive_v1.dart`, `act0_session_identity_v1.dart`. Internal IDs are for study/session bookkeeping, not account IDs. |
| Own hands: imported or manual format, source hash/record key, imported hand time, table size, button/hero seat, blind amounts, numbered seats and stacks, hero/board/shown cards, street/seat/action/chip amounts, payouts, showdown, pot and rake | `act0_imported_hand_v1.dart` → `act0_attempt_archive_v1.dart` (`importedHands`) → same local progress key; pasted source text processed on device, not saved verbatim; no player names in persisted payload. Manual record key is randomly generated and hashed. |
| Archived attempt label, choice label, table fingerprint/timeline, confidence, opened clue, learner input, action reason and event labels; selected archive ID | `act0_attempt_archive_v1.dart` → same local progress key. |
| Format version (20), recovery suppression, revision/heads, mirror, recovery and backup payloads, damaged copy and recovery intent | `act0_shell_preview_screen_v1.dart`, `act0_progress_store_v1.dart`: local SharedPreferences, including copies of the above data. |
| Welcome completed, introduction skipped | `act0_first_start_preferences_v1.dart`: `act0_welcome_completed_v1`, `act0_introduction_skipped_v1`. Compatibility onboarding booleans in `lib/ui_v2/onboarding/onboarding_preferences_service.dart`. |
| Placement version, completion UTC time, diagnostic correct/total, placement level, recommended lesson/task and focus label, placement score, intake completed, initialized free-roll counter | `act0_shell_preview_placement_v1.dart` → `lib/services/progress_service.dart` (`saveIntakeProfile`, `setPlacementScoreV1`); local preferences. Legacy service also defines unrelated data stores; these are not automatically active. |
| Language selection; haptics and settings preferences (sound, notifications, trainer UI, ICM, coach and engine-switch compatibility settings) | `lib/services/app_language_controller.dart`, `lib/services/app_settings_service.dart`: local preferences; existence of compatibility settings does not mean those legacy features run. |
| Reminder opt-in, scheduled hour/minute, pending and last reminder dates; notification permission and pending/delivered generic reminder | `act0_practice_reminder_v1.dart`, `ios/Runner/AppDelegate.swift`: native UserDefaults and local notification center, not push messaging. |
| Last App Store review request timestamp | `act0_growth_v1.dart`, `act0.store_review.last_request.v1` (local cooldown); native StoreKit review request via `ios/Runner/AppDelegate.swift`. |
| Delete-in-progress marker | `act0_local_data_deletion_v1.dart`, `act0_local_data_deletion_pending_v1`; local erase and recovery gate. Also clears native reminder and diagnostic file. |
| Beta first visit UTC, observed day, return day 2/7, fixed survey choices, lesson IDs/day, practice counts/day, rules check started | `act0_beta_metrics_v1.dart`, `act0_beta_activity_v1`; only with `SHARKY_BETA_METRICS`, local, default off. User can copy derived learning/return/survey summary using `act0_beta_metrics_dialog_v1.dart` and the system clipboard. |
| Framework/uncaught error counts during app run, version/build and platform | `act0_release_support_v1.dart`, `lib/main.dart`; counters in memory; copyable summary, no automatic support upload. Normal platform error handling remains. |
| Optional debug HNP events: progression, event names, task/session IDs, answer/repair and assistance fields, timing and sequence | `act0_shell_preview_telemetry_v1.dart`, `act0_telemetry_sink_v1.dart`, `act0_hnp_trace_file_store_io_v1.dart`; local JSONL trace and memory. `lib/ui_v2/app_root.dart` selects sink only with `HNP_TELEMETRY` and non-release mode; otherwise null. `act0_local_data_files_io_v1.dart` deletes trace. Not a public upload. |
| Fixed text and learning link on explicit Share confirmation | `act0_growth_v1.dart`, `act0_growth_links_v1.dart`; system share sheet, destination chosen by user. No answer history sent by this feature. |
| Incoming learning link | `ios/Runner/AppDelegate.swift`, `act0_growth_links_v1.dart`: local route input passed to Flutter; pending link in memory. |
| App Store review prompt | `act0_growth_v1.dart`, `ios/Runner/AppDelegate.swift`; Apple-controlled review UI, no app learning records passed to it. |

No active app analytics upload or remote flag service was found in this
source scan. `ios/Runner/PrivacyInfo.xcprivacy` declares the local
UserDefaults access; review the actual signed archive and integrated SDKs
before submission. Apple-managed backup, distribution, diagnostics and user
sharing are distinct from automatic app telemetry.

**Owner sign-off still required:** publish working URLs, confirm operator and
support/hosting handling, O4 and Apple data practices, and check the exact RC
against [Apple App Privacy details](https://developer.apple.com/app-store/app-privacy-details/).
Data Not Collected is a candidate answer for the public default-off build,
not a completed declaration. Reconcile the beta-labelled in-app notice
(`lib/ui/settings/privacy_terms.dart`) with the final public notice before GO.
