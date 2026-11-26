# GRO share and review entry inventory · B113

Source: `origin/main` at `8f2603285` (includes B100/#871).
Search: `git grep -n -i "share\|requestReview\|in_app_review" origin/main -- lib/`.
Reviewed actual outbound share APIs and their UI/service callers; shared
preferences, shared poker cards, localization-only strings, local-only exports
and ordinary lesson Review are not system share or store-review entries.

## Live (default iOS Act0 route)

| Entry / report ID | File (under `lib/`) | Trigger | Expected result |
|---|---|---|---|
| `act0_lesson_result_share` | `ui_v2/act0_shell/act0_lesson_runner_completion_v1.dart`, `act0_growth_v1.dart` | Finish a curriculum lesson (or world) → Result → Share result → Share. The same button serves both result tiers; iOS only, not debug harness. | Preview exactly `I completed a poker lesson in Sharky.\nsharky://open/v1/learn`; Cancel sends nothing; Share sends the same text only, no answers/history or automatic publishing. |
| `act0_world_review_prompt` | `ui_v2/act0_shell/act0_shell_preview_flow_v1.dart`, `act0_shell_preview_growth_v1.dart`, `act0_growth_v1.dart` | Newly earned world result, clean verified pass, positive XP, no run mistake/open review target; stay on foreground result ≥2 s. | One no-argument `requestReview` on `com.clubboss.sharky/growth_v1`; accepted request reserves 180-day cooldown. iOS StoreKit decides presentation; no rating/reward claim. |

## Present in source but not reachable from default Act0

These are not new routes to expose or phone checks to perform. The report
lists them as `reached: false` with the reason, not as passed or confirmed bugs.
Their expected results describe the dormant implementation, not GRO privacy
approval for those exports.

| Entry / report ID | File (under `lib/`) | Trigger | Expected result if legacy route were enabled |
|---|---|---|---|
| `legacy_hand_markdown_menu` | `screens/hand_history_review_screen.dart` | Hand history → Share icon → Markdown | Share `hand_export.md` with hand data and filename text. PDF option only saves locally. |
| `legacy_hand_markdown_button` | `screens/hand_history_review_screen.dart` | Hand history → Экспорт Markdown | Same Markdown file share. |
| `legacy_training_pack_share` | `screens/training_pack_core.dart`, `screens/training_pack_overlay.dart` | Pack screen → share FAB | Text `Training pack: <name>`. |
| `legacy_template_share` | `screens/training_pack_template_list_screen.dart` | Template menu → Поделиться | JSON template attachment. |
| `legacy_session_summary_share` | `screens/training_session_summary_screen.dart` | Training session summary → share icon | Summary PNG attachment. |
| `legacy_summary_spot_share` | `screens/training_session_summary_screen.dart`, `widgets/spot_viewer_dialog.dart`, `widgets/share_dialog.dart` | Summary mistake → spot viewer → Share → Share | Spot summary text. |
| `legacy_result_spot_share` | `screens/session_result_screen.dart`, `widgets/spot_viewer_dialog.dart`, `widgets/share_dialog.dart` | Session result → spot viewer → Share → Share | Same spot summary text. |
| `legacy_track_reward_share` | `services/stage_completion_celebration_service.dart`, `widgets/track_completion_dialog.dart` | Legacy track completion dialog → Поделиться | Reward PNG attachment. |
| `legacy_progress_pdf_share` | `screens/progress_screen.dart` | Progress → PDF | Native PDF share via `Printing.sharePdf`. |
| `legacy_session_notes_pdf` | `services/session_note_service.dart` | `exportAsPdf` service (no UI caller) | Session-note PDF attachment. |
| `legacy_training_stats_share` | `services/training_stats_service.dart` | `shareProgress` service (no UI caller) | CSV and PDF attachments (weekly/all-time parameter). |

## Reproduce before the phone pass

```sh
flutter test tools/gro_check_v1.dart
```

B100's W1 screen-navigation/grading driver, with clean answers instead of its
deliberate miss, uses a 393 × 852 iOS-shaped widget harness and real Result
widgets. As in B100 the save uses mocked preferences; the outbound share/growth
method channels are mocked as well. It checks
cancel/confirm and the exact captured text, then stays on the earned world
result for the actual review timer. No direct invocation of product sharing
or review services. No native simulator/StoreKit presentation is proven.

Read the ignored `build/gro/report.json`: a JSON array with one row per entry,
each containing `entry` (string), `reached` (bool), `payload_text` (string),
`exceptions` (string array). For review the payload is empty because the
method takes no text; a missing/extra call or route failure is an exception.
For dormant rows payload is empty and the exception explains why they cannot
be reached. CI smoke runs the same driver and requires the live rows to pass.
